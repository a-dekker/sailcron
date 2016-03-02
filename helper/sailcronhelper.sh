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
            SEP='[~][s][e][p][a][r][a][t][o][r][~]'
            CRON_COMMAND=$(echo $2|base64 --decode)
            EXEC_COMMAND=$(echo $4|awk -F ${SEP} '{print $1'}|base64 --decode)
            ALIAS_COMMAND=$(echo $4|awk -F ${SEP} '{print $2'}|base64 --decode)
            EXEC_COMMAND_B64=$(echo $4|awk -F ${SEP} '{print $1'})
            ALIAS_COMMAND_B64=$(echo $4|awk -F ${SEP} '{print $2'})
            append_entry
            ;;
        "edit")
            SEP='[~][s][e][p][a][r][a][t][o][r][~]'
            CRON_COMMAND=$(echo $4|base64 --decode)
            EXEC_COMMAND=$(echo $5|awk -F ${SEP} '{print $1'}|base64 --decode|sed -e 's/[\/&]/\\&/g')
            ALIAS_COMMAND=$(echo $5|awk -F ${SEP} '{print $2'}|base64 --decode|sed -e 's/[\/&]/\\&/g')
            EXEC_COMMAND_B64=$(echo $5|awk -F ${SEP} '{print $1'})
            ALIAS_COMMAND_B64=$(echo $5|awk -F ${SEP} '{print $2'})
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
        "readalias")
            CRON_ALIAS=$2
            read_alias
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
    crontab -l -u ${CRON_USER}|awk '{ if (index($0, "# Disabled by Sailcron ") != 0) \
        print "false~|" substr($0,24); else print "true~|"$0 }'|grep -nv "^true~| \?#"| \
        sed -e 's/ /~|/1' -e 's/ /~|/1' -e 's/ /~|/1' -e 's/ /~|/1' -e 's/ /~|/1'| \
        sed "s/:/~|/"|egrep -v "[0-9]+~\|(true|false)~\|[a-zA-Z]"|base64
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

add_alias ()
{
    if [ ! -z "${ALIAS_COMMAND}" ]
    then
        # see if alias is already added
        grep -q "${EXEC_COMMAND_B64}~separator~${ALIAS_COMMAND_B64}" ${ALIAS_FILE}
        if [ $? -ne 0 ]
        then
            echo "${EXEC_COMMAND_B64}~separator~${ALIAS_COMMAND_B64}" >> ${ALIAS_FILE}
        fi
    fi
}

append_entry ()
{
    echo "${CRON_COMMAND} ${EXEC_COMMAND}" >> ${CRON_FILE}
    add_alias
}

edit_entry ()
{
    set -f
    sed -i -r "${LINE_NBR}s/.*$/${CRON_COMMAND} ${EXEC_COMMAND}/" ${CRON_FILE} 2>&1
    echo "${LINE_NBR} ${CRON_COMMAND} ${EXEC_COMMAND} ${CRON_FILE}"
    # remove any existing alias entry
    LINE_NBR=$(grep -n "${EXEC_COMMAND_B64}~separator~" ${ALIAS_FILE}|cut -f1 -d:)
    if [ ! -z "${LINE_NBR}" ]
    then
        sed -i "${LINE_NBR}d" ${ALIAS_FILE}
    fi
    add_alias
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

read_alias ()
{
    SEP='[~][s][e][p][a][r][a][t][o][r][~]'
    ALIAS_LINE=$(grep ${CRON_ALIAS} ${ALIAS_FILE}|head -1)
    # echo "${CRON_ALIAS}"|base64 --decode
    # echo "alias_line: ${ALIAS_LINE}"
    ALIAS_VALUE=$(echo ${ALIAS_LINE}|awk -F ${SEP} '{print $2'}|base64 --decode|sed -e 's/[\/&]/\\&/g')
    printf "${ALIAS_VALUE}"
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
    CONFIG_DIR="/home/nemo/.config/harbour-sailcron"
    ALIAS_FILE="${CONFIG_DIR}/cron_command_alias.txt"
    if [ ! -d "${CONFIG_DIR}" ]
    then
        mkdir ${CONFIG_DIR}
        chown nemo:nemo ${CONFIG_DIR}
    fi
    if [ ! -f "${CONFIG_DIR}/cron_command_alias.txt" ]
    then
        touch ${ALIAS_FILE}
        chown nemo:nemo ${ALIAS_FILE}
    fi
    check_params $@
}

if [ ! -t 1 ]
then
    main $@
fi
