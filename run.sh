#!/bin/sh

CONSIDER_HOME=${CONSIDER_HOME:-10}

track_iphone()
{
  IP="$1"
  PRETTYNAME="$2"
  NAME="$(echo "$PRETTYNAME" | tr -d ' ' | tr '[:upper:]' '[:lower:]')"

  echo "Tracking '$PRETTYNAME' iPhone ($IP)"

  guest_status='not_home'
  guest_lastseen=0

  while true; do sleep 12
    config_cnt=20
    # Send config from time to time in case subscriber is reset.
    if [ $config_cnt -ge 20 ]; then
        config_cnt=0
        mosquitto_pub -h 127.0.0.1 -p 1883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" \
         -t "homeassistant/device_tracker/${NAME}/config" \
         -m '{"state_topic": "homeassistant/device_tracker/'"${NAME}"'/state", "name": "'"${PRETTYNAME}"'", "payload_home": "home", "payload_not_home": "not_home", "source_type": "router"}'
    else
        config_cnt=$((config_cnt+1))
    fi

    # IP
    hping3 -2 -c 3 -p 5353 "$IP" -q >/dev/null 2>&1
    if ip neigh show | grep REACHABLE | grep -q "$IP "; then
        guest_status='home'
        guest_lastseen=0
    else
        if [ $guest_lastseen -ge "$CONSIDER_HOME" ]; then
            guest_status='not_home'
        else
            guest_lastseen=$((guest_lastseen+1))
        fi
    fi
    mosquitto_pub -h 127.0.0.1 -p 1883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" \
     -t "homeassistant/device_tracker/${NAME}/state" \
     -m "$guest_status"
  done
  exit 1
}

while [ $# -gt 1 ]; do
  case $1 in
    -t|--target)
      IP="$2"
      NAME="$3"
      track_iphone "$IP" "$NAME" &
      shift # past argument
      shift
      shift
      ;;
    -u|--mqtt-user)
      MQTT_USER="$2"
      shift # past argument
      shift
      ;;
    -p|--mqtt-password)
      MQTT_PASSWORD="$2"
      shift # past argument
      shift
      ;;
    -h|--home)
      CONSIDER_HOME="$2"
      shift # past argument
      shift
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

wait

exit 1
