#!/bin/bash

# Validasi NGROK_TOKEN
if [ -z "$NGROK_TOKEN" ]; then
  echo "❌ ERROR: Environment variable NGROK_TOKEN belum diset."
  exit 1
fi

# Set region default jika tidak ada
REGION=${REGION:-ap}

# Jalankan ngrok untuk port SSH (22)
echo "🟡 Menjalankan ngrok..."
/usr/local/bin/ngrok tcp --authtoken "$NGROK_TOKEN" --region "$REGION" 22 &

# Tunggu ngrok aktif
sleep 5

# Ambil informasi tunnel dari ngrok
TUNNEL_INFO=$(curl -s http://localhost:4040/api/tunnels)
SSH_ADDRESS=$(echo "$TUNNEL_INFO" | python3 -c "import sys, json; j=json.load(sys.stdin); print(j['tunnels'][0]['public_url'][6:].replace(':', ' -p '))" 2>/dev/null)

if [ -z "$SSH_ADDRESS" ]; then
  echo "❌ Gagal mendapatkan alamat SSH dari ngrok."
else
  echo -e "\n✅ SSH Siap Digunakan:"
  echo -e "👉 ssh root@$SSH_ADDRESS"
  echo -e "🔐 Password sementara: changeme123 (akan diminta ganti setelah login)"
fi

# Jalankan SSH server
/usr/sbin/sshd -D
