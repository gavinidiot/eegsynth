#!/bin/bash

PATH=/sbin:/bin:/usr/bin:/usr/local/bin

# include library with helper functions
. "$(dirname "$0")/../../lib/EEGsynth.sh"

DIR=`dirname "$0"`
NAME=`basename "$0" .sh`
BINDIR=$DIR/../../bin

# helper files are stored in the directory containing this script
PIDFILE="$DIR"/"$NAME".pid
LOGFILE="$DIR"/"$NAME".log
INIFILE="$DIR"/"$NAME".ini

# Include library to parse ini file
. "$(dirname "$0")/../../lib/shini.sh"

# Declare the required handler for parsed variables, this creates local variables
__shini_parsed()
{
export $1_$2=$3
}

shini_parse $INIFILE

COMMAND="$BINDIR/jaga2ft"
OPTIONS="$fieldtrip_hostname $fieldtrip_port"

do_start () {
  status_led red
  log_action_msg "Starting $NAME"
  check_running_process && log_action_err "Error: $NAME is already started" && exit 1
  # start the process in the background
  date > "$LOGFILE"
  ( "$COMMAND" $OPTIONS >> "$LOGFILE" ) &
  echo $! > "$PIDFILE"
  status_led green
}

do_stop () {
  log_action_msg "Stopping $NAME"
  check_running_process || log_action_err "Error: $NAME is already stopped"
  check_running_process || exit 1
  kill -9 `cat "$PIDFILE"`
  rm "$PIDFILE"
}

do_status () {
  check_running_process && YESNO=" " || YESNO=" not "
  log_action_msg "$NAME is${YESNO}running"
}

case "$1" in
  start)
        do_start
        ;;
  restart)
        check_running_process && do_stop
        do_start
        ;;
  stop)
        do_stop
        ;;
  status)
        do_status
        ;;
  *)
        echo "Usage: $0 start|stop|restart|status" >&2
        exit 3
        ;;
esac