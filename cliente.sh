#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Error 255: Número insuficiente de parámetros."
	echo "Sintaxis:"
	echo -e "\t$0 SERVER_ADDRESS"
	echo "Ejemplos de uso:"
	echo -e "\t$0 localhost" 
	echo -e "\t$0 192.168.225.33"
	exit 255
fi

AUDIO_FILE="audio.wav"

VERSION_CURRENT="0.8"

PORT="9999"
IP_SERVER="$1"

clear


echo "Cliente del protocolo RECTP v$VERSION_CURRENT"
echo "Conectando a $IP_SERVER"

echo "1. SEND. Enviamos la cabecera al servidor"

IP_LOCAL=`ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1`
# IP_LOCAL=`ip route get 1 | awk '{print $7}'`
# IP_LOCAL=`ip -4 addr | grep "scope global" | sed 's/^[ \t]*//' | cut -d "/" -f 1 | cut -d " " -f 2`
# IP_LOCAL=`ip -4 addr | grep "scope global" | tr -s " " | cut -d " " -f 3 | cut -d "/" -f 1`
# IP_LOCAL=`ip -4 addr | grep 'inet ' | grep -v '127.' | awk '{print $2}' | cut -d "/" -f ip -4 addr | grep 'inet ' | grep -v '127.' | awk '{print $2}' | cut -d "/" -f 11`

IP_LOCAL_HASH=`echo "$IP_LOCAL" | md5sum | cut -d " " -f 1`

sleep 1
echo "RECTP $VERSION_CURRENT $IP_LOCAL $IP_LOCAL_HASH" | nc $IP_SERVER -q 0 $PORT

if [ $? != 0 ]
then
	echo "Error 127: No ha sido posible conectar a $IP_SERVER"
	exit 127
fi

echo "2. LISTEN. Header Response"

RESPONSE=`nc -l -p $PORT`

echo "5. TEST. Header Response"

if [ "$RESPONSE" != "HEADER_OK" ]
then
	echo "Error 1: Cabeceras mal formadas"

	exit 1
fi

echo "6. SEND. Nombre de archivo"

AUDIO_FILE_HASH=`echo "$AUDIO_FILE" | md5sum | cut -d " " -f 1`

sleep 1
echo "FILE_NAME $AUDIO_FILE $AUDIO_FILE_HASH" | nc $IP_SERVER -q 0 $PORT

echo "7. LISTEN. FILE_NAME_OK"

RESPONSE=`nc -l -p $PORT`

echo "10. TEST. FILE_NAME_OK"

if [ "$RESPONSE" != "FILE_NAME_OK" ]
then
	echo "Error 2: Nombre de archivo incorrecto o mal formado"
	exit 2
fi

echo "11. SEND. FILE DATA"

sleep 1
cat audio.wav | nc $IP_SERVER -q 0 $PORT

echo "12. LISTEN"

RESPONSE=`nc -l -p $PORT`

echo "16. TEST"

if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
	echo "ERROR 3: Datos del archivo corruptos"

	exit 3
fi

echo "17. SEND. FILE_DATA_HASH"


FILE_DATA_HASH=`md5sum $AUDIO_FILE | cut -d " " -f 1`

echo "FILE_DATA_HASH $FILE_DATA_HASH" | nc $IP_SERVER -q 0 $PORT

echo "18. LISTEN"

RESPONSE=`nc -l -p $PORT`

if [ "$RESPONSE" != "FILE_DATA_HASH_OK" ]
then
	echo "Error 4: Archivo enviado incorrectamente (error MD5)"
	exit 128
fi

echo "Fin de comuniación"

exit 0
