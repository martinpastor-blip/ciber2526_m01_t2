#!/bin/bash

AUDIO_FILE="audio.wav"

VERSION_CURRENT="0.8"

PORT="9999"
IP_SERVER="localhost"

clear


echo "Cliente del protocolo RECTP v$VERSION_CURRENT"

echo "1. SEND. Enviamos la cabecera al servidor"

IP_LOCAL=`ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1`

IP_LOCAL_HASH=`echo "$IP_LOCAL" | md5sum | cut -d " " -f 1`

sleep 1
echo "RECTP $VERSION_CURRENT $IP_LOCAL $IP_LOCAL_HASH" | nc $IP_SERVER -q 0 $PORT

RESPONSE=`nc -l -p $PORT`

echo "4. TEST. Header Response"

if [ "$RESPONSE" != "HEADER_OK" ]
then
	echo "Error 1: Cabeceras mal formadas"

	exit 1
fi

echo "5. SEND. Nombre de archivo"

AUDIO_FILE_HASH=`echo "$AUDIO_FILE" | md5sum | cut -d " " -f 1`

sleep 1
echo "FILE_NAME $AUDIO_FILE $AUDIO_FILE_HASH" | nc $IP_SERVER -q 0 $PORT

echo "6. LISTEN. FILE_NAME_OK"

RESPONSE=`nc -l -p $PORT`

echo "9. TEST. FILE_NAME_OK"

if [ "$RESPONSE" != "FILE_NAME_OK" ]
then
	echo "Error 2: Nombre de archivo incorrecto o mal formado"
	exit 2
fi

echo "10. SEND. FILE DATA"

sleep 1
cat audio.wav | nc $IP_SERVER -q 0 $PORT

echo "11. LISTEN"

RESPONSE=`nc -l -p $PORT`



echo "15 SEND AUDIO DATA HASH"
AUDIOFILE_DATA_HASH=`cat $AUDIO_FILE | md5sum | cut -d " " -f 1`

echo "AUDIOFILE_DATA_HASH $AUDIOFILE_DATA_HASH"
echo "$AUDIOFILE_DATA_HASH" | nc $IP_SERVER -q 0 $PORT











exit 0
