#!/bin/bash

CMD=`realpath $0`
SCRIPTS_DIR=`dirname $CMD`
TOP_DIR=$(realpath $SCRIPTS_DIR/..)
echo "TOP DIR = $TOP_DIR"

OUTPUT_DIR=$TOP_DIR/output
[[ ! -d "$TOP_DIR/output" ]] && mkdir -p $TOP_DIR/output

usage() {
    echo "====USAGE: compress-system-image.sh -c <cboard> -s <subboard> -m <model> -d <distro> -a <arch> -v <variant>===="
    echo "compress-system-image.sh -c px30 -b rockpropx30 -m debian -d buster -a arm64 -v xfce4"
}

while getopts "c:b:m:d:a:v:h" flag; do
    case $flag in
	    c)
	        CPU="$OPTARG"
	        ;;
	    b)
	        BOARD="$OPTARG"
	        ;;
		m)
	        MODEL="$OPTARG"
	        ;;
	    d)
	        DISTRO="$OPTARG"
	        ;;
	    a)
	        ARCH="$OPTARG"
            ;;
        v)
            VARIANT="$OPTARG"
	        ;;
        esac
done

if [ ! $CPU ] && [ ! $BOARD ] && [ ! $MODEL ] && [ ! $DISTRO ] && [ ! $ARCH ] && [ ! $VARIANT ]; then
    usage
    exit
fi

cd $OUTPUT_DIR
if [[ -e "system.img" ]]; then
    TIME=$(date +%Y%m%d_%H%M)
    mv "system.img" "${BOARD}_${MODEL}_${DISTRO}_${VARIANT}_${ARCH}_${TIME}-gpt.img"
    md5sum "${BOARD}_${MODEL}_${DISTRO}_${VARIANT}_${ARCH}_${TIME}-gpt.img" > "${BOARD}_${MODEL}_${DISTRO}_${VARIANT}_${ARCH}_${TIME}-gpt.img.md5.txt"
    bmaptool create "${BOARD}_${MODEL}_${DISTRO}_${VARIANT}_${ARCH}_${TIME}-gpt.img" > "${BOARD}_${MODEL}_${DISTRO}_${VARIANT}_${ARCH}_${TIME}-gpt.img.bmap"
    gzip -f "${BOARD}_${MODEL}_${DISTRO}_${VARIANT}_${ARCH}_${TIME}-gpt.img"
fi

echo -e  "\e[36m System image ${BOARD}_${MODEL}_${DISTRO}_${VARIANT}_${ARCH}_${TIME}-gpt.img is generated. See it in $OUTPUT_DIR \e[0m"
cd -
