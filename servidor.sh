#/bin/bash

VERSION_CURRENT="0.8"
AUDIO_FILE="audio.wav"
PORT="9999"
IP_CLIENT="localhost"
SERVER_DIR="server"

clear

mkdir -p $SERVER_DIR

echo "Servidor de RECTP v$VERSION_CURRENT"

IP_LOCAL=`ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1`

echo "IP Local: $IP_LOCAL"

echo "0. LISTEN. HEADER"

DATA=`nc -l -p $PORT`

echo "2.1. TEST. Datos"

HEADER=`echo $DATA | cut -d " " -f 1`

if [ "$HEADER" != "RECTP" ]
then
	echo "ERROR 1: Cabecera errónea"

	sleep 1
	echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 1
fi

VERSION=`echo $DATA | cut -d " " -f 2`

if [ "$VERSION" != "$VERSION_CURRENT" ]
then
	echo "ERROR 2: Versión errónea"

	sleep 1
	echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 2
fi

IP_CLIENT=`echo $DATA | cut -d " " -f 3`

if [ "$IP_CLIENT" == "" ]
then
	echo "Error 4: IP de cliente mal formada ($IP_CLIENT)"

	exit 3
fi


IP_CLIENT_HASH=`echo $DATA | cut -d " " -f 4`
IP_CLIENT_HASH_TEST=`echo "$IP_CLIENT" | md5sum | cut -d " " -f 1`

if [ "$IP_CLIENT_HASH" != "$IP_CLIENT_HASH_TEST" ]
then
	echo "Error 4h: IP de cliente mal formada (Hash erróneo)"
	exit 4
fi



echo "2.2. RESPONSE. Enviando HEADER_OK"

sleep 1
echo "HEADER_OK" | nc $IP_CLIENT -q 0 $PORT

echo "3. LISTEN. Nombre de archivo"

DATA=`nc -l -p $PORT`

echo "7. FILE NAME"

echo "7.1 TEST"

FILE_NAME_PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$FILE_NAME_PREFIX" != "FILE_NAME" ]
then
	echo "Error 5: Prefijo FILE_NAME incorrecto ($FILE_NAME_PREFIX)"

	sleep 1
	echo "FILE_NAME_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 5
fi

FILE_NAME=`echo $DATA | cut -d " " -f 2`

if [ "$FILE_NAME" == "" ]
then
	echo "Error 6: Nombre de archivo vacío"
	exit 6
fi

FILE_NAME_HASH=`echo $DATA | cut -d " " -f 3`

FILE_NAME_HASH_TEST=`echo "$FILE_NAME" | md5sum | cut -d " " -f 1`

if [ "$FILE_NAME_HASH" != "$FILE_NAME_HASH_TEST" ]
then
	echo "Error 7: Hash del nombre de archivo erróneo"
	exit 7
fi


echo "File Name: $FILE_NAME"

echo "7.2 RESPONSE FILE_NAME_OK"






sleep 1
echo "FILE_NAME_OK" | nc $IP_CLIENT -q 0 $PORT

echo "8. LISTEN FILE DATA"
echo "12. STORE FILE DATA"

nc -l -p $PORT > $SERVER_DIR/$FILE_NAME

echo "13. SEND. FILE_DATA_OK"

sleep 1
echo "FILE_DATA_OK" | nc $IP_CLIENT -q 0 $PORT

echo "14. LISTEN. AUDIO_FILE_DATA_HASH_FROM_CLIENT"

AUDIO_FILE_DATA_HASH_FROM_CLIENT=`nc -l -p $PORT`

echo "16. TEST CLIENT AUDIO DATA HASH"

AUDIO_FILE_DATA_HASH_TEST_LOCAL=`cat $AUDIO_FILE | md5sum | cut -d " " -f 1`

echo "AUDIO_FILE_DATA_HASH_TEST_LOCAL $AUDIO_FILE_DATA_HASH_TEST_LOCAL"
echo "AUDIO_FILE_DATA_HASH_FROM_CLIENT $AUDIO_FILE_DATA_HASH_FROM_CLIENT"

if [ "$AUDIO_FILE_DATA_HASH_TEST_LOCAL" != "$AUDIO_FILE_DATA_HASH_FROM_CLIENT" ]
then 
echo "Error 8. HASH_KO"
exit 8

else

echo "HASH_OK"

fi



echo "Fin de comunicación"

aplay $SERVER_DIR/$FILE_NAME

exit 0
