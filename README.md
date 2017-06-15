# docker-logstash
## Production grade Logstash in a Docker container
### Custom Logstash build that includes a specified logstash.conf and specified plugins!
Based on openjdk:8-jre-alpine to keep the container size small
## ==================================================
#### Build the Docker container:
docker build -t my-logstash:1.0.0 .
## ==================================================
#### Launch the container on a stand-alone Docker engine with the built-in /etc/logstash.conf file:
docker run -d --name my-logstash -p 514:514/udp -p 514:514 -p 127.0.0.1:9600:9600 my-logstash:1.0.0
## ==================================================
#### Launch the container on a stand-alone Docker engine using your custom logstash.conf file:
docker run -d --name my-logstash -p 514:514/udp -p 514:514 -p 127.0.0.1:9600:9600 -v /Your/Custom/logstash.conf:/etc/logstash.conf my-logstash:1.0.0
## ==================================================
#### Verify Logstash responds to API calls:
curl -XGET '127.0.0.1:9600/?pretty'
## ==================================================
#### Launch via docker-compose:
docker-compose up -d
## ==================================================
#### Deploy to a Docker Swarm:
docker stack deploy --compose-file=docker-compose.yml my-logstash
## ==================================================

