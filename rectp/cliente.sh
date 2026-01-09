#!/bin/bash
PORT=9999
VERSION_CURRENT="0.6"
AUDIO_FILE="audio.wav"
IP_SERVER="192.168.225.96"

clear 

echo "cliente de rectp $VERSION_CURRENT"

echo "1.0.SEND envia la cabecera al servidor"
IP_LOCAL=`ip -4 addr | grep "scope global" | awk "{print $2}`
sleep 1
echo "RECTP $VERSION_CURRENT $IP_LOCAL" | nc $IP_SERVER -q 0 $PORT

echo "2.0 Listen:"
RESPONSE=`nc -l -p $PORT`


echo "5.0 Test Header Response"
if [ "$RESPONSE" != "HEADER_OK" ]
then
echo "ERROR 1: Cabecera mal formada"

exit 1
fi
echo "6.SEND Nombre de archivo"
sleep 1
echo "FILE_NAME $AUDIO_FILE" | nc $IP_SERVER -q 0 $PORT

echo "7.LISTEN FILE_NAME_OK"

RESPONSE=`nc -l -p $PORT`


echo "10.TEST FILE_NAME_OK"

if [ "$RESPONSE" != "FILE_NAME_OK" ]
then
echo "Error 2: Nombre de archivo incorrecto o mal formado"
exit 2
fi

echo "11.SEND FILE DATA"
sleep 1
cat audio.wav | nc $IP_SERVER -q 0 $PORT

echo "12.LISTEN"

RESPONSE=`nc -l -p $PORT`

echo "15.0 TEST AND END"



if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
echo "ERROR 3: Datos de archivo corruptos"

exit 3
fi

echo "Fin de comunicación"
exit 0
