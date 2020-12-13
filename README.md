[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

# easy-nginx-with-https
Nginx+certbot : easy script to generate TLS certificate for a DNS and run Nginx in a container to reverse proxy a webapp over HTTPS

## Usage

:warning: Edit the Nginx conf files and docker-compose.yaml to fit to your needs.

To use this tool, you must have a dns pointing to a server to which you have access.
Run this script on that server:

```
❯  ./generate_tls.certificate.sh
```

## Demo

```bash
❯ cd /tmp
❯ git clone https://github.com/TommyStarK/easy-nginx-with-https.git
❯ cd easy-nginx-with-https
❯ mkdir -p certs/dummy.com
❯ cd certs/dummy.com
❯ openssl genrsa -out privkey.pem 4096
❯ openssl req -new -x509 -key privkey.pem -out fullchain.pem -days 360 -subj /CN=dummy.com
❯ cd -
❯ sudo -- sh -c 'echo "\n127.0.0.1 dummy.com\n" >> /etc/hosts'
❯ docker-compose up -d

# then you can go to your web browser or use curl
❯ curl -k -v https://dummy.com
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to dummy.com (127.0.0.1) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-CHACHA20-POLY1305
* ALPN, server accepted to use http/1.1
* Server certificate:
*  subject: CN=dummy.com
*  start date: Aug  5 19:49:10 2020 GMT
*  expire date: Jul 31 19:49:10 2021 GMT
*  issuer: CN=dummy.com
*  SSL certificate verify result: self signed certificate (18), continuing anyway.
> GET / HTTP/1.1
> Host: dummy.com
> User-Agent: curl/7.64.1
> Accept: */*
> Referer:
>
< HTTP/1.1 200 OK
< Server: nginx/1.15.12
< Date: Wed, 05 Aug 2020 20:03:37 GMT
< Transfer-Encoding: chunked
< Connection: keep-alive
<
You have reached service.dummy
* Connection #0 to host dummy.com left intact
* Closing connection 0
```
