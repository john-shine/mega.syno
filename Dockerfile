# Using CentOS 7 base image and VNC

FROM centos:7
MAINTAINER john.shine <mr.john.shine@gmail.com>
LABEL io.openshift.expose-services="5901:tcp"

USER root

ENV DISPLAY=":1"
ENV USER="mega"
ENV HOME=/home/${USER}
ARG vnc_password=""
EXPOSE 5901

RUN yum check-update -y ; \
    yum install -y --setopt=tsflags=nodocs tigervnc-server xorg-x11-server-utils xorg-x11-server-Xvfb xorg-x11-fonts-* motif xterm && \
    yum install -y --setopt=tsflags=nodocs sudo which wget && \
    wget --no-check-certificate https://mega.nz/linux/MEGAsync/CentOS_7/x86_64/megasync-CentOS_7.x86_64.rpm -O /tmp/megasync-CentOS_7.x86_64.rpm && \
    yum localinstall -y --setopt=tsflags=nodocs --nogpgcheck /tmp/megasync-CentOS_7.x86_64.rpm && \
    /bin/echo -e "\n${USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers && \
    yum clean all && rm -rf /var/cache/yum/* && rm -f /tmp/megasync-CentOS_7.x86_64.rpm

RUN /bin/dbus-uuidgen --ensure
RUN useradd -r -m -d ${HOME} -s /bin/bash -G 'root' ${USER}
RUN echo "root:root" | chpasswd
# set password of ${USER} to ${USER}
RUN echo "${USER}:${USER}" | chpasswd
# WORKDIR ${HOME}
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
 
ENTRYPOINT ["/entrypoint.sh"]

USER ${USER}

RUN mkdir -p ${HOME}/.vnc/
ADD xstartup ${HOME}/.vnc/xstartup
RUN touch ${HOME}/.vnc/passwd ${HOME}/.Xauthority
 
RUN sudo chown ${USER}:'root' ${HOME}/.vnc/xstartup && \
    sudo chmod 600 ${HOME}/.vnc/passwd

# Always run the WM last!
RUN /bin/echo -e "export DISPLAY=${DISPLAY}"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "[ -r ${HOME}/.Xresources ] && xrdb ${HOME}/.Xresources\nxsetroot -solid grey"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "megasync"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "tailf /dev/null"  >> ${HOME}/.vnc/xstartup

RUN /bin/echo -e 'alias ll="ls -last"' >> ${HOME}/.bashrc
