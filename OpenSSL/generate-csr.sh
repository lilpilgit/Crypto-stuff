openssl req -newkey rsa:2048 -nodes -sha256 -keyout example.key -x509 -days 365 -out example.crt -subj /C=US/ST=CA/O=Organization/OU=Department/CN=example -config <(
cat <<-EOF
[req]
default_bits = 2048
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req
[ dn ]
C = US
ST = VA
L = SomeCity
O = MyCompany
OU = MyDivision
CN = www.company.com
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = example.com
DNS.2 = www.example.com
DNS.3 = company.net
EOF
)
