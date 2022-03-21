#!/bin/bash

PASS=azerty

# créer une CA
openssl req -x509 -new -nodes -subj "/CN=cdweb.biz" \
  -keyout ca.key.pem -out ca.crt.pem

# générer et signer un certificat pour keycloak
name=keycloak
openssl req -new -nodes -subj "/CN=localhost" \
  -keyout $name.key.pem -out $name.csr.pem
openssl x509 -req -in $name.csr.pem -out $name.crt.pem \
  -CA ca.crt.pem -CAkey ca.key.pem -CAcreateserial

# générer et signer un certificat pour sample
name=sample
openssl req -new -nodes -subj '/CN=SAMPLE-API' \
  -keyout $name.key.pem -out $name.csr.pem
openssl x509 -req -in $name.csr.pem -out $name.crt.pem \
  -CA ca.crt.pem -CAkey ca.key.pem -CAcreateserial

# rassembler les infos de keycloak dans un fichier au format pkcs12
openssl pkcs12 -export \
  -in keycloak.crt.pem -inkey keycloak.key.pem -certfile keycloak.crt.pem \
  -out keycloak.p12 -passout pass:$PASS

# faire un keystore jks à partir du pkcs12
echo "$PASS" | keytool -importkeystore \
  -srckeystore keycloak.p12 -srcstoretype pkcs12 \
  -destkeystore keystore.jks -deststoretype JKS \
  -keypass azerty -storepass azerty

# créer un truststore pour faire confiance à keycloak et à tout les certif signés par la ca
keytool -importcert -keystore truststore.jks -alias ca -file ca.crt.pem \
  -storepass $PASS -noprompt

# optionnel mais on voit que cette fois le truststore demande pas de faire confiance parceque signé par un certificat existant
keytool -importcert -keystore truststore.jks -storepass $PASS -alias keycloak \
  -file keycloak.crt.pem -noprompt

cp keystore.jks ../configuration
cp truststore.jks ../configuration
