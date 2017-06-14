These files are included in case you need to change Logstash / JVM defaults.
To change defaults and have that built into the Docker image:
1. Create a copy of the default file and make your changes to the copy
2. Edit tbe Dockerfile and add a COPY line near the bottom of the file tbat copies your file to:
   /usr/share/logstash/config/
   Making sure to overwrite the corect default file and be sure to set permisons on that file to user: logstash
