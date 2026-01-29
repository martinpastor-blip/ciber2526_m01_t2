#!/bin/bash


./cliente.sh


if [ $? != 0 ] 
then

echo "error $? en" `date` >> rectp-sender.log

fi


