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

#RUN yum check-update -y ; \
#    yum install -y --setopt=tsflags=nodocs tigervnc-server xorg-x11-server-utils xorg-x11-server-Xvfb xorg-x11-fonts-* motif xterm && \
#    yum install -y --setopt=tsflags=nodocs sudo which wget && \
#    wget --no-check-certificate https://raw.githubusercontent.com/john-shine/mega.syno/master/rpms/LibRaw-0.14.8-5.el7.20120830git98d925.x86_64.rpm -O /tmp/LibRaw-0.14.8-5.x86_64.rpm && \
#    yum localinstall -y /tmp/LibRaw-0.14.8-5.x86_64.rpm && \
#    wget --no-check-certificate https://mega.nz/linux/MEGAsync/CentOS_7/x86_64/megasync-CentOS_7.x86_64.rpm -O /tmp/megasync-CentOS_7.x86_64.rpm && \
#    yum localinstall -y --setopt=tsflags=nodocs --nogpgcheck /tmp/megasync-CentOS_7.x86_64.rpm && \
#    /bin/echo -e "\n${USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers && \
#    yum clean all && rm -rf /var/cache/yum/* && rm -f /tmp/megasync-CentOS_7.x86_64.rpm /tmp/LibRaw-0.14.8-5.x86_64.rpm

RUN curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
RUN    yum check-update -y ; exit 0
RUN    yum  groupinstall -y --setopt=tsflags=nodocs xfce 
RUN    yum install -y --setopt=tsflags=nodocs tigervnc-server xorg-x11-server-utils xorg-x11-server-Xvfb xorg-x11-fonts-* motif sudo
RUN    yum clean all && rm -rf /var/cache/yum/* 
RUN yum install -y --setopt=tsflags=nodocs wget git
RUN wget https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz -O /tmp/noVNC.tar.gz
RUN tar -zxvf /tmp/noVNC.tar.gz -C /opt
RUN git clone https://github.com/novnc/websockify /opt/noVNC-1.1.0/utils/websockify
RUN mv /opt/noVNC-1.1.0/vnc_lite.html /opt/noVNC-1.1.0/index.html
RUN rm -f /tmp/noVNC.tar.gz

RUN /bin/echo -e "\n${USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

#RUN curl --insecure https://mega.nz/linux/MEGAsync/CentOS_7/x86_64/megasync-CentOS_7.x86_64.rpm -o /tmp/megasync-CentOS_7.x86_64.rpm && \
RUN curl --insecure http://192.168.1.169/megasync-CentOS_7.x86_64.rpm -o /tmp/megasync-CentOS_7.x86_64.rpm && \
    yum localinstall -y --setopt=tsflags=nodocs --nogpgcheck /tmp/megasync-CentOS_7.x86_64.rpm && \
    rm -f /tmp/megasync-CentOS_7.x86_64.rpm

ADD dist/tray /usr/local/bin/

RUN /bin/dbus-uuidgen --ensure
RUN useradd -r -m -d ${HOME} -s /bin/bash -G 'root' ${USER}
RUN echo "root:root" | chpasswd
# set password of ${USER} to ${USER}
RUN echo "${USER}:${USER}" | chpasswd
# WORKDIR ${HOME}
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
 
ENTRYPOINT ["/entrypoint.sh"]

RUN mkdir -p ${HOME}/.vnc/
RUN chown -R ${USER}:${USER} ${HOME}

USER ${USER}

ADD xstartup ${HOME}/.vnc/xstartup
RUN touch ${HOME}/.vnc/passwd ${HOME}/.Xauthority
 
RUN sudo chown ${USER}:'root' ${HOME}/.vnc/xstartup && \
    sudo chmod 600 ${HOME}/.vnc/passwd

# Always run the WM last!
RUN /bin/echo -e "export DISPLAY=${DISPLAY}"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "[ -r ${HOME}/.Xresources ] && xrdb ${HOME}/.Xresources\nxsetroot -solid grey"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "/opt/noVNC-1.1.0/utils/launch.sh --listen 6080 --vnc 127.0.0.1:5901 &"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "/usr/local/bin/tray &"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "/usr/bin/megasync &"  >> ${HOME}/.vnc/xstartup
RUN /bin/echo -e "tailf /dev/null"  >> ${HOME}/.vnc/xstartup

RUN /bin/echo -e 'alias ll="ls -last"' >> ${HOME}/.bashrc
