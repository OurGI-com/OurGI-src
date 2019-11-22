#!/bin/bash

#compile nginx and php: https://gist.github.com/diyism/8dbabfd99fd71abf7758
#build docker image: sudo docker rmi diyism/b4gi ; sudo DOCKER_BUILDKIT=1 docker build -t diyism/b4gi ./

sudo mkdir var var/tmp var/tmp/run var/fastcgi_temp var/proxy_temp var/client_body_temp var/cockroach
sudo chmod 777 var/tmp
sudo chmod 777 var/tmp/run
sudo chmod 777 var/cockroach
sudo touch var/access.nginx.log var/error.nginx.log var/nginx.pid var/nginx.lock var/php-fpm.log
sudo docker -D run \
--read-only \
--rm \
--init \
-it \
\
`#nginx(lua)` \
--mount type=bind,source=$(pwd)/var/access.nginx.log,target=/usr/local/nginx/logs/access.log \
--mount type=bind,source=$(pwd)/var/error.nginx.log,target=/usr/local/nginx/logs/error.log \
--mount type=bind,source=$(pwd)/var/nginx.pid,target=/usr/local/nginx/logs/nginx.pid \
--mount type=bind,source=$(pwd)/var/nginx.lock,target=/usr/local/nginx/logs/nginx.lock \
--mount type=bind,source=$(pwd)/var/client_body_temp,target=/usr/local/nginx/client_body_temp \
--mount type=bind,source=$(pwd)/var/proxy_temp,target=/usr/local/nginx/proxy_temp \
--mount type=bind,source=$(pwd)/var/fastcgi_temp,target=/usr/local/nginx/fastcgi_temp \
\
`#fpm(php)` \
--mount type=bind,source=$(pwd)/var/php-fpm.log,target=/usr/local/php73/var/log/php-fpm.log \
--mount type=bind,source=$(pwd)/var/tmp,target=/tmp \
\
`#wireguard(boringtun)` \
--mount type=bind,source=$(pwd)/var/tmp/run,target=/var/run \
--cap-add=NET_ADMIN --device=/dev/net/tun \
\
`#cockroachdb` \
--mount type=bind,source=$(pwd)/var/cockroach,target=/var/cockroach \
\
-p 80:21404 \
-p 21405:21405 \
\
`#debug` \
`#--security-opt seccomp:unconfined` \
\
diyism/b4gi

