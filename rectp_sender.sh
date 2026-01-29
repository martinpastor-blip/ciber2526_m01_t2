#!/bin/bash


echo "dame la IP del server"
read SERVER_ADDRESS


./cliente.sh $SERVER_ADDRESS


if [ $? -gt 0 ] 
then

echo "error $? en" `date` >> rectp-sender.log

fi


