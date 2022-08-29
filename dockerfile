FROM ich777/steamcmd:cstrike1.6
COPY ./data /opt/custom/
RUN sed -E -i "s/(echo \"---Prepare Server---\")/source custom.sh\n\1/g" /opt/scripts/start-server.sh