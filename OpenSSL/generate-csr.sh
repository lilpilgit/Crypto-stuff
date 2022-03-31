openssl req -new -newkey rsa:2048 -nodes -sha256 -keyout example.key -subj "/C=US/ST=CA/O=Organization/OU=Department/CN=example" -config <(
cat <<-EOF
[req]
default_bits = 2048
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = example.com
DNS.2 = www.example.com
EOF
)
