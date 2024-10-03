# iphone-tracker
Track iPhone on the local network


## Usage

Docker compose:
```yaml
iphone-tracker:
    container_name: iphone-tracker
    build:
      context: https://github.com/Passific/iphone-tracker.git
      args:
        - BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
        - BUILD_VERSION="1.0.1"
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
