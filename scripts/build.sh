#!/bin/bash

CMD=`realpath $0`
SCRIPTS_DIR=`dirname $CMD`
TOP_DIR=$(realpath $SCRIPTS_DIR/..)
echo "TOP DIR = $TOP_DIR"
BOARDS_DIR=$TOP_DIR/boards
TARGET_IMAGE=$1
BUILD_DIR=$TOP_DIR/build
TARGER_IMAGE_LIST=$BUILD_DIR/target-image-list
[ ! -d "$BUILD_DIR" ] && mkdir -p $BUILD_DIR/overlays $BUILD_DIR/recipes $BUILD_DIR/scripts

touch $TARGER_IMAGE_LIST
for board in `ls $BOARDS_DIR`
do
    cd $BOARDS_DIR/$board
    for image in `ls $board*.list`
    do
        echo $image | cut -d '.' -f1 >> $TARGER_IMAGE_LIST
    done
done

cleanup() {
    rm -rf $TARGER_IMAGE_LIST
    rm -rf $BUILD_DIR
}
trap cleanup EXIT

usage() {
    echo "====USAGE: build.sh [image]===="
    echo "image:"
    cat $TARGER_IMAGE_LIST
}

found=0
for image in `cat $TARGER_IMAGE_LIST`
do
    if [ "$TARGET_IMAGE" == "$image" ] ; then
        found=1
        break
    else
        continue
    fi
done
if [[ "$found" == "0" ]]; then
    usage
    exit
fi

export CPU=$(echo "$TARGET_IMAGE" | cut -d '-' -f1)
export BOARD=$(echo "$TARGET_IMAGE" | cut -d '-' -f2)
export MODEL=$(echo "$TARGET_IMAGE" | cut -d '-' -f3)
export DISTRO=$(echo "$TARGET_IMAGE" | cut -d '-' -f4)
export VARIANT=$(echo "$TARGET_IMAGE" | cut -d '-' -f5)
export ARCH=$(echo "$TARGET_IMAGE" | cut -d '-' -f6)

build_board() {
    echo "====Start to build $SUBBOARD board system image===="
    $SCRIPTS_DIR/debos-target-board.sh -c $CPU -b $BOARD -m $MODEL -d $DISTRO -v $VARIANT -a $ARCH
    $SCRIPTS_DIR/compress-system-image.sh -c $CPU -b $BOARD -m $MODEL -d $DISTRO -v $VARIANT -a $ARCH
    echo "====Building $SUBBOARD board system image is done===="
}

clean_system_images() {
    echo "====Start to clean system images===="
    $SCRIPTS_DIR/clean-system-images.sh
    echo "====Cleaning system images is done===="
}

build_board
clean_system_images
