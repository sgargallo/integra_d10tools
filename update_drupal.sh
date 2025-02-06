#!/bin/bash

#Variables y constantes
RUTA_WEB=/var/www/html
USER_WEB=www-data

#Comprobamos que el usuario no es SUDO
if [ "$EUID" -eq 0 ]; then
  >&2 echo "El script no debe ser ejecutado como super usuario"
  exit 1
fi

#Comprobamos que se ha enviado un parámetro
if [ -z "$1" ]; then
	>&2 echo "Nombre del sitio web no especificado. Ejecute ./update_d10.sh nombreSitioWeb"
	exit 1
fi

#Comprobamos si el directorio ya existe
if [ ! -d "$RUTA_WEB/$1/" ]; then
	>&2 echo "El sitio web especificado no existe. Por favor, indique otro diferente"
	exit 1
fi

#Accedemos a la carpeta de sitios web del servidor
cd $RUTA_WEB/$1/

#Clonamos imagen base desde repositorio
echo "Actualizando Drupal..."
sudo -u $USER_WEB composer update --no-cache --ignore-platform-reqs

#Fin del proceso
echo "Proceso finalizado"