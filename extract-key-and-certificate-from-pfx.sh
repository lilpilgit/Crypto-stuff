#!/bin/sh

export PFX_FILE="test.pfx"

printf "\n\n(+) Extracting certificate and private key from pfx file...\n\n"
openssl pkcs12 -in ${PFX_FILE} -nocerts -out tls-key-encrypted.key
openssl rsa -in tls-key-encrypted.key -out tls-key-decrypted.key
openssl pkcs12 -in ${PFX_FILE} -clcerts -nokeys -out cert.pem
