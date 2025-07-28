#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u


OUTDIR=/home/csk2/Output/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git

KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
AARCH64_LIB_DIR=/opt/arm-cross-compile-tool/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib
AARCH64_LIB64_DIR=/opt/arm-cross-compile-tool/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux/arch/${ARCH}/boot/Image ]; then
    cd linux
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
  

    # Configure the kernel
    echo "Configuring the kernel for ${ARCH} architecture"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    echo "Using defconfig for ${ARCH} architecture"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig

    # build the kernel
    echo "Building the kernel for ${ARCH} architecture"
    make -j8 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    make -j8 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make -j8 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
    make -j8 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} Image
    if [ ! -e arch/${ARCH}/boot/Image ]; then
        echo "Kernel Image not found. Build failed."
        exit 1
    fi

    echo "Kernel Image built successfully at arch/${ARCH}/boot/Image"

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux/arch/${ARCH}/boot/Image ${OUTDIR}/Image

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p ${OUTDIR}/rootfs/{bin,dev,etc,home,lib,lib64,proc,sbin,sys,tmp,usr/{bin,sbin},var/log}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "Configuring busybox"
    make distclean
    make defconfig
    echo "Busybox configured successfully"
else
    cd busybox
fi

# TODO: Make and install busybox
echo "Building and installing busybox"
make -j8 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make -j8 CONFIG_PREFIX=${OUTDIR}/rootfs/ ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a ${OUTDIR}/busybox/_install/bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a ${OUTDIR}/busybox/_install/bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "Copying library dependencies to rootfs"
cp -L ${AARCH64_LIB_DIR}/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/
cp -L ${AARCH64_LIB64_DIR}/libc.so.6 ${OUTDIR}/rootfs/lib64/
cp -L ${AARCH64_LIB64_DIR}/libm.so.6 ${OUTDIR}/rootfs/lib64/
cp -L ${AARCH64_LIB64_DIR}/libresolv.so.2 ${OUTDIR}/rootfs/lib64/

# TODO: Make device nodes
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
if [ ! -d "${FINDER_APP_DIR}/writer" ]; then
    echo "Writer directory not found. Exiting."
    exit 1
fi
cd writer
if [ ! -e Makefile ]; then
    echo "Makefile not found in writer directory. Exiting."
    exit 1
fi
make clean
make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH}
if [ ! -e writer ]; then
    echo "Writer utility not built successfully. Exiting."
    exit 1
fi
echo "Writer utility built successfully."

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "Copying finder related scripts and executables to /home directory in rootfs"
mkdir -p ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/writer/writer ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/writer/Makefile ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/writer/writer.c ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/start-qemu-app.sh ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home/
mkdir -p ${OUTDIR}/rootfs/home/conf
cp ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home/conf
cp ${FINDER_APP_DIR}/conf/assignment.txt ${OUTDIR}/rootfs/home/conf


# TODO: Chown the root directory
echo "Setting ownership of root directory to root:root"
sudo chown -R root:root ${OUTDIR}/rootfs
sudo chmod -R 755 ${OUTDIR}/rootfs


# TODO: Create initramfs.cpio.gz
echo "Creating initramfs.cpio.gz"
cd ${OUTDIR}/rootfs
find . | cpio -H newc -o | gzip -9 > ${OUTDIR}/initramfs.cpio.gz
if [ ! -e ${OUTDIR}/initramfs.cpio.gz ]; then
    echo "initramfs.cpio.gz not created. Exiting."
    exit 1
fi
echo "initramfs.cpio.gz created successfully at ${OUTDIR}/initramfs.cpio.gz"