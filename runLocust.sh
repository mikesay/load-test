#!/bin/bash
#
# Run locust load test
#
#####################################################################
ARGS="$@"
HOST="${1}"
SCRIPT_NAME=`basename "$0"`
INITIAL_DELAY=1
TARGET_HOST="$HOST"
CLIENTS=5
SPAWN_RATE=1

do_check() {

  # check hostname is not empty
  if [ "${TARGET_HOST}x" == "x" ]; then
    echo "TARGET_HOST is not set; use '-h http(s)://hostname:port'"
    exit 1
  fi

  # check for locust
  if [ ! `command -v locust` ]; then
    echo "Python 'locust' package is not found!"
    exit 1
  fi

  # check locust file is present
  if [ -n "${LOCUST_FILE:+1}" ]; then
  	echo "Locust file: $LOCUST_FILE"
  else
  	LOCUST_FILE="locustfile.py" 
  	echo "Default Locust file: $LOCUST_FILE" 
  fi
}

do_exec() {
  sleep $INITIAL_DELAY

  # check if host is running
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${TARGET_HOST}) 
  if [ $STATUS -ne 200 ]; then
      echo "${TARGET_HOST} is not accessible"
      exit 1
  fi

  echo "Will run $LOCUST_FILE against $TARGET_HOST. Spawning $CLIENTS clients to request the website in $RUN_TIME."
  locust --host=$TARGET_HOST -f $LOCUST_FILE --users=$CLIENTS -r $SPAWN_RATE --run-time=$RUN_TIME --headless --only-summary
  echo "done"
}

do_usage() {
    cat >&2 <<EOF
Usage:
  ${SCRIPT_NAME} [ hostname ] OPTIONS

Options:
  -d  Delay before starting
  -h  Target host url, e.g. http://localhost, or https://localhost, or http://localhost:8080
  -c  Number of clients (default 5)
  -r  Rate to spawn users (users per second, default 1)
  -t  Stop after the specified amount of time, e.g. (300s, 20m, 3h, 1h30m, etc.)

Description:
  Runs a Locust load simulation against specified host.

EOF
  exit 1
}



while getopts ":d:h:c:r:t:" o; do
  case "${o}" in
    d)
        INITIAL_DELAY=${OPTARG}
        #echo $INITIAL_DELAY
        ;;
    h)
        TARGET_HOST=${OPTARG}
        #echo $TARGET_HOST
        ;;
    c)
        CLIENTS=${OPTARG:-5}
        #echo $CLIENTS
        ;;
    r)
        SPAWN_RATE=${OPTARG:-1}
        #echo $SPAWN_RATE
        ;;
    t)
        RUN_TIME=${OPTARG:-300s}
        #echo $RUN_TIME
        ;;
    *)
        do_usage
        ;;
  esac
done


do_check
do_exec
