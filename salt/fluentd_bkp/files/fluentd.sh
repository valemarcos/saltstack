#!/bin/bash

PIDFILE=/var/run/fluentd.pid

start () {
    /usr/local/bin/fluentd -c /etc/fluent/fluent.conf -d $PIDFILE
}

stop () {
    if [ -e $PIDFILE ]
    then
        /bin/kill $(cat $PIDFILE)
    else
        echo 'FluentD is not running'
    fi
}

reload () {
    if [ -e $PIDFILE ]
    then
        /bin/kill -1 $(cat $PIDFILE)
    else
        echo 'FluentD is not running'
    fi
}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload)
        reload
        ;;
    restart)
        stop
        sleep 1
        start
        ;;
    *) exit 1
esac
