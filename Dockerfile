FROM rockylinux:9
ARG NGROK_TOKEN
ARG REGION=ap
ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN dnf -y update && dnf -y install \
    openssh-server wget unzip vim curl python3 iproute \
    && dnf clean all

# Setup Ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O /ngrok.zip && \
    unzip /ngrok.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok && \
    rm -f /ngrok.zip

# Prepare SSH and Ngrok
RUN mkdir -p /var/run/sshd && \
    echo "/usr/local/bin/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 22 &" >> /openssh.sh && \
    echo "sleep 5" >> /openssh.sh && \
    echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"ssh info:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT Password:craxid\\\")\" || echo \"\\nError：NGROK_TOKEN tidak valid.\\n\"" >> /openssh.sh && \
    echo "/usr/sbin/sshd -D" >> /openssh.sh && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo root:sV25.33gIZ>fd.jT | chpasswd && \
    chmod +x /openssh.sh

EXPOSE 22 4040
CMD ["/openssh.sh"]
