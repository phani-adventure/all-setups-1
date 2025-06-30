#!/bin/bash
set -e

# Configuration
NEXUS_VERSION="3.77.2-02"
ARCHIVE="nexus-${NEXUS_VERSION}-unix.tar.gz"
DOWNLOAD_URL="https://download.sonatype.com/nexus/3/${ARCHIVE}"
INSTALL_DIR="/app"
NEXUS_USER="nexus"

# 1. System update and Java install
yum update -y
yum install -y wget java-17-amazon-corretto

# 2. Prepare install directory
mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

# 3. Download Nexus archive
wget -O "${ARCHIVE}" "${DOWNLOAD_URL}"

# 4. Extract and relocate
tar -xvf "${ARCHIVE}"
mv "nexus-${NEXUS_VERSION}" nexus
rm -f "${ARCHIVE}"

# 5. Create nexus user if missing
if ! id -u "${NEXUS_USER}" &>/dev/null; then
  useradd "${NEXUS_USER}"
fi

# 6. Set ownership for Nexus and data directories
chown -R "${NEXUS_USER}":"${NEXUS_USER}" nexus
mkdir -p sonatype-work
chown -R "${NEXUS_USER}":"${NEXUS_USER}" sonatype-work

# 7. Configure service user
echo "run_as_user=${NEXUS_USER}" > nexus/bin/nexus.rc
chmod +x nexus/bin/nexus

# 8. Create systemd service definition
cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=${NEXUS_USER}
Group=${NEXUS_USER}
ExecStart=${INSTALL_DIR}/nexus/bin/nexus start
ExecStop=${INSTALL_DIR}/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# 9. Enable & launch Nexus
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

echo "✅ Nexus ${NEXUS_VERSION} installed successfully!"
echo "🔗 Access Nexus at http://<EC2_PUBLIC_IP>:8081"
echo "🔐 Your admin password is in: ${INSTALL_DIR}/sonatype‑work/nexus3/admin.password"
