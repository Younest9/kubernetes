#!/bin/bash


List_namespaces=$(kubectl get namespaces | cut -d " " -f 1 | grep -v -e "NAME" -e "kube-public" -e "kube-system" -e "metallb-system" -e "traefik" -e "cattle-fleet-system" -e "cattle-impersonation-system" -e "cattle-system" -e "kube-node-lease" -e "local" -e cert-manager -e "default")
Length_list=$(kubectl get namespaces | cut -d " " -f 1 | grep -v -e "NAME" -e "kube-public" -e "kube-system" -e "metallb-system" -e "traefik" -e "cattle-fleet-system" -e "cattle-impersonation-system" -e "cattle-system" -e "kube-node-lease" -e "local" -e cert-manager -e "default" | wc -l)

imbe_fr="imbe_fr"
cerege_fr="cerege_fr"
dt_insu_cnrs_fr="dt_insu_cnrs_fr"
igsn_cnrs_fr="igsn_cnrs_fr"
lam_fr="lam_fr"
lped_fr="lped_fr"
mio_osupytheas_fr="mio_osupytheas_fr"
mio_univ_amu_fr="mio_univ-amu_fr"
obs_hp_fr="obs-hp_fr"
osupytheas_fr="osupytheas_fr"
declare -a files=(imbe_fr, cerege_fr, dt_insu_cnrs_fr, lam_fr, lped_fr, mio_osupytheas_fr, mio_univ_amu_fr, obs_hp_fr, osupytheas_fr)
while true; do
    read -p "In which directory are the certificates : " dir
    if  ; then
        sleep 1
        echo "Wrong directory, or you don't have the files in the directory you specified"
        echo ""
        continue
    fi
done
#echo "it worked"
#exit 1
for line in $List_namespaces
do
    echo ""
    echo "Update Certificates in namespaces: $line : starting ..."
    echo ""
    echo "Deleting old certificates..."
    kubectl delete secret imbe-fr-cert -n $line 2>/dev/null 2>&1
    kubectl delete secret cerege-fr-cert -n $line 2>/dev/null 2>&1
    kubectl delete secret dt-insu-cnrs-fr -n $line 2>/dev/null 2>&1
    #kubectl delete secret igsn-cnrs-fr -n $line 2>/dev/null 2>&1
    kubectl delete secret lam-fr -n $line 2>/dev/null 2>&1
    kubectl delete secret lped-fr -n $line 2>/dev/null 2>&1
    kubectl delete secret mio-osupytheas-fr -n $line 2>/dev/null 2>&1
    kubectl delete secret mio-univ-amu-fr -n $line 2>/dev/null 2>&1
    kubectl delete secret obs-hp-fr -n $line 2>/dev/null 2>&1
    kubectl delete secret osupytheas-fr -n $line 1>/dev/null  2>&1
    sleep 2
    echo ""
    echo "Creating new ones from the files in the directory: $dir"
    echo ""
    kubectl create secret tls imbe-fr-cert -n $line --key="$dir/$imbe_fr.key" --cert "$dir/$imbe_fr.pem"  2>/dev/null 2>&1
    kubectl create secret tls cerege-fr-cert -n $line --key="$dir/$cerege_fr.key" --cert "$dir/$cerege_fr.pem" 2>/dev/null 2>&1
    kubectl create secret tls dt-insu-cnrs-fr -n $line --key="$dir/$dt_insu_cnrs_fr.key" --cert "$dir/$dt_insu_cnrs_fr.pem" 2>/dev/null 2>&1
    #kubectl create secret tls igsn-cnrs-fr -n $line --key="$dir/$igsn_cnrs_fr.key" --cert "$dir/$igsn_cnrs_fr.pem" 2>/dev/null 2>&1
    kubectl create secret tls lam-fr -n $line --key="$dir/$lam_fr.key" --cert "$dir/$lam_fr.pem" 2>/dev/null 2>&1
    kubectl create secret tls lped-fr -n $line --key="$dir/$lped_fr.key" --cert "$dir/$lped_fr.pem" 2>/dev/null 2>&1
    kubectl create secret tls mio-osupytheas-fr -n $line --key="$dir/$mio_osupytheas_fr.key" --cert "$dir/$mio_osupytheas_fr.pem" 2>/dev/null 2>&1
    kubectl create secret tls mio-univ-amu-fr -n $line --key="$dir/$mio_univ_amu_fr.key" --cert "$dir/$mio_univ_amu_fr.pem" 2>/dev/null 2>&1
    kubectl create secret tls obs-hp-fr -n $line --key="$dir/$obs_hp_fr.key" --cert "$dir/$obs_hp_fr.pem" 2>/dev/null 2>&1
    kubectl create secret tls osupytheas-fr -n $line --key="$dir/$osupytheas_fr.key" --cert "$dir/$osupytheas_fr.pem" 2>/dev/null 2>&1
    sleep 2
    echo "Update certificates in namespace $line : Completed"
done
echo ""
echo "All certificates are updated"
