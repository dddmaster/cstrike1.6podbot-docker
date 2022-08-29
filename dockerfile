FROM ich777/steamcmd:cstrike1.6
COPY ./data /opt/custom/
COPY start.sh /opt/scripts/start.sh
RUN chmod +x /opt/scripts/start.sh