#!/bin/bash

#verify all required envs are set or set fallback values
check_and_fix_env() {
	if [[ -z $(UID) ]]; then
		UID=99;
	fi
	
	if [[ -z $(GID) ]]; then
		GID=100;
	fi
	
	if [[ -z $(USER) ]]; then
		USER="steam";
	fi
	
	if [[ -z $(GAME_PORT) ]]; then
		GAME_PORT="27015";
	fi
	
	if [[ -z $(GAME_NAME) ]]; then
		GAME_NAME="cstrike";
	fi
	
	if [[ -z $(GAME_ID) ]]; then
		GAME_ID="90";
	fi
	
	if [[ -z $(GAME_PARAMS) ]]; then
		GAME_PARAMS="+maxplayers 32 +map de_dust";
	fi
	
	if [ -z $SERVER_NAME ]; then
		SERVER_NAME='default ddd servername'
	fi

	if [ -z $RCON_PASSWORD ]; then
		RCON_PASSWORD="$(echo $RANDOM | md5sum | head -c 20; echo;)"
		echo "generated random rcon password $RCON_PASSWORD"
	fi
	
	acc="${USERNAME} ${PASSWRD}"
	
	if [ "${USERNAME}" == "" ]; then
		acc="anonymous"
	fi
	
		
	#DATA_DIR /serverdata
	#STEAMCMD_DIR /serverdata/steamcmd
	#SERVER_DIR /serverdata/serverfiles
	#DATA_PERM 770
	#UMASK 000
	#
	
}

first_start() {
	echo "---Ensuring UID: ${UID} matches user---"
	usermod -u ${UID} ${USER}
	echo "---Ensuring GID: ${GID} matches user---"
	groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
	usermod -g ${GID} ${USER}
	echo "---Setting umask to ${UMASK}---"
	umask ${UMASK}

	echo "---Checking for optional scripts---"

	echo "---Taking ownership of data...---"
	chown -R root:${GID} /opt/scripts
	chmod -R 750 /opt/scripts
	chown -R ${UID}:${GID} ${DATA_DIR}

	echo "---Starting...---"
	
	term_handler() {
        kill -SIGTERM "$killpid"
        wait "$killpid" -f 2>/dev/null
        exit 143;
	}

	trap 'kill ${!}; term_handler' SIGTERM
	su ${USER} -c "/opt/scripts/start.sh" &
	killpid="$!"
	while true
	do
        wait $killpid
        exit 0;
	done
}
	

# download steamcmd
download_steamcmd() {
	wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
	tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
	rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
}

# install and update steamcmd
update_steam() {
	${STEAMCMD_DIR}/steamcmd.sh \
    +login ${acc} \
    +quit
}

# download and update serverfiles, will loop untill its successfull
update_server() {
	run="true"
	while [[ "$run" == "true" ]]; do
	echo -n ".";
	resp=$(${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${acc} \
        +app_set_config ${GAME_MOD} \
        +app_update ${GAME_ID} validate \
        +quit | tail -n1)
		
		if [[ $(echo $resp | grep "Success! App '${GAME_ID}'") ]]; then
			run=false;
		else
			echo $resp;
		fi
	done
}

# fix sdk3 stuff and set permissions
prepare_server() {
	mkdir ${DATA_DIR}/.steam/sdk32
	cp ${SERVER_DIR}/steamclient.so ${DATA_DIR}/.steam/sdk32/steamclient.so
	chmod -R ${DATA_PERM} ${DATA_DIR}
}

# copy all extra files
install_extra() {
	cp -R /opt/custom/* ${SERVER_DIR}/cstrike/
}

#replace and alter config files
replace_conf() {
	sed -E -i  "s/(hostname \")(.*?)\"/\1$SERVER_NAME\"/g" ${SERVER_DIR}/cstrike/server.cfg

	if [[ $(grep -e 'rcon_password \".*\"' server.cfg) ]]; then
	   sed -E -i "s/(rcon_password \")(.*?)\"/\1$RCON_PASSWORD\"/g" ${SERVER_DIR}/cstrike/server.cfg
	else
		echo -e "rcon_password \"$RCON_PASSWORD\"\n$(cat ${SERVER_DIR}/cstrike/server.cfg)" > ${SERVER_DIR}/cstrike/server.cfg 
	fi
	
	# install my custom mapcycle and motd because im lazy
	if [ -n $DDD ]; then
		cp ${SERVER_DIR}/cstrike/data/ddd/* ${SERVER_DIR}/cstrike/data/
	fi

}

#start the server
start_server() {
	cd ${SERVER_DIR}
	${SERVER_DIR}/hlds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}
}


check_and_fix_env

if [[ "$(whoami)" != "steam" ]]; then
	first_start;
	exit;
fi


if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
	echo "SteamCMD not found!"
	download_steamcmd
fi

echo "---Update SteamCMD---"
update_steam

echo "---Update Server---"
update_server

echo "---Prepare Server---"
prepare_server

echo "---Install Extra---"
install_extra

echo "---replace conf---"
replace_conf

echo "---Start Server---"
start_server
