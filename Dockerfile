FROM corbinu/docker-nginx-php
MAINTAINER mzvast <mzvast@gmail.com>

ENV PMA_SECRET          blowfish_secret
ENV PMA_USERNAME        root
ENV PMA_PASSWORD        root
ENV PMA_NO_PASSWORD     0
ENV PMA_AUTH_TYPE       cookie
ENV MYSQL_USERNAME      root
ENV MYSQL_PASSWORD      root

RUN apt-get update
RUN apt-get install -y mysql-client

ENV PHPMYADMIN_VERSION 4.5.0.2
ENV MAX_UPLOAD "200M"

RUN curl --location https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz | tar xzf - \
 && rm -r /www \
 && mv phpMyAdmin* /www 

ADD sources/config.inc.php /
ADD sources/create_user.sql /
ADD sources/phpmyadmin-start /usr/local/bin/
ADD sources/phpmyadmin-firstrun /usr/local/bin/

RUN chmod +x /usr/local/bin/phpmyadmin-start
RUN chmod +x /usr/local/bin/phpmyadmin-firstrun

RUN sed -i "s/http {/http {\n        client_max_body_size $MAX_UPLOAD;/" /etc/nginx/nginx.conf
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = $MAX_UPLOAD/" /etc/php5/fpm/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = $MAX_UPLOAD/" /etc/php5/fpm/php.ini

EXPOSE 80

CMD phpmyadmin-start
