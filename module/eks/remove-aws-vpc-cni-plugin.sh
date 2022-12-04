#!/bin/bash

#CLUSTER_ENDPOINT
#CLUSTER_CA
#CLUSTER_TOKEN
#REGION

until curl -k -s $CLUSTER_ENDPOINT/healthz >/dev/null; do sleep 4; done

MANIFEST_FILE=`mktemp -t manifest_`
CONFIG_FILE=`mktemp -t config_`
CA_FILE=`mktemp -t ca_`

trap "{ rm -f $MANIFEST_FILE $CONFIG_FILE $CA_FILE; }" EXIT

echo $CLUSTER_CA | base64 -d > $CA_FILE

VERSION=$(kubectl get ds aws-node -n kube-system -o yaml \
  --kubeconfig $CONFIG_FILE \
  --server $CLUSTER_ENDPOINT \
  --certificate-authority $CA_FILE \
  --token "$CLUSTER_TOKEN" \
  | grep -i "image: \d" | grep amazon-k8s-cni: | cut -d "/" -f 2 | cut -d ":" -f 2 | sed -E 's#^v([[:digit:]]+)\.([[:digit:]]+)\..+$#\1.\2#g')

curl -sqL \
  https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-$VERSION/config/master/aws-k8s-cni.yaml \
  | sed -e "s#us-west-2#$REGION#" > $MANIFEST_FILE

kubectl delete \
  --kubeconfig $CONFIG_FILE \
  --server $CLUSTER_ENDPOINT \
  --certificate-authority $CA_FILE \
  --token "$CLUSTER_TOKEN" \
  --filename $MANIFEST_FILE \
  --wait
