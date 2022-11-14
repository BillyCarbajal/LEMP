## Crear LEMP
### Paso 1. Crear y editar archivo Vagrantfile
Usamos el comando "vagrant init" desde una terminal cmd que nos creara un archivo llamado Vagrantfile.
Editamos ese archivo con un editor de texto y eliminamos la siguiente linea:
> config.vm.box = "base"

Y añadimos estas líneas que serán las que indicaran el hostname, sistema instalado, tipo de red, cantidad de memoria RAM, limite de procesadores y la ubicación de sus respectivos script bash de aprovisionamiento de las 4 maquinas llamadas "Billy-nalanceador", "Billy-nginx1", "Billy-nginx2" y "Billy-mysql".

	Vagrant.configure("2") do |config|
		config.vm.define "balanceador" do |ba|
			ba.vm.hostname = "balanceador"
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
		config.vm.define "servidor-nginx1" do |web1|
			web1.vm.hostname = "apache1"
			web1.vm.box = "generic/debian11"
			web1.vm.network "private_network", ip:"192.168.100.3",
				virtualbox__intnet: "priv1"
			web1.vm.network "private_network", ip:"192.168.200.3",
				virtualbox__intnet: "priv2"
			web1.vm.provider "virtualbox" do |v|
				v.memory = 1024
				v.cpus = 1
			end
			web1.vm.provision :shell, privileged:true, path: "script-apache1.sh"
		end
		config.vm.define "servidor-nginx2" do |web2|
			web2.vm.hostname = "apache2"
			web2.vm.box = "generic/debian11"
			web2.vm.network "private_network", ip:"192.168.100.4",
				virtualbox__intnet: "priv1"
			web2.vm.network "private_network", ip:"192.168.200.4",
				virtualbox__intnet: "priv2"
			web2.vm.provider "virtualbox" do |v|
				v.memory = 1024
				v.cpus = 1
			end
			web2.vm.provision :shell, privileged:true, path: "script-apache2.sh"
		end
		config.vm.define "servidor-mysql" do |sql|
			sql.vm.hostname = "mysql"
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

