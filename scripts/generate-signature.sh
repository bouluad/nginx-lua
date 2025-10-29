#!/usr/bin/env bash
# usage: ./generate-signature.sh <secret> '<payload-json>'
secret="$1"
payload="$2"

sig=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$secret" -binary | xxd -ps -c 256)
printf "sha256=%s\n" "$sig"
