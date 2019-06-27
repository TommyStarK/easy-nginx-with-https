# easy_nginx
Nginx+certbot : easy script to generate ssl certificate for a dns and run nginx in a container to reverse proxy a webapp over https

# Usage

```
$ ./generate_tls.certificate.sh
```

## Disclaimer

To use this tool, you must have a valid DNS pointing to a machine to which you must have access.
You must run the script on the machine in question so that certbot can start a web server, inject a token to validate that your DNS is valid.
