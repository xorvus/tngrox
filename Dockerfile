FROM rockylinux:9

ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN dnf -y upgrade --refresh && \
    dnf -y install openssh-server wget unzip vim curl python3 iproute --allowerasing && \
    dnf clean all

# Install ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O /ngrok.zip && \
    unzip /ngrok.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok && \
    rm -f /ngrok.zip

# SSH config
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "root:changeme123" | chpasswd

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set default password dan paksa ganti saat login
RUN echo "root:changeme123" | chpasswd && \
    chage -d 0 root

EXPOSE 22 4040
CMD ["/entrypoint.sh"]