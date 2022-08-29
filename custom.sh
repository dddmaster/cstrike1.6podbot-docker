#!/bin/bash
if [ ! -d ${SERVER_DIR}/cstrike/addons ]; then
        cp /opt/extra/* $SERVER_DIR/cstrike/
fi

if [[ -e /opt/custom/data/* ]]; then
        cp /opt/custom/data/* $SERVER_DIR/cstrike/
fi

if [ -z $SERVER_NAME ]; then
        SERVER_NAME='default servername'
fi

if [ -z $RCON_PASSWORD ]; then
        RCON_PASSWORD=$(echo $RANDOM | md5sum | head -c 20; echo;)
        echo "generated random rcon password $RCON_PASSWORD"
fi

sed -E -i  "s/(hostname \")(.*?)\"/\1$SERVER_NAME\"/g" server.cfg

if [[ $(grep -e 'rcon_password \".*\"' server.cfg) ]]; then
        sed -E -i "s/(rcon_password \")(.*?)\"/\1$RCON_PASSWORD\"/g" server.cfg
else
        echo -e "rcon_password \"$RCON_PASSWORD\"\n$(cat server.cfg)" > server.cfg
fi