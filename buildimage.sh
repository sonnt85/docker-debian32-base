#!/bin/bash -x
arch=i386
suite=${1:-jessie}
chroot_dir="/var/chroot/$suite"
apt_mirror="http://http.debian.net/debian"
docker_image="sonnt/32bitdebian:$suite"
apt-get install -y docker.io debootstrap dchroot
export DEBIAN_FRONTEND=noninteractive
debootstrap --arch $arch $suite $chroot_dir $apt_mirror
cat <<EOF > $chroot_dir/etc/apt/sources.list
deb $apt_mirror $suite main contrib non-free
deb $apt_mirror $suite-updates main contrib non-free
deb http://security.debian.org/ $suite/updates main contrib non-free
EOF
chroot $chroot_dir apt-get update
chroot $chroot_dir apt-get upgrade -y
chroot $chroot_dir apt-get autoclean
chroot $chroot_dir apt-get clean
chroot $chroot_dir apt-get autoremove
tar cfz debian.tgz -C $chroot_dir .
cat debian.tgz | docker import - $docker_image
docker push $docker_image && rm debian.tgz && rm -rf $chroot_dir