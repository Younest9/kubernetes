#!/bin/bash
# Rotate TLS secrets in non-system namespaces from a local cert directory.
# Expect generic basenames (example_com.key / example_com.pem, etc.).

List_namespaces=$(kubectl get namespaces | cut -d " " -f 1 | grep -v -e "NAME" -e "kube-public" -e "kube-system" -e "metallb-system" -e "traefik" -e "cattle-fleet-system" -e "cattle-impersonation-system" -e "cattle-system" -e "kube-node-lease" -e "local" -e cert-manager -e "default")

example_com="example_com"
lab_example_com="lab_example_com"
www_example_com="www_example_com"
api_example_com="api_example_com"
docs_example_com="docs_example_com"
app_example_com="app_example_com"
portal_example_com="portal_example_com"
mail_example_com="mail_example_com"
cdn_example_com="cdn_example_com"

basenames=(
  "$example_com"
  "$lab_example_com"
  "$www_example_com"
  "$api_example_com"
  "$docs_example_com"
  "$app_example_com"
  "$portal_example_com"
  "$mail_example_com"
  "$cdn_example_com"
)

while true; do
    read -r -p "In which directory are the certificates : " dir
    if [[ -d "$dir" ]]; then
        missing=0
        for base in "${basenames[@]}"; do
            if [[ ! -f "$dir/$base.key" || ! -f "$dir/$base.pem" ]]; then
                missing=1
                break
            fi
        done
        if [[ $missing -eq 0 ]]; then
            break
        fi
    fi
    sleep 1
    echo "Wrong directory, or you don't have the files in the directory you specified"
    echo ""
done

for line in $List_namespaces
do
    echo ""
    echo "Update Certificates in namespaces: $line : starting ..."
    echo ""
    echo "Deleting old certificates..."
    kubectl delete secret example-com-cert -n "$line" 2>/dev/null
    kubectl delete secret lab-example-com-cert -n "$line" 2>/dev/null
    kubectl delete secret www-example-com -n "$line" 2>/dev/null
    kubectl delete secret api-example-com -n "$line" 2>/dev/null
    kubectl delete secret docs-example-com -n "$line" 2>/dev/null
    kubectl delete secret app-example-com -n "$line" 2>/dev/null
    kubectl delete secret portal-example-com -n "$line" 2>/dev/null
    kubectl delete secret mail-example-com -n "$line" 2>/dev/null
    kubectl delete secret cdn-example-com -n "$line" 2>/dev/null
    sleep 2
    echo ""
    echo "Creating new ones from the files in the directory: $dir"
    echo ""
    kubectl create secret tls example-com-cert -n "$line" --key="$dir/$example_com.key" --cert="$dir/$example_com.pem" 2>/dev/null
    kubectl create secret tls lab-example-com-cert -n "$line" --key="$dir/$lab_example_com.key" --cert="$dir/$lab_example_com.pem" 2>/dev/null
    kubectl create secret tls www-example-com -n "$line" --key="$dir/$www_example_com.key" --cert="$dir/$www_example_com.pem" 2>/dev/null
    kubectl create secret tls api-example-com -n "$line" --key="$dir/$api_example_com.key" --cert="$dir/$api_example_com.pem" 2>/dev/null
    kubectl create secret tls docs-example-com -n "$line" --key="$dir/$docs_example_com.key" --cert="$dir/$docs_example_com.pem" 2>/dev/null
    kubectl create secret tls app-example-com -n "$line" --key="$dir/$app_example_com.key" --cert="$dir/$app_example_com.pem" 2>/dev/null
    kubectl create secret tls portal-example-com -n "$line" --key="$dir/$portal_example_com.key" --cert="$dir/$portal_example_com.pem" 2>/dev/null
    kubectl create secret tls mail-example-com -n "$line" --key="$dir/$mail_example_com.key" --cert="$dir/$mail_example_com.pem" 2>/dev/null
    kubectl create secret tls cdn-example-com -n "$line" --key="$dir/$cdn_example_com.key" --cert="$dir/$cdn_example_com.pem" 2>/dev/null
    sleep 2
    echo "Update certificates in namespace $line : Completed"
done
echo ""
echo "All certificates are updated"
