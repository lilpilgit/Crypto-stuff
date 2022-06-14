#!/bin/sh

export FQDN_1="" # <<<<<< TO COMPILE
export FQDN_2="" # <<<<<< TO COMPILE
export KEY_PATH="./ss-certs/server.key"
export CERT_PATH="./ss-certs/server-cert.crt"
export REQ_PATH="./ss-certs/server-cert.req"
export CSR_PATH="./ss-certs/server.csr"
export CA_CERT_PATH="./ss-certs/ca-cert.crt"
export CA_KEY_PATH="./ss-certs/ca-key.crt"
export DECRYPTED_KEY_PATH="./ss-certs/tls-key-decrypted.key"


mkdir ss-certs #create directory with all certificates if doesn't exist

printf "\n\n[+] Generate the private key of the root CA and self-signed root CA certificate"
openssl genrsa -out ${CA_KEY_PATH} 2048
openssl req -x509 -sha256 -new -nodes -days 3650 -key ${CA_KEY_PATH} \
        -subj "/C=IT/ST=Italy/O=FAKECA/CN=fakeca.it" \
		-out ${CA_CERT_PATH}
sleep 5

printf "\n\n [+] Review the CA certificate"
openssl x509 -in ${CA_CERT_PATH} -text
sleep 5

printf "\n\n\ [+] Generate the private key of server \n\n"
openssl genrsa -out ${KEY_PATH} 2048
sleep 5

printf "\n\n [+] Creation of OpenSSL request configuration file ${REQ_PATH}"
cat <<EOF >> ${REQ_PATH}
[req]
prompt = no
distinguished_name = dn
req_extensions = v3_req
[dn]
CN = ${FQDN_1}
C = IT
L = Milano
O = Fake Snam
OU = IoT
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${FQDN_1}
DNS.2 = ${FQDN_2}
EOF
sleep 5


printf "\n\n [+] Create the server certificate signing request (CSR) file:"
openssl req -new -key ${KEY_PATH} -out ${CSR_PATH} -config ${REQ_PATH}
sleep 5

printf "\n\n [+] Review the server certificate signing request (CSR) file:"
openssl req -in ${CSR_PATH} -noout -text
sleep 5

#The SAN Extensions will missing from our certificate.
#This is an expected behaviour. As per official documentation from openssl
#Extensions in certificates are not transferred to certificate requests and vice versa.
#Due to this, the extensions which we added in our CSR were not transferred by default to the certificate. So these extensions must be added to the certificate explicitly.

printf "\n\n [+] Generate the server certificate signed by CA:"	
openssl x509 -req -days 3650 -in ${CSR_PATH} -out ${CERT_PATH} -CA ${CA_CERT_PATH} -CAkey ${CA_KEY_PATH} -CAcreateserial -extensions v3_req -extfile ${REQ_PATH}
sleep 5

printf "\n\n [+] Review the server certificate:"	
openssl x509 -in ${CERT_PATH} -text -noout


