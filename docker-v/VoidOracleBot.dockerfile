FROM ghcr.io/void-linux/void-glibc-full

ARG PORT="18022"

RUN cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
RUN set -xe && xbps-install -S

# install
# need other package
RUN set -xe && xbps-install -y ncurses git bash curl wget vim dust unzip ripgrep fd openssh dcron rclone
#  RUN set -xe && xbps-install -y glibc-locales

# timezone
RUN ln -sf /usr/share/zoneinfo/Hongkong /etc/localtime
# RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/default/libc-locales
# RUN echo "LANG=zh_CN.UTF-8" >> /etc/locale.conf
# RUN echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# RUN echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
# RUN xbps-reconfigure -a -f

# ssh config
#===========================
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri "s/^#?Port\s+.*/Port ${PORT}/" /etc/ssh/sshd_config

RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo 'root:root' | chpasswd

RUN useradd tom && echo 'tom:tom' | chpasswd && \
    mkdir -p /home/tom && \
    chown tom:tom /home/tom -R && \
    mkdir -p /tmp &&\
    chmod 777 /tmp

RUN ssh-keygen -A

# start script
# ==================================
COPY VoidOracleBotStart.sh /start.sh
RUN chmod +x /start.sh
WORKDIR /opt



# environment
# ===================================
xbps-install -y openjdk17

EXPOSE 18022
ENTRYPOINT  ["/bin/bash", "-c", "/start.sh"]

