#!/bin/bash

DOMAIN="${1:-app.test}"
NAME="${2:-Application}"
echo "Generating for $DOMAIN, $NAME"

# Generate server keys
openssl genrsa -des3 -passout pass:p4ssw0rd -out server.pass.key 2048
openssl rsa -passin pass:p4ssw0rd -in server.pass.key -out server.key
rm server.pass.key

# Generate CSR
openssl req -new -key server.key -out server.csr \
  -subj "/C=CH/ST=ZH/L=Zuerich/O=$NAME/CN=$DOMAIN"

tee v3.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
EOF

# Generate cert
openssl x509 -req -sha256 \
  -days 365 -extfile v3.ext \
  -in server.csr -signkey server.key -out server.crt

# Links
ln -sf server.crt fullchain.pem
ln -sf server.key privkey.pem

# dhparams
openssl dhparam -out dhparam.pem 2048