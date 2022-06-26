#!/bin/sh

# --- helper functions for logs ---
info()
{
    echo 'start-k3s.sh-[INFO] ' "$@"
}
warn()
{
    echo 'start-k3s.sh-[WARN] ' "$@" >&2
}
fatal()
{
    echo 'start-k3s.sh-[ERROR] ' "$@" >&2
    exit 1
}

INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC"

# If server node then
if [ -z "${K3S_URL}" ]; then
  #disable servicelb if we are using metallb
  if [ "${LB}" = "MetalLB" ]; then
      metallb_flags="--disable servicelb"

      info "Adding default flags \"$metallb_flags\" to INSTALL_K3S_EXEC"
      INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC $metallb_flags"
  fi

  #add datastore endpoint if provided
  if [ -n "${K3S_DATASTORE_ENDPOINT}" ]; then
    ds_flags="--datastore-endpoint=$K3S_DATASTORE_ENDPOINT"

    info "Adding default flags $ds_flags to INSTALL_K3S_EXEC"
    INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC $ds_flags"
  fi
fi

info "INSTALL_K3S_EXEC=$INSTALL_K3S_EXEC"

info "Installing K3s..."
sudo INSTALL_K3S_SKIP_DOWNLOAD="$INSTALL_K3S_SKIP_DOWNLOAD" INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" K3S_TOKEN="$K3S_TOKEN" K3S_URL="$K3S_URL" /home/pocuser/installer.sh
info "K3s installation done"

if [ -z "${K3S_URL}" ]; then
  if [ "${LB}" = "MetalLB" ]; then
    info "Installing MetalLB..."
    metallb_config_path="/home/pocuser/metallb-config.yaml" #default path
    if [ -z "${LB_CONFIG}" ]; then
      metallb_config_path="$LB_CONFIG"
    fi
    metallb_version="v0.10.2"

    if [ -z "${LB_IP_RANGE}" ]; then
      prefix_ip=$(hostname -I | awk '{print $1}' | cut -d"." -f1-3)
      LB_IP_RANGE="$prefix_ip".150-"$prefix_ip".250
    fi

    sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/"$metallb_version"/manifests/namespace.yaml
    sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/"$metallb_version"/manifests/metallb.yaml

    echo "      - $LB_IP_RANGE" >> "$metallb_config_path"
    sudo kubectl apply -f "$metallb_config_path"
    info "MetalLB Installation done"
  fi

  if [ "${INSTALL_TILLER}" = "true" ]; then
    info "Installing Tiller..."
    UPDATED_KUBECONFIG_PATH=/home/pocuser/kubeconfig
    sudo kubectl config view --raw > "$UPDATED_KUBECONFIG_PATH"
    export KUBECONFIG="$UPDATED_KUBECONFIG_PATH"

    kubectl -n kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
    info "Tiller Installation done"
  fi

fi