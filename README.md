# easy_nginx
Nginx+certbot : easy script to generate ssl certificate for a dns and run nginx in a container to reverse proxy a webapp over https

# Usage

```
$ ./generate_tls.certificate.sh
```

## Disclaimer

To use this tool, you must have a valid DNS pointing to a machine to which you must have access.
Run the script on the machine in question so that certbot can start a web server, inject a token to ensure that your DNS is valid.
