#! /bin/sh
info()
{
    echo 'generate_kubeconfig.sh-[INFO] ' "$@"
}
warn()
{
    echo 'generate_kubeconfig.sh-[WARN] ' "$@" >&2
}
fatal()
{
    echo 'generate_kubeconfig.sh-[ERROR] ' "$@" >&2
    exit 1
}


user_name="$(cat /etc/hostname)"
eve_service_user_file_path="$HOME/eve-service-user-$user_name.yaml"
eve_kubeconfig_path="$1"

info "Generating k3s namespace, role and service account config at $eve_service_user_file_path for user $user_name"
cat <<EOT > "$eve_service_user_file_path"
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: $user_name-admin
  labels:
    cattle.io/creator: "norman"
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'

---

apiVersion: v1
kind: Namespace
metadata:
  name: $user_name

---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: $user_name
  namespace: $user_name

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $user_name-binding
  namespace: $user_name
  labels:
    cattle.io/creator: "norman"
subjects:
- kind: ServiceAccount
  name: $user_name
  namespace: $user_name
roleRef:
  kind: ClusterRole
  name: $user_name-admin
  apiGroup: rbac.authorization.k8s.io

EOT

info "Creating k3s namespace, role and service account for $user_name"
sudo kubectl create -f "$eve_service_user_file_path" || fatal "Failed to create namespace, role and service account"

secret_token_name=$( (sudo kubectl describe serviceAccounts -n "$user_name" "$user_name" || fatal "Failed to get service account $user_name") | grep -o '\bMountable secrets:[^\\]*' | cut -d : -f 2 | tr -d '[:space:]')
token=$( (sudo kubectl describe secrets -n "$user_name" "$secret_token_name" || fatal "Failed to get service account $user_name token") | grep -o '\btoken:[^\\]*' |  cut -d : -f 2 | tr -d '[:space:]')
certificate_authority_data=$( (sudo kubectl config -n "$user_name" view --flatten --minify  || fatal "Failed to get cluster config") | grep -o '\bcertificate-authority-data:[^\\]*' |  cut -d : -f 2 | tr -d '[:space:]')
server="https://$(hostname -I | cut -d' ' -f1):6443"

info "Generating kubeconfig at $eve_kubeconfig_path"

cat <<EOT > "$eve_kubeconfig_path"
{
    "kind": "Config",
    "apiVersion": "v1",
    "preferences": {},
    "clusters": [
        {
            "name": "$user_name",
            "cluster": {
                "server": "$server",
                "certificate-authority-data": "$certificate_authority_data"
            }
        }
    ],
    "users": [
        {
            "name": "$user_name",
            "user": {
                "token": "$token"
            }
        }
    ],
    "contexts": [
        {
            "name": "$user_name",
            "context": {
                "cluster": "$user_name",
                "user": "$user_name"
            }
        }
    ],
    "current-context": "$user_name"
}
EOT

KUBECONFIG="$eve_kubeconfig_path" sudo kubectl get nodes || fatal "Unable to use kubeconfig $eve_kubeconfig_path file for kubectl operations"