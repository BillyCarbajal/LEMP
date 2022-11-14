## Crear LEMP
### Paso 1. Crear y editar archivo Vagrantfile
Usamos el comando "vagrant init" desde una terminal cmd que nos creara un archivo llamado Vagrantfile.
Editamos ese archivo con un editor de texto y eliminamos la siguiente linea:
> config.vm.box = "base"

Y añadimos estas líneas que serán las que indicaran el hostname, sistema instalado, tipo de red, cantidad de memoria RAM, limite de procesadores y la ubicación de sus respectivos script bash de aprovisionamiento de las 4 maquinas llamadas "Billy-balanceador", "Billy-nginx1", "Billy-nginx2" y "Billy-mysql".

	Vagrant.configure("2") do |config|
		config.vm.define "Billy-balanceador" do |ba|
			ba.vm.hostname = "Billy-balanceador"
			ba.vm.box = "generic/debian11"
			ba.vm.network "private_network", ip:"192.168.100.2",
				virtualbox__intnet: "priv1"
			ba.vm.network "public_network"
			ba.vm.provider "virtualbox" do |v|
				v.memory = 1024
				v.cpus = 1
			end
			ba.vm.provision :shell, privileged:true, path: "script-balanceador.sh"
		end
		config.vm.define "Billy-nginx1" do |web1|
			web1.vm.hostname = "Billy-nginx1"
			web1.vm.box = "generic/debian11"
			web1.vm.network "private_network", ip:"192.168.100.3",
				virtualbox__intnet: "priv1"
			web1.vm.network "private_network", ip:"192.168.200.3",
				virtualbox__intnet: "priv2"
			web1.vm.provider "virtualbox" do |v|
				v.memory = 1024
				v.cpus = 1
			end
			web1.vm.provision :shell, privileged:true, path: "script-nginx1.sh"
		end
		config.vm.define "Billy-nginx2" do |web2|
			web2.vm.hostname = "billy-nginx2"
			web2.vm.box = "generic/debian11"
			web2.vm.network "private_network", ip:"192.168.100.4",
				virtualbox__intnet: "priv1"
			web2.vm.network "private_network", ip:"192.168.200.4",
				virtualbox__intnet: "priv2"
			web2.vm.provider "virtualbox" do |v|
				v.memory = 1024
				v.cpus = 1
			end
			web2.vm.provision :shell, privileged:true, path: "script-nginx2.sh"
		end
		config.vm.define "Billy-mysql" do |sql|
			sql.vm.hostname = "Billy-mysql"
			sql.vm.box = "generic/debian11"
			sql.vm.network "private_network", ip:"192.168.200.2",
				virtualbox__intnet: "priv2"
			sql.vm.provider "virtualbox" do |v|
				v.memory = 1024
				v.cpus = 1
			end
			sql.vm.provision :shell, privileged:true, path: "script-mysql.sh"
		end 
	end

### Paso2. Editamos el archivo de aprovisionamiento del balanceador
Ahora crearemos en la misma carpeta un archivo llamado "script-balanceador.sh" en el incluiremos las siguientes lineas:
- Para actualiza los repositorios del servidor apache:

	apt update
- Para instalar los paquetes necesarios en el balanceador:

	apt install nginx -y
- Nos dirigimos a la carpeta de nginx y movemos el archivo default a default.bak:

	cd /etc/nginx/sites-available
	mv default default.bak
- Creamos un nuevo archivo default que sea actuara como configuracion de la pagina web del balanceador y en el introducimos los ajustes:
	printf "upstream myapp1 { server 192.168.100.3; server 192.168.100.4; } server { listen 80; location / { proxy_pass http://myapp1; } }" > default

- Reiniciamos el servidor nginx:

	service nginx restart

### Paso 3. Editamos el archivo de aprovisionamiento del servidor Billy-nginx1
Ahora crearemos en la misma carpeta un archivo llamado "script-nginx1.sh" en el incluiremos las siguientes lineas:
- Para actualizar los repositorios del servidor apache:

	apt update

- Para instalar los paquetes necesarios en el balanceador:

	apt install nginx php-fpm php-mysql git -y
- Descargamos los archivos para la pagina web:

	git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
- Copiamos los archivos al directorio donde se alojara la pagina web y eliminamos los archivos no necesarios:

	cp iaw-practica-lamp/src/* /var/www/html/ && rm -rf iaw-practica-lamp
- Reconfiguramos los archivos de la pagina web:

	sed -i 's/localhost/192.168.200.2/' /var/www/html/config.php
- Vamos a la carpeta con la configuracion de la pagina por defecto y la movemos como .bak:

	cd /etc/nginx/sites-available
	mv default default.bak
- Creamos un nuevo archivo default con los ajustes necesarios:

	printf "server {\n\tlisten 80 default_server;\n\tlisten [::]:80 default_server;\n\troot /var/www/html;\n\tindex index.php index.html index.htm index.nginx-debian.html;\n\tserver_name _;\n\tlocation / {\n\ttry_files \$uri \$uri/ =404;\n\t}\n\tlocation ~ \\.php$ {\n\tinclude snippets/fastcgi-php.conf;\n\tfastcgi_pass unix:/run/php/php7.4-fpm.sock;\n\t}\n}" > default

- Reiniciamos el php-fpm y el nginx:
	service php7.4-fpm restart && service nginx restart

Ahora tambien realizamos lo mismo pero creando un archivo script-nginx2.sh
### Paso 4. Editamos el archivo de aprovisionamiento del servidor Billy-mysql
Ahora crearemos en la misma carpeta un archivo llamado "script-mysql.sh" en el incluiremos las siguientes lineas:
- Con esta linea actualizamos los respositorios del servidor mysql: \

		apt update
- Con esta linea se instalan los paquetes necesario para el servidor mysql:

		apt install default-mysql-server git -y
- Con esta linea descargamos los archivos necesarios para el servidor mysql:

		git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
- Con esta linea enviamos el archivo database.sql para que lo ejecute el servidor mysql:

		mysql -u root -proot < iaw-practica-lamp/db/database.sql
- Con esta linea eliminamos de configuracion ya no necesarios:

		rm -rf iaw-practica-lamp
- Creamos un archivo adicional para reconfigurar el la base de datos mysql:

		echo "use mysql; alter user 'lamp_user'@'%' identified by 'lamp_password'; grant all privileges on lamp_db.* to 'lamp_user'@'%'; flush privileges;" > temp.sql
		mysql -u root -proot < temp.sql
		rm temp.sql
- Con estas lineas editamos la direccion del servidor mysql:

		cat /etc/mysql/mariadb.conf.d/50-server.cnf|grep -v "bind-address" > temp1.txt
		printf "[mariadb]\nbind-address = 192.168.200.2\n" >> temp1.txt
		mv temp1.txt /etc/mysql/mariadb.conf.d/50-server.cnf
- Con estas lineas deshabilitamos la puerta del enlace creada por defecto por Vagrant:

		prub=`arp -n|grep "eth0"|cut -d " " -f1`
		route delete default gw $prub
- Con esta linea reiniciamos el servicio mysql:

		systemctl restart mysql

Una vez hecho todo esto guardamos el archivo.

### Paso









