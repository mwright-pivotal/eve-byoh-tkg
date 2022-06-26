#!/bin/bash

k3s_version='v1.20.4+k3s1'
k3s_install_bin_dir="/zed/data1/bin"
BIN_DIR=/usr/local/bin

helm_version="v2.17.0"
helm_tar_file_name="helm-$helm_version-linux-amd64.tar.gz"
helm_install_bin_dir="/zed/data1/bin"
TMP_DIR=$(mktemp -d -t helm-install.XXXXXXXXXX)

mkdir -p "$k3s_install_bin_dir"

sudo wget https://github.com/rancher/k3s/releases/download/"${k3s_version}"/k3s -P "$k3s_install_bin_dir"
sudo chmod 755 "${k3s_install_bin_dir}"/k3s
sudo chown root:root "${k3s_install_bin_dir}"/k3s

ln -s "${k3s_install_bin_dir}"/k3s "${BIN_DIR}"/k3s



sudo wget https://get.helm.sh/"$helm_tar_file_name" -P "$TMP_DIR"
cd "$TMP_DIR" || exit
tar -xvzf "$helm_tar_file_name"
mv linux-amd64/helm "$helm_install_bin_dir"/helm
mv linux-amd64/tiller "$helm_install_bin_dir"/tiller

ln -s "$helm_install_bin_dir"/helm $BIN_DIR/helm
ln -s "$helm_install_bin_dir"/tiller $BIN_DIR/tiller
