#!/bin/bash

# ============================================
# Deployment Script für Java Spring Boot App
# ============================================

set -e  # Bei Fehler abbrechen

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Deploying Spring Boot Application to EC2${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ============================================
# 1. Parameter prüfen
# ============================================

if [ -z "$1" ]; then
    echo -e "${RED}❌ Fehler: EC2 IP-Adresse fehlt${NC}"
    echo "Usage: $0 <EC2_IP> <SSH_KEY_PATH> <JAR_PATH>"
    exit 1
fi

if [ -z "$2" ]; then
    echo -e "${RED}❌ Fehler: SSH Key Pfad fehlt${NC}"
    echo "Usage: $0 <EC2_IP> <SSH_KEY_PATH> <JAR_PATH>"
    exit 1
fi

if [ -z "$3" ]; then
    echo -e "${RED}❌ Fehler: JAR Pfad fehlt${NC}"
    echo "Usage: $0 <EC2_IP> <SSH_KEY_PATH> <JAR_PATH>"
    exit 1
fi

EC2_IP=$1
SSH_KEY=$2
JAR_FILE=$3

echo -e "${YELLOW}Configuration:${NC}"
echo "  EC2 IP: ${EC2_IP}"
echo "  SSH Key: ${SSH_KEY}"
echo "  JAR File: ${JAR_FILE}"
echo ""

# ============================================
# 2. SSH Key Berechtigungen setzen
# ============================================

echo -e "${YELLOW}Setting SSH key permissions...${NC}"
chmod 600 "${SSH_KEY}"

# ============================================
# 3. Warten bis EC2 bereit ist
# ============================================

echo -e "${YELLOW}Waiting for EC2 instance to be ready...${NC}"

MAX_RETRIES=30
RETRY_COUNT=0

while ! ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" ubuntu@"${EC2_IP}" "echo 'SSH ready'" 2>/dev/null; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo -e "${RED}❌ EC2 instance not reachable after ${MAX_RETRIES} attempts${NC}"
        exit 1
    fi
    echo "  Attempt ${RETRY_COUNT}/${MAX_RETRIES}..."
    sleep 10
done

echo -e "${GREEN}✅ EC2 instance is ready${NC}"
echo ""

# ============================================
# 4. JAR-Datei hochladen
# ============================================

echo -e "${YELLOW}Uploading JAR file to EC2...${NC}"

scp -o StrictHostKeyChecking=no -i "${SSH_KEY}" \
    "${JAR_FILE}" \
    ubuntu@"${EC2_IP}":/tmp/demo-app.jar

echo -e "${GREEN}✅ JAR file uploaded${NC}"
echo ""

# ============================================
# 5. Anwendung auf EC2 deployen
# ============================================

echo -e "${YELLOW}Deploying application on EC2...${NC}"

ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" ubuntu@"${EC2_IP}" << 'ENDSSH'
    set -e

    APP_USER="appuser"
    APP_DIR="/opt/demo-app"
    JAR_FILE="${APP_DIR}/demo-app.jar"

    echo "Stopping old application (if running)..."
    sudo systemctl stop demo-app.service || true

    # 1️⃣ User erstellen, falls nicht vorhanden
    if ! id -u "$APP_USER" >/dev/null 2>&1; then
        echo "Creating user $APP_USER..."
        sudo useradd -m -s /bin/bash $APP_USER
    fi

    # 2️⃣ App-Verzeichnis erstellen, falls nicht vorhanden
    if [ ! -d "$APP_DIR" ]; then
        echo "Creating application directory $APP_DIR..."
        sudo mkdir -p "$APP_DIR"
    fi

    sudo chown $APP_USER:$APP_USER "$APP_DIR"

    echo "Moving JAR to application directory..."
    sudo mv /tmp/demo-app.jar "$JAR_FILE"
    sudo chown $APP_USER:$APP_USER "$JAR_FILE"

    # 4️⃣ systemd-Service-Datei erstellen, falls sie nicht existiert
    SERVICE_FILE="/etc/systemd/system/demo-app.service"
    if [ ! -f "$SERVICE_FILE" ]; then
        echo "Creating systemd service file..."
        sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Demo Spring Boot Application
After=network.target

[Service]
User=$APP_USER
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/java -jar $JAR_FILE
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    fi

    # 5️⃣ Service starten und prüfen
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload

    echo "Starting application..."
    sudo systemctl enable demo-app.service
    sudo systemctl start demo-app.service

    echo "Starting application..."
    sudo systemctl start demo-app.service

    echo "Waiting for application to start..."
    sleep 30

    echo "Checking application status..."
    sudo systemctl status demo-app.service --no-pager
ENDSSH

echo -e "${GREEN}✅ Application deployed${NC}"
echo ""

# ============================================
# 6. Health Check
# ============================================

echo -e "${YELLOW}Performing health check...${NC}"

MAX_HEALTH_RETRIES=12
HEALTH_RETRY_COUNT=0

while ! curl -sf "http://${EC2_IP}:8080/actuator/health" > /dev/null; do
    HEALTH_RETRY_COUNT=$((HEALTH_RETRY_COUNT + 1))
    if [ $HEALTH_RETRY_COUNT -ge $MAX_HEALTH_RETRIES ]; then
        echo -e "${RED}❌ Application health check failed after ${MAX_HEALTH_RETRIES} attempts${NC}"
        exit 1
    fi
    echo "  Health check attempt ${HEALTH_RETRY_COUNT}/${MAX_HEALTH_RETRIES}..."
    sleep 30
done

echo -e "${GREEN}✅ Application is healthy${NC}"
echo ""

# ============================================
# 7. Erfolgs-Meldung
# ============================================

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✅ Deployment Successful!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}Application URL:${NC} http://${EC2_IP}:8080"
echo -e "${BLUE}Health Check:${NC} http://${EC2_IP}:8080/actuator/health"
echo ""
echo -e "${YELLOW}Test the application:${NC}"
echo "  curl http://${EC2_IP}:8080"
echo "  curl http://${EC2_IP}:8080/hello"
echo "  curl http://${EC2_IP}:8080/hello/YourName"
echo ""
