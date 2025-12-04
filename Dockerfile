# Ubuntu 22.04 + SSH + playit (Railway-safe)
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. base + ssh + tools
RUN apt-get update && apt-get install -y \
      openssh-server nano vim curl wget net-tools dnsutils iputils-ping \
      htop git python3 python3-pip unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. download playit latest (GitHub release)
RUN wget -q https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-x86_64.tar.gz -O /playit.tgz && \
    cd / && tar -xvf playit.tgz && rm playit.tgz && chmod +x playit

# 3. SSH setup
RUN mkdir -p /run/sshd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'root:kelvin123' | chpasswd && \
    ssh-keygen -A

# 4. startup script
RUN printf '#!/bin/bash\n\
/playit &\n\
/usr/sbin/sshd -D\n' > /start.sh && chmod +x /start.sh

EXPOSE 22
CMD ["/start.sh"]
