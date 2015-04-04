FROM ppschweiz/apache

RUN apt-get update && apt-get install -y \
		curl \
		libapache2-mod-php5 \
		php5-curl \
		php5-gd \
		php5-mysql \
		php5-ldap \
		php5-xcache \
		rsync \
		wget \
		git \
	&& rm -rf /var/lib/apt/lists/*

ENV WORDPRESS_VERSION 4.0.0
ENV WORDPRESS_UPSTREAM_VERSION 4.0

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -SL http://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz | tar -xzC /usr/src/

COPY docker-apache.conf /etc/apache2/sites-available/wordpress
RUN a2dissite 000-default && a2ensite wordpress

COPY docker-entrypoint.sh /entrypoint.sh

COPY update-wordpress.sh /update-wordpress.sh

RUN git clone https://github.com/ppschweiz/wptheme.git /wptheme && mv /wptheme/pps /usr/src/wordpress/wp-content/themes/pps && rm -Rf /wptheme

RUN curl -SL curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp-cli.phar
RUN chmod 755 /usr/local/bin/wp-cli.phar
ADD wp /usr/local/bin/wp

RUN a2enmod expires headers

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2", "-DFOREGROUND"]

