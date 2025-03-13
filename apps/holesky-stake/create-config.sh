#!/usr/bin/env bash
set -e -x

mkdir -p ./config/certs

cd ./config/certs

echo "create authority"
if [ ! -f dirk_authority.key ]; then
  openssl genrsa -des3 -out dirk_authority.key 4096
fi
if [ ! -f dirk_authority.crt ]; then
  openssl req -x509 -new -nodes -key dirk_authority.key -sha256 -days 1825 -out dirk_authority.crt
fi

echo "create dirk certs"
for i in {0..0}; do
  if [ -f dirk$i.crt ]; then
      continue
  fi
  cat << EOF >dirk$i.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = dirk$i
EOF
	openssl genrsa -out dirk$i.key 4096
  openssl req -out dirk$i.csr -key dirk$i.key -new -subj "/CN=dirk$i" -addext "subjectAltName=DNS:dirk$i"
	openssl x509 -req -in dirk$i.csr -CA dirk_authority.crt -CAkey dirk_authority.key -CAcreateserial -out dirk$i.crt -days 1825 -sha256 -extfile dirk$i.ext
	openssl x509 -in dirk$i.crt -text -noout
done

echo "create vouch certs"
for i in {0..0}; do
  if [ -f vouch$i.crt ]; then
      continue
  fi
  cat << EOF >vouch$i.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = vouch$i
EOF
  openssl genrsa -out vouch$i.key 4096
	openssl req -out vouch$i.csr -key vouch$i.key -new -subj "/CN=vouch$i"
	openssl x509 -req -in vouch$i.csr -CA dirk_authority.crt -CAkey dirk_authority.key -CAcreateserial -out vouch$i.crt -days 1825 -sha256 -extfile vouch$i.ext
	openssl x509 -in vouch$i.crt -text -noout
done

cd ../

echo "wallet passphrase"
if [ ! -f wallet_passphrase ]; then
  openssl rand -base64 32 > wallet_passphrase.txt
fi

echo "account passphrase"
if [ ! -f account_passphrase ]; then
  openssl rand -base64 32 > account_passphrase.txt
fi

echo "done"