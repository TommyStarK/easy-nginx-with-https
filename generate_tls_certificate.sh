#!/bin/bash

rsa_key_size=4096
data_path="./certs"

check_last_cmd_return_code() {
  if [ $? -ne 0 ]; then
    echo -e "[\033[0;31mError\033[0m] $1. Exiting ..."
    exit 1
  fi
}

read -p $'\e[34m>>>\e[0m  Select the domain for which you want to generate certificate: ' domain
if [ -z "$domain" ]; then
    echo -e "[\033[0;31mError\033[0m] No domain provided. Exiting ..."
    exit 1
fi

if [ -d "$data_path/$domain" ]; then
  read -p "Existing data found for $domain. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  else
    rm -Rf $data_path/$domain
    check_last_cmd_return_code "Removing old $domain certificate failed."
  fi
fi

echo -e "\033[0;34m>>>\033[0m Generating TLS certificate for $domain"
mkdir -p "$data_path/$domain"
mkdir -p dummy
docker run -it --rm -p 443:443 -p 80:80 --name certbot -v `pwd`/dummy:/etc/letsencrypt quay.io/letsencrypt/letsencrypt:latest certonly
check_last_cmd_return_code "certbot failed to generate certificate"

echo -e "\033[0;34m>>>\033[0m Purging useless files ..."
cat dummy/live/$domain/fullchain.pem > "$data_path/$domain/fullchain.pem"
cat dummy/live/$domain/privkey.pem > "$data_path/$domain/privkey.pem"
chmod 644 "$data_path/$domain/fullchain.pem" "$data_path/$domain/privkey.pem"
rm -rf dummy

if [[ "$OSTYPE" == "darwin"* ]]; then
  exit
fi

read -p "Run Nginx container in host network mode? (y/N) " decision
if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
  exit
else
  echo -e "\033[0;34m>>>\033[0m Starting nginx ..."
  docker run --network host --name nginx \
    -v `pwd`/certs:/etc/letsencrypt \
    -v `pwd`/nginx/nginx.conf:/etc/nginx/nginx.conf \
    -v `pwd`/nginx/conf.d:/etc/nginx/conf.d \
    -v `pwd`/nginx/ssl:/etc/nginx/ssl \
    --detach --restart always nginx:1.15-alpine
fi
