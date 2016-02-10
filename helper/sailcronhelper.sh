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
    crontab -l -u ${CRON_USER}|awk '{ if (index($0, "# Disabled by Sailcron ") != 0) print "false|" substr($0,24); else print "true|"$0 }'|grep -nv "^true| \?#"|sed -e 's/ /|/1' -e 's/ /|/1' -e 's/ /|/1' -e 's/ /|/1' -e 's/ /|/1'|sed "s/:/|/"|base64
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

main ()
{
    check_params $@
}

if [ ! -t 1 ]
then
    main $@
fi
