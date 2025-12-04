FROM ubuntu:rolling

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000

ENV container=docker \
    LC_ALL=C \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        openssh-server nano net-tools bash-completion dnsutils sudo \
        systemd systemd-sysv git python3 python3-pip locales curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    locale-gen en_US.UTF-8

RUN cd /lib/systemd/system/sysinit.target.wants && \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f && \
    rm -f \
        /lib/systemd/system/multi-user.target.wants/* \
        /etc/systemd/system/*.wants/* \
        /lib/systemd/system/local-fs.target.wants/* \
        /lib/systemd/system/sockets.target.wants/*udev* \
        /lib/systemd/system/sockets.target.wants/*initctl* \
        /lib/systemd/system/basic.target.wants/* \
        /lib/systemd/system/anaconda.target.wants/* \
        /lib/systemd/system/plymouth* \
        /lib/systemd/system/systemd-update-utmp*

RUN curl -fsSL https://get.docker.com | bash

RUN deluser ubuntu 2>/dev/null || true && \
    useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    usermod -aG docker $USERNAME && \
    echo "$USERNAME:ruse" | chpasswd

RUN systemctl enable ssh docker && \
    systemctl set-default multi-user.target && \
    ln -sf /lib/systemd/system/systemd-user-sessions.service \
       /etc/systemd/system/multi-user.target.wants/

CMD ["/lib/systemd/systemd"]
