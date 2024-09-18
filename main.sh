#!/bin/bash
DEV="/dev/sda"
MNT="/mnt/sda"
DEV_FAT32="${DEV}2"
DEV_EXFAT="${DEV}1"
MNT_FAT32="${MNT}2"
MNT_EXFAT="${MNT}1"

formatting_confirm() {
	reply='N'
	msg="Do you need to format/reformat disk? [y/N]: "
	read -p "$msg" reply
	if [ "$reply" == "y" ]; then
		erase_data
	fi
}
# erase data
erase_data() {
	reply='N'
	warning_msg="WARNING:Erasing disk will take large amount of time & all data in disk will be wiped.
Are you sure to proceed? [y/N]: "
	read -p "$warning_msg" reply
	if [ "$reply" == "y" ]; then
		echo "Start erase $DEV..."
		dd if=/dev/urandom of="$DEV" bs=1M status=progress && sync
	fi
}
# create partition
# making filesystem
create_partition() {
	mkfs.fat -F32 -v -I -n '' "$DEV_FAT32" 
	mkfs.exfat -L '' "$DEV_EXFAT"
}
install-grub() {
	echo "installing at $DEV_FAT32..."
	#fdisk -l "$DEV_FAT32"
	mount "$DEV_FAT32" "$MNT_FAT32"
	mkdir "$MNT_FAT32/boot"
	grub-install --target=x86_64-efi --efi-directory="$MNT_FAT32" --boot-directory="$MNT_FAT32/boot" \
				 --removable "$DEV"
}

# Get UUID of USB Flash with `$ lsblk -f` command:
lsblk -f "$DEV"

#formatting_confirm

uuid_1=$(blkid -s UUID -o value "$DEV_FAT32")
uuid_2=$(blkid -s UUID -o value "$DEV_EXFAT")
echo "fat32 uuid:$uuid_1"
echo "exfat uuid:$uuid_2"

install-grub
