# Using CentOS 7 base image and VNC

FROM centos:7
MAINTAINER john.shine <mr.john.shine@gmail.com>
LABEL io.openshift.expose-services="5901:tcp"

USER root

ENV DISPLAY=":1"
ENV USER="mega"
ENV HOME=/home/${USER}
ARG vnc_password=""
EXPOSE 5901 6080

RUN yum check-update -y ; \
    yum install -y --setopt=tsflags=nodocs tigervnc-server epel-release && \
    yum install -y --setopt=tsflags=nodocs sudo git fluxbox && \
    yum clean all && rm -rf /var/cache/yum/*
RUN curl -k https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz -o /tmp/noVNC.tar.gz
RUN tar -zxvf /tmp/noVNC.tar.gz -C /opt
RUN git clone https://github.com/novnc/websockify /opt/noVNC-1.1.0/utils/websockify
RUN mv /opt/noVNC-1.1.0/vnc_lite.html /opt/noVNC-1.1.0/index.html && \
    sed -i 's/<title>noVNC<\/title>/<title>MEGAsync Client<\/title>/g' /opt/noVNC-1.1.0/index.html
RUN rm -f /tmp/noVNC.tar.gz

RUN /bin/echo -e "\n${USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

RUN curl -k https://raw.githubusercontent.com/john-shine/mega.syno/master/rpms/LibRaw-0.14.8-5.el7.20120830git98d925.x86_64.rpm -o /tmp/LibRaw-0.14.8-5.x86_64.rpm
RUN curl -k https://mega.nz/linux/MEGAsync/CentOS_7/x86_64/megasync-CentOS_7.x86_64.rpm -o /tmp/megasync-CentOS_7.x86_64.rpm && \
RUN yum localinstall -y --setopt=tsflags=nodocs --nogpgcheck /tmp/LibRaw-0.14.8-5.x86_64.rpm /tmp/megasync-CentOS_7.x86_64.rpm && \
    rm -rf /tmp/megasync-CentOS_7.x86_64.rpm /tmp/LibRaw-0.14.8-5.x86_64.rpm

RUN /bin/dbus-uuidgen --ensure
# set password of root to root
RUN echo "root:root" | chpasswd
# WORKDIR ${HOME}
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
 
ENTRYPOINT ["/entrypoint.sh"]

RUN mkdir -p ${HOME}/.vnc/ ${HOME}/.fluxbox/
ADD xstartup ${HOME}/.vnc/xstartup

RUN touch ${HOME}/.vnc/passwd ${HOME}/.Xauthority && \
    chmod 600 ${HOME}/.vnc/passwd

RUN /bin/echo -e 'alias ll="ls -last"' >> ${HOME}/.bashrc
RUN /bin/echo -e "session.screen0.toolbar.placement: TopCenter" >> ${HOME}/.fluxbox/init
# Always run the WM last!
RUN /bin/echo -e "export DISPLAY=${DISPLAY}" >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "[ -r ${HOME}/.Xresources ] && xrdb ${HOME}/.Xresources\nxsetroot -solid grey" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "fluxbox &" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "sleep 3" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "sed -i ':a;N;\$!ba;s/      \[exec\] (xterm) {xterm}\n//' ~/.fluxbox/menu" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "sed -i 's/\[exec\] (firefox) {}/\[exec\] (mega) {\/usr\/bin\/megasync}/' ~/.fluxbox/menu" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "/opt/noVNC-1.1.0/utils/launch.sh --listen 6080 --vnc 127.0.0.1:5901 &" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "while true; do" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "    /usr/bin/megasync" >> ${HOME}/.vnc/xstartup
RUN /bin/echo "done" >> ${HOME}/.vnc/xstartup

