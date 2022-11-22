docker stop vit.nginx
docker rm vit.nginx
docker build -t vitmihaescu/nginx-geoip2-certbot:1.23.2-alpine .