FROM debian:12

RUN apt update -y && apt upgrade -y

#install nginx
RUN apt install nginx -y

#install openssl (for tls)
RUN apt install openssl -y

#cpy config into container
COPY config/nginx.conf /etc/nginx/nginx.conf

#generate tsl certs, CN=common name of cert, domain name that the certificate is valid for
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/CN=lgottsch.42.fr"

CMD ["nginx", "-g", "daemon off;"]