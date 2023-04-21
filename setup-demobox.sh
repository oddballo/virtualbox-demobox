#!/bin/bash

PATH_VBOX="${PATH_VBOX:-}"
PATH_DOWNLOADS="${PATH_DOWNLOADS:-/tmp}"
VM_NAME="${VM_NAME:-demobox}"
VM_CPU="${VM_CPU:-2}"
VM_HDD="${VM_HDD:-20000}"
VM_RAM="${VM_RAM:-2048}"
VM_SSH="${VM_SSH:-2222}"

IMAGE_CODENAME="jammy"
IMAGE_DESCRIPTION="Ubuntu 22.04"
IMAGE_NAME="$IMAGE_CODENAME-server-cloudimg-amd64.ova"
IMAGE_URL_IMAGE="https://cloud-images.ubuntu.com/$IMAGE_CODENAME/current/$IMAGE_NAME"
IMAGE_URL_CHECKSUM="https://cloud-images.ubuntu.com/$IMAGE_CODENAME/current/SHA256SUMS"

#-----------------------------------------
set -eou pipefail

if [ ! -z "$PATH_VBOX" ]; then 
	PATH="$PATH_VBOX:$PATH"
fi

if [ ! -d "$PATH_DOWNLOADS" ]; then
	mkdir -p "$PATH_DOWNLOADS"
fi

downloadImage(){
    PATH_DOWNLOADS=$1
    IMAGE_NAME=$2
    IMAGE_DESCRIPTION=$3
    IMAGE_URL_IMAGE=$4

    echo "The next operation can take some time to complete."
    echo -n "Fetching cloud image ($IMAGE_DESCRIPTION)..."
	if [ ! -f "$PATH_DOWNLOADS/$IMAGE_NAME" ]; then
		curl --create-dirs -O \
            --fail \
			--output-dir "$PATH_DOWNLOADS" \
             --progress-bar \
			$IMAGE_URL_IMAGE &>> "$LOG_FILE" &&
			echo "Success" ||
			{ echo "Failure. Please check log at $LOG_FILE for more information."; return 1; }
	else
        echo "Found (already downloaded)."
	fi

}

validateImage(){
    PATH_DOWNLOADS=$1
    IMAGE_NAME=$2
    IMAGE_URL_CHECKSUM=$3

    cd "$PATH_DOWNLOADS"
    echo -n "Validating cloud image checksum..."
    curl -s "$IMAGE_URL_CHECKSUM" \
        | grep " \*$IMAGE_NAME$" \
        | sha256sum --check --status &&
        echo "Success" ||
        { echo "Failure. Potential corruption or network issue when fetching image."; return 1; }
}

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$DIR"
LOG_FILE="$DIR/log.txt"
>"$LOG_FILE"

RETRY_LIMIT=3
for (( ATTEMPT=0; ATTEMPT<$RETRY_LIMIT; ATTEMPT++)); do

    downloadImage \
        "$PATH_DOWNLOADS" \
        "$IMAGE_NAME" \
        "$IMAGE_DESCRIPTION" \
        "$IMAGE_URL_IMAGE"

    validateImage \
        "$PATH_DOWNLOADS" \
        "$IMAGE_NAME" \
        "$IMAGE_URL_CHECKSUM" \
        || { rm "$PATH_DOWNLOADS/$IMAGE_NAME"; echo "Removed corrupt image. Trying again."; continue; }

    break
done
if [ $ATTEMPT -ge $RETRY_LIMIT ]; then
    echo "Hit max retry limit for fetching image. Aborting."
    exit 1
fi

FILE_SEED="${PATH_DOWNLOADS}/seed.iso"
if [ ! -f "$FILE_SEED" ]; then
    {
        cd "$DIR/seed"
        echo -n "Building seed.iso using remote webserver..."
        ./build-using-web.sh &>> "$LOG_FILE" &&
            echo "Success" ||
            { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }
        cp seed.iso "$FILE_SEED"
    }
else
    echo "Found seed.iso. Reusing (delete file $FILE_SEED to trigger regeneration)."
fi

FLAG_FORCE=1
FLAG_SKIP_IMPORT=1
while getopts :fs FLAG; do
    case $FLAG in
        f) FLAG_FORCE=0 ;;
        s) FLAG_SKIP_IMPORT=0 ;;
    esac
done

command -v vboxmanage &> /dev/null || { echo "Missing vboxmanage. Is VirtualBox installed?"; exit 1; }

echo "DEBUG FLAG_FORCE=$FLAG_FORCE" &>> "$LOG_FILE"
echo "DEBUG FLAG_SKIP_IMPORT=$FLAG_SKIP_IMPORT" &>> "$LOG_FILE"

if [[ $FLAG_SKIP_IMPORT -eq 0 ]]; then
    echo "FLAG_SKIP_IMPORT set. Forced to skip import checks."
else	
    if vboxmanage list vms | grep -q "^\"$VM_NAME\" "; then
        echo "Virtual Box already exists. Continuing with configuration"
        if [[ $FLAG_FORCE -eq 0 ]]; then
            echo -n "FLAG_FORCE enabled. Destroying $VM_NAME..."
            vboxmanage unregistervm --delete "$VM_NAME" &>> "$LOG_FILE" &&
                echo "Success" ||
                { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }
        else
            echo "Virtual machine \"$VM_NAME\" already exists. Run with -f to force cleanup ahead of deploy."
            exit 1
        fi
    else
        echo "Virtual Box \"$VM_NAME\" not found locally"
    fi
    echo -n "Importing Virtual Box \"$VM_NAME\"..."

    vboxmanage import \
        --options importtovdi \
        --vsys 0 \
        --ostype Ubuntu_64 \
        --cpus $VM_CPU \
        --memory $VM_RAM \
        --unit 9 \
        --ignore "$PATH_DOWNLOADS/$IMAGE_NAME" \
        --vmname "$VM_NAME" &>> "$LOG_FILE" &&
                echo "Success" ||
                { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }
fi

INTERFACES="$(vboxmanage list hostonlyifs)" 
if [[ "$INTERFACES" == "" ]]; then
    echo -n "Generating Host only interface..."
    vboxmanage hostonlyif create &>> "$LOG_FILE" &&
        echo "Success" ||
        { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }

    INTERFACES="$(vboxmanage list hostonlyifs)" 
fi

# Remove NAT SSH rule (if present). Ignore failure to remove rule
vboxmanage modifyvm "$VM_NAME" --nic1 nat --natnet1 default --natpf1 delete ssh &> /dev/null || true

INTERFACE="$(vboxmanage list hostonlyifs | grep "^Name:" | tr -s " " | cut -f2- -d" ")"

# Setup SSH port forward
echo -n "Setting up SSH port forward from 127.0.0.1:$VM_SSH to Virtual Machine..."
vboxmanage modifyvm "$VM_NAME" --nic1 nat --natnet1 default --natpf1 ssh,tcp,127.0.0.1,${VM_SSH},,22 \
    --nic2 hostonly --hostonlyadapter2 "$INTERFACE" &>> "$LOG_FILE" &&
    echo "Success" ||
    { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }


# Attach IDE - Ignore failure - likely already in place
vboxmanage storagectl "$VM_NAME" \
    --name IDE \
    --add ide &> /dev/null || true

# Resize HDD image
HDD="$(vboxmanage showvminfo --machinereadable "$VM_NAME" | grep "^\"SCSI-0-0" | cut -f2- -d= | cut -f2 -d\")"
echo -n "Resizing hard drive to $VM_HDD..."
vboxmanage modifyhd "$HDD" \
    --resize $VM_HDD &>> "$LOG_FILE" &&
            echo "Success" ||
            { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }


# Attaching seed ISO to the box
echo -n "Attaching seed.iso to the virtual machine..."
vboxmanage storageattach "$VM_NAME" \
    --storagectl IDE \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$FILE_SEED" &>> "$LOG_FILE" &&
            echo "Success" ||
            { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }


echo -n "Starting virtual machine..."
vboxmanage startvm "$VM_NAME" &>> "$LOG_FILE" &&
            echo "Success" ||
            { echo "Failure. Please check log at $LOG_FILE for more information."; exit 1; }
  

cd "$DIR"
while ! timeout 2 ./tool/stream-over-ssh.sh $VM_SSH "echo \"Connected over SSH!\""; do
    echo "SSH not available yet. Waiting upto 5 seconds."
    sleep 3
done
echo "SSH available. Continuing after 2 seconds."
sleep 2

# Configure box over SSH
./tool/stream-over-ssh.sh $VM_SSH "$(cat <<EOF
echo "$VM_NAME" | sudo tee /etc/hostname &>/dev/null
if ! grep -q " $VM_NAME" /etc/hosts; then
	echo "127.0.0.1 $VM_NAME" | sudo tee -a /etc/hosts &>/dev/null
fi
sudo reboot
EOF
)"
