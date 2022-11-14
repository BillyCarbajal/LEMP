apt update
apt install nginx -y
cd /etc/nginx/sites-available
mv default default.bak
printf "upstream myapp1 { server 192.168.100.3; server 192.168.100.4; } server { listen 80; location / { proxy_pass http://myapp1; } }" > default
service nginx restart