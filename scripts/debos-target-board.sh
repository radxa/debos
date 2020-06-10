#!/bin/bash

CMD=`realpath $0`
SCRIPTS_DIR=`dirname $CMD`
TOP_DIR=$(realpath $SCRIPTS_DIR/..)
echo "TOP DIR = $TOP_DIR"
BUILD_DIR=$TOP_DIR/build
ROOTFS_DIR=$TOP_DIR/rootfs

OUTPUT_DIR=$TOP_DIR/output
[[ ! -d "$TOP_DIR/output" ]] && mkdir -p $TOP_DIR/output
rm -rf $OUTPUT_DIR/*.img

usage() {
    echo "====USAGE: debos-target-board.sh -c <cboard> - b <board> -m <model> -d <distro> -a <arch> -v <variant>===="
    echo "debos-target-board..sh -c px30 -b rockpropx30 -m debian -d buster -a arm64 -v xfce4"
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

prepare_build() {
    echo "====Start to preppare workspace directory, build===="
    TARGET_BOARD_DIR=$TOP_DIR/boards/$CPU
    cp -av $TARGET_BOARD_DIR/overlays $BUILD_DIR
    cp -av $TARGET_BOARD_DIR/packages.list.d/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-packages.list $BUILD_DIR/overlays/packages/preinstall-packages.list
    cp -av $TARGET_BOARD_DIR/*.list $BUILD_DIR
    cp -av $TARGET_BOARD_DIR/*.yaml $BUILD_DIR

    cp -av $ROOTFS_DIR/recipes-*/*.yaml $BUILD_DIR/recipes/
    cp -av $ROOTFS_DIR/scripts/*.sh $BUILD_DIR/scripts/

    echo "/${BOARD}-${MODEL}-${DISTRO}-${ARCH}-${VARIANT}-packages.list"
    cat $TARGET_BOARD_DIR/packages.list.d/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-packages.list

    for pkg in `cat $TARGET_BOARD_DIR/packages.list.d/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-packages.list`
    do
        cp -av `find $ROOTFS_DIR/packages/${ARCH} -name "$pkg"` $BUILD_DIR/overlays/packages/
    done

    cp -av `find $ROOTFS_DIR/packages/${ARCH} -name "*$BOARD*"` $BUILD_DIR/overlays/packages/
    echo "====Preparing workspace directory, build is done===="
}

generate_target_yaml() {
    echo "====Start to generate $BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH yaml===="
    TARGET_YAML=$BUILD_DIR/$BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH.yaml
    touch ${TARGET_YAML}
    TEMP_YAML_DIR=$BUILD_DIR/temp_yaml
    [ ! -d $TEMP_YAML_DIR ] && mkdir $TEMP_YAML_DIR

    for yaml in `cat $BUILD_DIR/$CPU-$BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH.list`
    do
        cp -f $BUILD_DIR/recipes/$yaml $TEMP_YAML_DIR 2>/dev/null
    done

    cd $TEMP_YAML_DIR
    cat $BUILD_DIR/$CPU-$BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH-variable.yaml >> $TARGET_YAML
    for yaml in `ls | sort -n`
    do
        cat $yaml >> $TARGET_YAML
    done
    echo "====$BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH yaml is ready===="
}

debos_system_image() {
    echo "====debos $BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH start===="
    cd $OUTPUT_DIR && debos --print-recipe --show-boot --debug-shell -v $TARGET_YAML
    echo "====debos $BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH end===="
}

prepare_build
generate_target_yaml
debos_system_image
