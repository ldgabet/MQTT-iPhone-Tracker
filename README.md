# iphone-tracker
Track iPhone on the local network


## Usage

Docker compose:
```yaml
iphone-tracker:
    container_name: iphone-tracker
    image: ghcr.io/passific/iphone-tracker:latest
    restart: unless-stopped
    depends_on:
      - mosquitto
    network_mode: host # Needed for mDNS
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    environment:
      - MQTT_USER=mqttuser
      - MQTT_PASSWORD=mqttpwd
      - CONSIDER_HOME=10
    command: ["-t", "192.168.1.104", "iPhone 1", "-t", "192.168.1.105", "iPhone 2"]
```
