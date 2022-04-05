#!/bin/sh

export FQDN_1=""
export FQDN_2=""

printf "\n\n[+] Generate the private key of the root CA and self-signed root CA certificate"
openssl genrsa -out rootCA.key 2048
openssl req -x509 -sha256 -new -nodes -days 3650 -key rootCA.key \
        -subj "/C=IT/ST=Italy/O=FAKECA/CN=fakeca.it" \
		-out rootCA.crt
sleep 5

printf "\n\n [+] Review the CA certificate"
openssl x509 -in rootCA.crt -text
sleep 5

printf "\n\n\ [+] Generate the private key of server \n\n"
openssl genrsa -out server.key 2048
sleep 5

printf "\n\n [+] Creation of OpenSSL request configuration file server-cert.req"
cat <<EOF >> server-cert.req
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
openssl req -new -key server.key -out server.csr -config server-cert.req
sleep 5

printf "\n\n [+] Review the server certificate signing request (CSR) file:"
openssl req -in server.csr -noout -text
sleep 5

#The SAN Extensions will missing from our certificate.
#This is an expected behaviour. As per official documentation from openssl
#Extensions in certificates are not transferred to certificate requests and vice versa.
#Due to this, the extensions which we added in our CSR were not transferred by default to the certificate. So these extensions must be added to the certificate explicitly.

printf "\n\n [+] Generate the server certificate signed by CA:"	
openssl x509 -req -days 3650 -in server.csr -out server.crt -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -extensions v3_req -extfile server-cert.req
sleep 5

printf "\n\n [+] Review the server certificate:"	
openssl x509 -in server.crt -text -noout


