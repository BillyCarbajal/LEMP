apt update
apt install nginx php-fpm php-mysql git -y
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
cp iaw-practica-lamp/src/* /var/www/html/ && rm -rf iaw-practica-lamp
sed -i 's/localhost/192.168.200.2/' /var/www/html/config.php
cd /etc/nginx/sites-available
mv default default.bak
printf "server {\n\tlisten 80 default_server;\n\tlisten [::]:80 default_server;\n\troot /var/www/html;\n\tindex index.php index.html index.htm index.nginx-debian.html;\n\tserver_name _;\n\tlocation / {\n\ttry_files \$uri \$uri/ =404;\n\t}\n\tlocation ~ \\.php$ {\n\tinclude snippets/fastcgi-php.conf;\n\tfastcgi_pass unix:/run/php/php7.4-fpm.sock;\n\t}\n}" > default
service php7.4-fpm restart
service nginx restart