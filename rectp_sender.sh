#!/bin/bash

SERVER_ADDRESS=localhost
ERROR_RECTP=$?

./cliente.sh $SERVER_ADDRESS


if [ $ERROR_RECTP -gt 0 ] 
then

echo "error $? en" `date` >> rectp-sender.log

fi


