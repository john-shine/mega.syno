#!/bin/bash

rm -f /tmp/.X*-lock /tmp/.X11-unix/X*; [[ -z "${DISPLAY}" ]] || /usr/bin/vncserver -kill ${DISPLAY} && sleep 3

if [[ -d ${HOME}/MEGA ]]; then
    uid=$(stat -c '%u' ${HOME}/MEGA)
    gid=$(stat -c '%g' ${HOME}/MEGA)

    if getent passwd $uid > /dev/null 2>&1; then
        echo "user exists"
        gid_=$(id -g $uid)
        if [[ $gid -ne $gid_ ]]; then
            if getent group $gid > /dev/null 2>&1; then
                echo "group exists."
            else
                echo "group not exists."
                groupadd -g $gid -r "${USER}"
            fi
            usermod -d ${HOME} -g $gid -aG $gid -s /bin/bash -p {$USER} `id -un $uid`
        fi
    else
        echo "user not exist"
        if getent group $gid > /dev/null 2>&1; then
            echo "group exists."
        else
            echo "group not exists."
            groupadd -g $gid -r "${USER}"
        fi
        useradd -u $uid -d ${HOME} -g $gid -s /bin/bash -p ${USER} -r -N ${USER}
    fi


    chown -R $uid:$gid ${HOME}

    if [[ -z $vnc_password ]]; then
        su - -p -c "echo \"${vnc_password}\" | vncpasswd -f > ${HOME}/.vnc/passwd" `id -un $uid`
    fi

    if [[ -z $vnc_password ]]; then
        su - -p -c "/usr/bin/vncserver -geometry 1024x768 -fg -SecurityTypes None,TLSNone" `id -un $uid`
    else
        su - -p -c "/usr/bin/vncserver -geometry 1024x768 -fg" `id -un $uid`
    fi
else
    if [[ -z $vnc_password ]]; then
        echo "${vnc_password}" | vncpasswd -f > ${HOME}/.vnc/passwd
    fi

    if [[ -z $vnc_password ]]; then
        /usr/bin/vncserver -geometry 1024x768 -fg -SecurityTypes None,TLSNone
    else
        /usr/bin/vncserver -geometry 1024x768 -fg
    fi
fi
