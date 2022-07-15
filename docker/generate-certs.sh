#!/bin/bash
# Generate certificates for OpenSearch cluster

CERT_DN="/C=KO/ST=JUNGU/L=SEOUL/O=ORG/OU=UNIT"
EXPIRE_DAYS=365
SUBJECT_ALT_NAMES="DNS:localhost,IP:127.0.0.1"

mkdir -p certs/{ca,os-dashboard}

# ROOT CA
openssl genrsa -out certs/ca/ca.key 2048
openssl req -new -x509 -sha256 -days $EXPIRE_DAYS -subj "$CERT_DN/CN=ROOT" -key certs/ca/ca.key -out certs/ca/ca.pem

# Admin
openssl genrsa -out certs/ca/admin-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/ca/admin-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/ca/admin.key
openssl req -new -subj "$CERT_DN/CN=ADMIN" -key certs/ca/admin.key -out certs/ca/admin.csr
openssl x509 -req -in certs/ca/admin.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/ca/admin.pem -extfile <(printf "subjectAltName=$SUBJECT_ALT_NAMES")

# Opensearch Dashboard
openssl genrsa -out certs/os-dashboard/os-dashboard-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/os-dashboard/os-dashboard-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/os-dashboard/os-dashboard.key
openssl req -new -subj "$OPENDISTRO_DN/CN=DASHBOARD" -key certs/os-dashboard/os-dashboard.key -out certs/os-dashboard/os-dashboard.csr
openssl x509 -req -in certs/os-dashboards/os-dashboards.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/os-dashboard/os-dashboard.pem -extfile <(printf "subjectAltName=$SUBJECT_ALT_NAMES")


# Nodes
for NODE_NAME in "os01" "os02"
do
    mkdir "certs/${NODE_NAME}"
    openssl genrsa -out "certs/$NODE_NAME/$NODE_NAME-temp.key" 2048
    openssl pkcs8 -inform PEM -outform PEM -in "certs/$NODE_NAME/$NODE_NAME-temp.key" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "certs/$NODE_NAME/$NODE_NAME.key"
    openssl req -new -subj "$OPENDISTRO_DN/CN=$NODE_NAME" -key "certs/$NODE_NAME/$NODE_NAME.key" -out "certs/$NODE_NAME/$NODE_NAME.csr"
    openssl x509 -req -in "certs/$NODE_NAME/$NODE_NAME.csr" -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out "certs/$NODE_NAME/$NODE_NAME.pem"  -extfile <(printf "subjectAltName=$SUBJECT_ALT_NAMES")

done

# cleanup

rm certs/os-dashboard/os-dashboard-temp.key certs/os-dashboard/os-dashboard.csr