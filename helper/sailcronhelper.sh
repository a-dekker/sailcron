#!/bin/bash
#

check_params ()
{
    LINE_NBR=$2
    CRON_USER=$3
    CRON_FILE="/var/cron/tabs/${CRON_USER}"
    case "$1" in
        "readcron")
            CRON_USER=$2
            get_cron_data
            ;;
        "disable")
            disable_entry
            ;;
        "enable")
            enable_entry
            ;;
        "delete")
            delete_entry
            ;;
        "append")
            CRON_COMMAND=$(echo $2|base64 --decode)
            EXEC_COMMAND=$(echo $4|base64 --decode)
            append_entry
            ;;
        "edit")
            CRON_COMMAND=$(echo $4|base64 --decode)
            EXEC_COMMAND=$(echo $5|base64 --decode|sed -e 's/[\/&]/\\&/g')
            edit_entry
            ;;
        "start_cron")
            start_cron_service
            ;;
        "stop_cron")
            stop_cron_service
            ;;
        "enable_cron")
            enable_cron_service
            ;;
        "disable_cron")
            disable_cron_service
            ;;
        "isEnabled")
            check_cron_service isEnabled
            ;;
        "isStarted")
            check_cron_service isStarted
            ;;
        *)
            echo "Unknown call"
            exit 1
            ;;
    esac
}

get_cron_data ()
{
    if [ -z "${CRON_USER}" ]
    then
        echo "No user specified"
        exit 1
    fi
    # also exclude environment settings
    crontab -l -u ${CRON_USER}|awk '{ if (index($0, "# Disabled by Sailcron ") != 0) print "false|" substr($0,24); else print "true|"$0 }'|grep -nv "^true| \?#"|sed -e 's/ /|/1' -e 's/ /|/1' -e 's/ /|/1' -e 's/ /|/1' -e 's/ /|/1'|sed "s/:/|/"|grep -v "\w*.=.*$"|base64
}

disable_entry ()
{
    sed -i -r "${LINE_NBR}s/^.{0}/&# Disabled by Sailcron /" ${CRON_FILE}
}

enable_entry ()
{
    sed -i -r "${LINE_NBR}s/(.{0}).{23}/\1/" ${CRON_FILE}
}

delete_entry ()
{
    sed -i "${LINE_NBR}d" ${CRON_FILE}
}

append_entry ()
{
    echo "${CRON_COMMAND} ${EXEC_COMMAND}" >> ${CRON_FILE}
}

edit_entry ()
{
    set -f
    sed -i -r "${LINE_NBR}s/.*$/${CRON_COMMAND} ${EXEC_COMMAND}/" ${CRON_FILE} 2>&1
    echo "${LINE_NBR} ${CRON_COMMAND} ${EXEC_COMMAND} ${CRON_FILE}"
}

start_cron_service ()
{
    /bin/systemctl start cron.service
    EXIT_CODE=$?
}

stop_cron_service ()
{
    /bin/systemctl stop cron.service
    EXIT_CODE=$?
}

disable_cron_service ()
{
    /bin/systemctl disable cron.service
    EXIT_CODE=$?
}

enable_cron_service ()
{
    /bin/systemctl enable cron.service
    EXIT_CODE=$?
}

check_cron_service ()
{
    case "$1" in
        "isEnabled")
            RESULT=$(/bin/systemctl is-enabled cron)
            printf ${RESULT}
            ;;
        "isStarted")
            /bin/systemctl status cron >/dev/null 2>&1
            EXIT_CODE=$?
            if [ ${EXIT_CODE} -eq 0 ]
            then
                printf "true"
            else
                printf "false"
            fi
            ;;
    esac
}

main ()
{
    check_params $@
}

if [ ! -t 1 ]
then
    main $@
fi
