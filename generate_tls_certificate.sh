#!/bin/bash

rsa_key_size=4096
data_path="./certbot"

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

if [ -d "$data_path/conf/live/$domain" ]; then
  read -p "Existing data found for $domain. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  else
    rm -Rf $data_path/conf/live/$domain
    check_last_cmd_return_code "Removing old $domain certificate failed."
  fi
fi

echo -e "\033[0;34m>>>\033[0m Generating TLS certificate for $domain"
mkdir -p "$data_path/conf/live/$domain"
mkdir dummy && cd dummy
docker run -it --rm -p 443:443 -p 80:80 --name certbot -v `pwd`:/etc/letsencrypt quay.io/letsencrypt/letsencrypt:latest certonly
check_last_cmd_return_code "certbot certonly failed to generate certificate"

echo -e "\033[0;34m>>>\033[0m Purging useless files ..."
cd ..
cat dummy/live/$domain/fullchain.pem > "$data_path/conf/live/$domain/fullchain.pem"
cat dummy/live/$domain/privkey.pem > "$data_path/conf/live/$domain/privkey.pem"
chmod 644 "$data_path/conf/live/$domain/fullchain/pem" "$data_path/conf/live/$domain/privkey/pem"
rm -rf dummy

echo -e "\033[0;34m>>>\033[0m Starting nginx ..."
docker run --network host --name nginx \
  -v `pwd`/nginx:/etc/nginx/conf.d \
  -v `pwd`/certbot/conf:/etc/letsencrypt \
  --detach --restart always nginx:1.15-alpine
