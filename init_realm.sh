#!/bin/bash

BASE_URL="https://localhost:8443/auth/realms"

TOKEN=$(curl --silent --location \
  --request POST "$BASE_URL/master/protocol/openid-connect/token" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "username=admin" \
  --data-urlencode "password=admin" \
  --data-urlencode "client_id=admin-cli" \
  --data-urlencode "grant_type=password" \
  --cacert ca/ca.crt.pem \
  | jq '.access_token' | tr -d '"')

NBREALMS=$(curl --silent --location \
  --cacert ca/ca.crt.pem \
  --request GET "https://localhost:8443/auth/admin/realms/" \
  --header "Authorization: Bearer $TOKEN" | jq '.|length')

if [[ $NBREALMS -eq 1 ]]; then
  curl -i --silent --location \
    --cacert ca/ca.crt.pem \
    --request POST "https://localhost:8443/auth/admin/realms/" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $TOKEN" \
    -d "$(cat realm_internal.json)"
else
  echo 'Already imported.'
fi
