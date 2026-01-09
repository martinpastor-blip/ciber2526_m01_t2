#!/bin/bash
PORT="9999"
VERSION_CURRENT="0.6"
IP_CLIENT="localhost"
SERVER_DIR="server"

clear

mkdir -p $SERVER_DIR
echo "servidor de rectp v$VERSION_CURRENT"
echo "0. Listen"
DATA=`nc -l -p $PORT`
HEADER=`echo $DATA | cut  -d " " -f 1`

echo "3.0 Test"
if [ $HEADER != "RECTP" ]
then
  echo "ERROR 1: Cabecera erronea"
sleep 1
echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT
  exit 1
else  
  echo "Cabecera correcta"
fi

VERSION=`echo $DATA | cut -d " " -f 2`
if [ $VERSION != "$VERSION_CURRENT" ]
then	

echo "ERROR 2: Version erronea"
sleep 1
echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT
exit 2
fi

echo "3.2. RESPONSE. Enviando HEADER_OK"

echo "HEADER_OK" | nc $IP_CLIENT -q 0 $PORT

echo "4.0 Listen header"
DATA=`nc -l -p $PORT`

echo "8.0. FILE NAME"
echo "8.1 TEST"
FILE_NAME_PREFIX=`echo $DATA | cut -d " " -f 1`


if [ "$FILE_NAME_PREFIX" != "$FILE_NAME" ]
then

echo "ERROR 3: Prefijo FILE_NAME incorrecto ($FILE_NAME_PREFIX)"

sleep 1
echo "FILE_NAME_KO" | nc $IP_CLIENT -q 0 $PORT
exit 3

FILE_NAME=`echo $DATA | cut -d " " -f 2`
echo "File name: $FILE_NAME"

fi



echo "8.2.RESPONSE FILE_NAME_OK"
echo "FILE_NAME_OK" | nc $IP_CLIENT -q 0 $PORT

echo "9.LISTEN FILE DATA"

echo "13. STORE FILE DATA"



nc -l -p $PORT > $SERVER_DIR/$FILE_NAME

echo "14.SEND FILE_DATA_OK"
sleep 1

echo "FILE_DATA_OK" | nc $IP_CLIENT -q 0 $PORT
aplay $SERVER_DIR/$FILE_NAME
echo "Fin de comunicación"


exit 0
