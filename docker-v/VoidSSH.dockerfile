FROM ghcr.io/void-linux/void-glibc-full

ARG PORT="18022"

RUN cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
RUN set -xe && xbps-install -S

# install
# need other package
RUN set -xe && xbps-install -y ncurses git bash curl wget vim dust unzip xz ripgrep fd openssh dcron exa zoxide procs glow starship atuin stow 
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

RUN useradd tom && echo 'tom:tom' |chpasswd

RUN ssh-keygen -A

# start script
#==============================
RUN echo "#!/bin/bash"                                            >  /start.sh
RUN echo "echo log start: $(date '+%Y-%m-%d %H:%m') >> /log.log"  >> /start.sh
RUN echo "/usr/sbin/sshd  -E /log.log"                            >> /start.sh
Run echo "/usr/sbin/crond -L /log.log"                            >> /start.sh
RUN echo "tail -f /log.log"                                       >> /start.sh
RUN chmod +x /start.sh

# config for tom
#==============================
USER tom
WORKDIR /home/tom
RUN set -xe && \
    git clone --depth=1 https://github.com/tom-temp/linux-dotfiles.git ./linux-dotfiles && \
    git clone https://github.com/tmux-plugins/tpm /home/tom/.tmux/plugins/tpm && \
    wget -O - https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf - && \
    bash ble-nightly/ble.sh --install ~/.local/share
WORKDIR /home/tom/linux-dotfiles
RUN set -xe && \
    stow vim && \
    stow tmux && \
    mkdir -p /home/tom/.local/bin/ && \
    ln -s /home/tom/.config/tmux/layout.default.sh /home/tom/.local/bin/tm && \
    mv /home/tom/.bashrc /home/tom/bashrc.bac
    stow bash

USER root
EXPOSE 18022
ENTRYPOINT  ["/bin/bash", "-c", "/start.sh"]

