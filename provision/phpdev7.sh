#!/usr/bin/env bash

sudo apt-get install -y apache2 apache2-utils # install before mod_php

# php
sudo apt-get install -y php php-pgsql php-mysql php-pdo php-curl php-xml php-mbstring php-zip php-bcmath php-redis php-gd libapache2-mod-php

# No more interactive questions asked by installers
export DEBIAN_FRONTEND=noninteractive

# Update system
sudo apt-get update
sudo apt-get upgrade

sudo locale-gen ru_RU.UTF-8

# Common utils
sudo apt-get install -y mc curl htop git software-properties-common python-software-properties unzip

# external repos

# postgreSQL
sudo add-apt-repository 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# heroku toolbelt
sudo add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
wget --quiet -O - https://cli-assets.heroku.com/apt/release.key | sudo apt-key add -

sudo apt-get update
sudo adduser vagrant www-data

# apache
sudo a2enmod rewrite
sudo cp /vagrant/conf/apache.conf /etc/apache2/sites-available/000-default.conf

# mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 123'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 123'
sudo apt-get install -y mysql-server mysql-client
printf "[client]\nuser=root\npassword=123\n" > /home/vagrant/.my.cnf

# postgres
sudo apt-get install -y postgresql-9.6 postgresql-server-dev-9.6
sudo cp /vagrant/conf/postgres.conf /etc/postgresql/9.6/main/pg_hba.conf
printf "\nexport PGUSER=\"postgres\"\nexport PGPASSWORD=\"123\"\n" >> /home/vagrant/.bashrc
sudo -u postgres psql -c "ALTER USER postgres with password '123';"

# PHP Composer
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

mkdir /home/vagrant/.composer
php composer-setup.php --install-dir=/home/vagrant/.composer
rm composer-setup.php
echo "export PATH=~/.composer:~/.composer/vendor/bin:$PATH" >> ~/.bashrc
mv /home/vagrant/.composer/composer.phar /home/vagrant/.composer/composer


# PHPUnit
/home/vagrant/.composer/composer global require phpunit/phpunit=^5.4.0
/home/vagrant/.composer/composer global require phpunit/dbunit=^2.0.2

# heroku
sudo apt-get install -y heroku

# restart services
sudo service apache2 restart
