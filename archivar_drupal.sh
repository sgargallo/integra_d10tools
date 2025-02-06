#!/bin/bash

#Variables y constantes
TIMESTAMP=$(date +"%F")
MYSQL_USER=eformedia
MYSQL_PASSWORD=efor2017
MYSQLDUMP=/usr/bin/mysqldump
RUTA_WEB=/var/www/html
RUTA_BD=/var/lib/mysql
RUTA_TEMP=./$1

#Comprobamos que el usuario no es SUDO
if [ "$EUID" -ne 0 ]; then
  >&2 echo "El script debe ser ejecutado como super usuario"
  exit 1
fi

#Comprobamos que se ha enviado un parámetro
if [ $# -eq 0 ]; then
	>&2 echo "Nombre del sitio web no especificado. Ejecute ./archivar_d10.sh nombreSitioWeb"
	exit 1
fi

#Comprobamos si el directorio existe
if [ ! -d "$RUTA_WEB/$1/" ]; then
	>&2 echo "El sitio web especificado no existe. Por favor, indique otro diferente"
	exit 1
fi

#Comprobamos si la base de datos existe
if [ ! -d "$RUTA_BD/$1" ]; then
	>&2 echo "La base de datos para este sitio web no existe. Por favor, indique otro diferente"
	exit 1
fi

#Preparamos un directorio local para archivar la web
echo "Preparando directorio temporal para el sitio web..."
[ -d "$RUTA_TEMP/" ] && rm -r $RUTA_TEMP
mkdir $RUTA_TEMP

#Creamos la estructura necesaria de carpetas para alojar el volcado
echo "Creando estructura de carpetas..."
mkdir $RUTA_TEMP/web
mkdir $RUTA_TEMP/web/libraries
mkdir $RUTA_TEMP/web/modules
mkdir $RUTA_TEMP/web/sites
mkdir $RUTA_TEMP/web/sites/default
mkdir $RUTA_TEMP/web/themes

#Copiamos los recursos necesarios en las carpetas temporales
echo "Copiando archivos y carpetas del sitio web a la ruta temporal..."
cp $RUTA_WEB/$1/composer.json $RUTA_TEMP/web
cp $RUTA_WEB/$1/composer.lock $RUTA_TEMP/web
cp -r $RUTA_WEB/$1/libraries $RUTA_TEMP/web
cp -r $RUTA_WEB/$1/modules/custom $RUTA_TEMP/web/modules
cp -r $RUTA_WEB/$1/profiles $RUTA_TEMP/web
cp -r $RUTA_WEB/$1/sites/default/files $RUTA_TEMP/web/sites/default/
cp -r $RUTA_WEB/$1/themes/custom $RUTA_TEMP/web/themes

#Limpiamos las carpetas de caché y temporales que nos hemos traido
echo "Limpiando archivos de caché..."
rm -r $RUTA_TEMP/web/sites/default/files/css
rm -r $RUTA_TEMP/web/sites/default/files/js
rm -r $RUTA_TEMP/web/sites/default/files/languages
rm -r $RUTA_TEMP/web/sites/default/files/php
rm -r $RUTA_TEMP/web/sites/default/files/styles
rm -r $RUTA_TEMP/web/sites/default/files/translations

#Volcamos la base de datos y la dejamos en la raiz de la copia de seguridad
echo "Volcando base de datos del sitio web..."
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $1 | gzip > "$RUTA_TEMP/dbdump.sql.gz"

#Compactamos el sitio web en un archivo que podamos manejar y lo trasladamos a una ruta accesible
echo "Compactando el sitio web y moviéndolo a la carpeta 'www'..."
tar -czf "$1-$TIMESTAMP-archive.tar.gz" "$RUTA_TEMP/"
mv "$1-$TIMESTAMP-archive.tar.gz" "$RUTA_WEB"

#Borramos la carpeta temporal
echo "Borrando la carpeta temporal..."
rm -r $RUTA_TEMP/
