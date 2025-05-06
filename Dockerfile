FROM debian

ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y \
    openssh-server wget unzip vim curl python3 && \
    apt clean

# Download Ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O /ngrok-stable-linux-amd64.zip\
    && cd / && unzip ngrok-stable-linux-amd64.zip \
    && chmod +x ngrok

# SSH configuration
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "root:changeme123" | chpasswd

# Entrypoint script (moved SSH key generation here)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set default password dan paksa ganti saat login
RUN echo "root:changeme123" | chpasswd && \
    chage -d 0 root

EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000
CMD ["/entrypoint.sh"]