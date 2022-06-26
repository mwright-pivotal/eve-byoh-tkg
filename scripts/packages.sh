DEV_PACKAGES="
build-essential
curl
git
net-tools
vim
cloud-init
libprotobuf-dev
libssl-dev
libcurl4-openssl-dev
uuid-dev
libprotoc-dev
"
sudo apt update
sudo apt-get -y install $DEV_PACKAGES
sudo apt-get update
