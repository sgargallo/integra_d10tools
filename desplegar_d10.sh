#!/bin/bash

#Variables y constantes
MYSQL_USER=eformedia
MYSQL_PASSWORD=efor2017
RUTA_WEB=/var/www/html
RUTA_BD=/var/lib/mysql
USER_WEB=www-data
D10_REPO=https://github.com/sgargallo/integra_d10base.git

#Comprobamos que el usuario no es SUDO
if [ "$EUID" -eq 0 ]; then
  >&2 echo "El script no debe ser ejecutado como super usuario"
  exit 1
fi

#Comprobamos que se ha enviado un parámetro
if [ $# -eq 0 ]; then
	>&2 echo "Nombre del sitio web no especificado. Ejecute ./desplegar_d10.sh nombreSitioWeb"
	exit 1
fi

#Comprobamos si el directorio ya existe
if [ -d "$RUTA_WEB/$1/" ]; then
	>&2 echo "El sitio web especificado ya existe. Por favor, indique otro diferente"
	exit 1
fi

#Comprobamos si la base de datos ya existe
if [ -d "$RUTA_BD/$1" ]; then
	>&2 echo "La base de datos para este sitio web ya existe. Por favor, indique otro diferente"
	exit 1
fi

#Accedemos a la carpeta de sitios web del servidor
cd $RUTA_WEB

#Clonamos imagen base desde repositorio
echo "Clonando instalación base en la carpeta solicitada..."
sudo -u $USER_WEB git clone $D10_REPO $1

#Accedemos a la carpeta del sitio web
cd $RUTA_WEB/$1/

#Ejecutamos instalación de Drupal con composer
echo "Desplegando Drupal 10 utilizando composer..."
sudo -u $USER_WEB composer install --no-cache --ignore-platform-reqs

#Creamos una base de datos para el sitio web
echo "Creando base de datos para el sitio web..."
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "create database $1"; 

#Fin del proceso
echo "Proceso finalizado"