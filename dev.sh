#!/bin/sh
sudo docker build -t ppschweiz/wordpress .
sudo docker kill mysql
sudo docker rm mysql
sudo docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=root -v `pwd`/mysql:/var/lib/mysql mysql
sleep 5
sudo docker run -p 8080:80 --link mysql:mysql -v `pwd`/html:/var/www/html -e MYSQL_USERNAME=root -e MYSQL_PASSWORD=root ppschweiz/wordpress
