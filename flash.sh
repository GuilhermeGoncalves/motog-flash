#! /bin/bash
# License: GNU GENERAL PUBLIC LICENSE v3
# Author: Guilherme Goncalves, 2016
# Please send feedback to inacio.guilherme@gmail.com

usage() {
  echo "Usage: flash.sh -f <fastboot-path> -r <rom-path> [OPTION]"
  echo ""
  echo "OPTIONS:"
  echo "-b                        relock bootloader"
  exit 1
}

flash() {
  local path="$1"
  local rom="$2"
  local relock="$3"

  cd $rom

  if [ $relock ]; then
    $path/fastboot oem lock begin
  fi
  $path/fastboot reboot-bootloader
  $path/fastboot flash partition gpt.bin
  $path/fastboot flash motoboot motoboot.img
  $path/fastboot flash logo logo.bin
  $path/fastboot flash boot boot.img
  $path/fastboot flash recovery recovery.img
  $path/fastboot flash system system.img_sparsechunk.0
  $path/fastboot flash system system.img_sparsechunk.1
  $path/fastboot flash system system.img_sparsechunk.2
  $path/fastboot flash modem NON-HLOS.bin
  $path/fastboot erase modemst1
  $path/fastboot erase modemst2
  $path/fastboot flash fsg fsg.mbn
  $path/fastboot erase cache
  $path/fastboot erase userdata

  if [ $relock ]; then
    $path/fastboot oem lock
  fi

  $path/fastboot reboot
  exit 0
}

while getopts "bf:r:" OPTION
do
  case $OPTION in
    b) RELOCK_BOOTLOADER=1 ;;
    f) FASTBOOT_PATH=$OPTARG ;;
    r) ROM_PATH=$OPTARG ;;
    ?) usage ;;
   esac
done
shift $((OPTIND-1))

if [ -d "$FASTBOOT_PATH" ] && [ -d "$ROM_PATH" ]; then
  flash $FASTBOOT_PATH $ROM_PATH $RELOCK_BOOTLOADER
else
  usage
fi
