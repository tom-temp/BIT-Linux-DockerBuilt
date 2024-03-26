FROM ghcr.io/void-linux/void-glibc-full

ARG PORT="18022"

RUN cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
RUN set -xe && xbps-install -S

# install
# need other package
RUN set -xe && xbps-install -y glibc-locales ncurses git bash curl wget vim dust unzip ripgrep fd openssh dcron rclone

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


# manba install
# ==================================
# need change
RUN mkdir -p /opt/app-shell/_env_/mamba/
RUN mkdir -p /opt/work/daily-detial/

ENV CONDA_DIR=/opt/app-shell/_env_/mamba/
ENV PATH=$CONDA_DIR/bin:$PATH

ARG CONDA_VERSION="24.1.2"
ARG MINIFORGE_PATCH_NUMBER="0"
ARG MINIFORGE_TYPE="Miniforge3"
ARG MINIFORGE_VERSION="${CONDA_VERSION}-${MINIFORGE_PATCH_NUMBER}"
ARG MINIFORGE_INSTALLER="${MINIFORGE_TYPE}-${MINIFORGE_VERSION}-Linux-aarch64.sh"
# ARG MINIFORGE_INSTALLER="${MINIFORGE_TYPE}-${MINIFORGE_VERSION}-Linux-x86_64.sh"

WORKDIR /opt
RUN set -xe && \
    wget --quiet "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${MINIFORGE_INSTALLER}" && \
    chmod +x ${MINIFORGE_INSTALLER} && \
    /bin/bash "${MINIFORGE_INSTALLER}" -f -b -p $CONDA_DIR && \
    rm ${MINIFORGE_INSTALLER}
# echo "${MINIFORGE_CHECKSUM} *${MINIFORGE_INSTALLER}" | sha256sum --check && \ # make a note


RUN set -xe && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true

# set VENV, needchange
RUN set -xe && \
    conda create -n excel python=3.8.16 pandas=1.5.3 xlrd=2.0.1 -y


EXPOSE 18022
ENTRYPOINT  ["/bin/bash", "-c", "/start.sh"]

