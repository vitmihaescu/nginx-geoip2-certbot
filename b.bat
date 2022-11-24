@REM docker stop vit.nginx
@REM docker rm vit.nginx
docker build -t vitmihaescu/nginx-geoip2-certbot:latest .
docker tag vitmihaescu/nginx-geoip2-certbot:latest vitmihaescu/nginx-geoip2-certbot:1.23.2-alpine
@REM docker push vitmihaescu/nginx-geoip2-certbot
@REM docker push vitmihaescu/nginx-geoip2-certbot:1.23.2-alpine
