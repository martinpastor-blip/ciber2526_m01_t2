#!/bin/bash

AUDIO_FILE="audio.wav"
HASH_MD5_HEXADECIMAL=`echo -n "$AUDIO_FILE" | md5sum | cut -d " " -f 1`
VERSION_CURRENT="0.6"
PORT="9999"
IP_SERVER="localhost"

clear


echo "Cliente del protocolo RECTP v$VERSION_CURRENT"

echo "1. SEND. Enviamos la cabecera al servidor"

IP_LOCAL=`ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1`

sleep 1
echo "RECTP $VERSION_CURRENT $IP_LOCAL" | nc $IP_SERVER -q 0 $PORT

echo "2. LISTEN"
RESPONSE=`nc -l -p $PORT`

echo "5. TEST. Header Response"

if [ "$RESPONSE" != "HEADER_OK" ]
then
	echo "Error 1: Cabeceras mal formadas"

	exit 1
fi

echo "6. SEND. Nombre de archivo y hash"
sleep 1
echo "FILE_NAME $AUDIO_FILE" "$HASH_MD5_HEXADECIMAL"| nc $IP_SERVER -q 0 $PORT




echo "7.0 LISTEN. FILE_NAME_OK"

RESPONSE=`nc -l -p $PORT`

echo "10.0 TEST. FILE_NAME_OK"

if [ "$RESPONSE" != "FILE_NAME_OK" ]
then
	echo "Error 2: Nombre de archivo incorrecto o mal formado"
	exit 2
fi


echo "11 LISTEN. HASH_OK"
RESPONSE=`nc -l -p $PORT`

echo "12 TEST HASH_OK"

if [ "$RESPONSE" != "HASH_OK" ]
then
	echo "Error 3: Hash del archivo erroneo"
	exit 3
fi


echo "15. SEND. FILE DATA"

sleep 1
cat audio.wav | nc $IP_SERVER -q 0 $PORT

echo "16. LISTEN"

RESPONSE=`nc -l -p $PORT`

echo "17. TEST AND END"

if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
	echo "ERROR 4: Datos del archivo corruptos"

	exit 4
fi

echo "Fin de comuniación"

exit 0
