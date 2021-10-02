#!/bin/bash

#set -e

mkdir -p /config/log
CONF_FILE=/config/.configure

function init_settings(){
    if [ ! -f ${CONF_FILE} ]
    then
        initdb=1

        if [ -z $SOPDS_SECRET_KEY ]
        then
            SOPDS_SECRET_KEY=`python3 script/gen_secret_key.py`
        fi
        for e in ${!SOPDS*} ${!MYSQL*}
        do
            echo "export $e='${!e}'" >> ${CONF_FILE}
        done
    fi

    source ${CONF_FILE}

    if [ ! -z $initdb ]
    then
        init_db
    fi
}

function init_db() {
    if [ ! -z $MYSQL_DB ]
    then
        #INIT MySQL
        echo "**** Creating MySQL Databse. ****"
    	cat << EOF | mysql -uroot -p${MYSQL_ROOT_PASSWORD} --host ${MYSQL_HOST} mysql
create database if not exists $MYSQL_DB default charset=utf8;
grant all on ${MYSQL_DB}.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}';
commit;
EOF
    elif [ ! -z $POSTGRES_DB ]
    then
        #INIT POSTGRES
        echo "NONE!"
    fi

    echo "**** Initialize the database ****"
    python3 manage.py migrate
    echo "**** Fill in the initial data (genres) ****"
    python3 manage.py sopds_util clear

    echo "**** Creating a Superuser ****"
    python3 script/create_super_user.py

    echo "**** Adjust the path to catalog with books ****"
    python3 manage.py sopds_util setconf SOPDS_ROOT_LIB ${SOPDS_ROOT_LIB}

    echo "**** Switch the interface language to ${SOPDS_LANGUAGE} ****"
    python3 manage.py sopds_util setconf SOPDS_LANGUAGE ${SOPDS_LANGUAGE}

    echo "**** BASIC - authorization to ${SOPDS_AUTH} ****"
    python3 manage.py sopds_util setconf SOPDS_AUTH ${SOPDS_AUTH}

    if [ ! -z $SOPDS_TELEBOT_API_TOKEN ]
    then
        echo "**** Configure Telegram-bot ****"
    	python3 manage.py sopds_util setconf SOPDS_TELEBOT_API_TOKEN ${SOPDS_TELEBOT_API_TOKEN}
	    python3 manage.py sopds_util setconf SOPDS_TELEBOT_AUTH ${SOPDS_TELEBOT_AUTH}
    fi

    echo "**** Generation Static file for NGINX ****"
    python3 manage.py collectstatic --clear --no-input

    echo "**** Start Scan library ****"
    python3 manage.py sopds_util setconf SOPDS_SCAN_START_DIRECTLY True
    return 0
}

init_settings

case "$1" in
start)
    #To start the Telegram-bot if it enabled
    if [ ! -z $SOPDS_TELEBOT_API_TOKEN ]
    then
        echo "**** Run Telegram-bot ****"
	python3 manage.py sopds_telebot start --daemon
    fi

    echo "**** Run Scaner ****"
    python3 manage.py sopds_scanner start --daemon
    echo "**** Run Server ****"
    #python3 manage.py sopds_server start
    gunicorn -c gunicorn.py sopds.wsgi
    ;;
log)
    if [ ! -z $SOPDS_TELEBOT_API_TOKEN ]
    then
	TELEBOT_LOG=$(python3 manage.py sopds_util getconf SOPDS_TELEBOT_LOG)
    fi
    tail -f \
        $(python3 manage.py sopds_util getconf SOPDS_SERVER_LOG) \
        $(python3 manage.py sopds_util getconf SOPDS_SCANNER_LOG) $TELEBOT_LOG
    ;;
scannow)
    python3 manage.py sopds_util setconf SOPDS_SCAN_START_DIRECTLY True
;;
*)
    "$@"
    ;;
esac
