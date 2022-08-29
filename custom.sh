#!/bin/bash
set -e
if [ ! -d ${SERVER_DIR}/cstrike/addons ]; then
		echo "COPY data"
		cp -r /opt/custom/* $SERVER_DIR/cstrike/
fi

if [[ -e /opt/custom/extra ]]; then
		echo "COPY extrra"
		cp -r /opt/extra/* $SERVER_DIR/cstrike/        
fi

if [ -z $SERVER_NAME ]; then
    SERVER_NAME='default servername'
fi

if [ -z $RCON_PASSWORD ]; then
        RCON_PASSWORD="$(echo $RANDOM | md5sum | head -c 20; echo;)"
        echo "generated random rcon password $RCON_PASSWORD"
fi

sed -E -i  "s/(hostname \")(.*?)\"/\1$SERVER_NAME\"/g" ${SERVER_DIR}/cstrike/server.cfg

if [[ $(grep -e 'rcon_password \".*\"' server.cfg) ]]; then
   sed -E -i "s/(rcon_password \")(.*?)\"/\1$RCON_PASSWORD\"/g" ${SERVER_DIR}/cstrike/server.cfg
else
	echo -e "rcon_password \"$RCON_PASSWORD\"\n$(cat ${SERVER_DIR}/cstrike/server.cfg)" > ${SERVER_DIR}/cstrike/server.cfg 
fi
