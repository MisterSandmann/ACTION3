# 🚀 Action3: Java Spring Boot AWS Deployment - Projekt-Übersicht

## ✅ Vollständiges CI/CD-Projekt erstellt!

### Was wurde gebaut?

Eine **Production-Ready Java Spring Boot Anwendung** mit vollautomatischer CI/CD-Pipeline:

```
Code Push → Build → Test → Infrastructure → Deploy → Live App!
```

---

## 📁 Projekt-Struktur

```
action3/
├── src/
│   ├── main/java/com/workshop/demo/
│   │   ├── DemoApplication.java              # Spring Boot Hauptklasse
│   │   └── controller/HelloController.java   # REST API Controller
│   ├── test/java/                            # Unit Tests
│   └── main/resources/
│       └── application.properties            # App-Konfiguration
│
├── terraform/
│   ├── main.tf                               # AWS Infrastruktur (VPC, EC2, SG)
│   ├── variables.tf                          # Input-Variablen
│   └── outputs.tf                            # Outputs (IP, URL)
│
├── .github/workflows/
│   └── deploy.yml                            # CI/CD Pipeline (4 Jobs)
│
├── scripts/
│   └── deploy.sh                             # Deployment-Script
│
├── pom.xml                                   # Maven Dependencies
├── README.md                                 # Technische Dokumentation
├── TEILNEHMER_ARBEITSMAPPE.md               # Schritt-für-Schritt Anleitung
├── DOZENTEN_LEITFADEN.md                    # Workshop-Ablauf für Dozenten
└── .gitignore                                # Git-Ignore
```

---

## 🎯 Features

### Java Spring Boot Anwendung
- ✅ REST API mit 4 Endpoints
- ✅ Actuator Health Checks
- ✅ Unit Tests (MockMvc)
- ✅ Maven Build
- ✅ Executable JAR

### CI/CD Pipeline (GitHub Actions)
- ✅ **Job 1: Build & Test** - Maven Build + Tests
- ✅ **Job 2: Infrastructure** - Terraform (EC2, VPC, SG)
- ✅ **Job 3: Deploy** - SSH-basiertes Deployment
- ✅ **Job 4: Destroy** - Cleanup (manuell)

### AWS Infrastruktur
- ✅ VPC mit Public Subnet
- ✅ Internet Gateway
- ✅ Security Group (Port 22, 8080)
- ✅ EC2 Instance (t3.micro)
- ✅ Automatic Java 17 Installation
- ✅ Systemd Service für App

---

## 🔧 Tech Stack

| Technologie | Version | Zweck |
|-------------|---------|-------|
| **Java** | 17 | Runtime |
| **Spring Boot** | 3.2.0 | Web Framework |
| **Maven** | 3.x | Build Tool |
| **Terraform** | 1.6.0 | Infrastructure as Code |
| **GitHub Actions** | - | CI/CD |
| **AWS EC2** | Ubuntu 22.04 | Hosting |

---

## 📋 Setup-Schritte für Teilnehmer

### 1. GitHub Environment erstellen

**Settings → Environments → New environment → "production"**

**Environment Variables:**
- `AWS_REGION` = `eu-north-1`
- `AMI_ID` = `ami-0a716d3f3b16d290c`
- `INSTANCE_TYPE` = `t3.micro`

**Environment Secrets:**
- `AWS_ACCESS_KEY_ID` = AWS Access Key
- `AWS_SECRET_ACCESS_KEY` = AWS Secret Key
- `SSH_PUBLIC_KEY` = Public Key Content
- `SSH_PRIVATE_KEY` = Private Key Content

### 2. SSH Keys generieren

```bash
ssh-keygen -t rsa -b 4096 -f deployer-key -N ""
# Erstellt: deployer-key (private) und deployer-key.pub (public)
```

### 3. Code pushen

```bash
git add .
git commit -m "Initial Java Spring Boot App"
git push origin main
```

### 4. Pipeline beobachten

GitHub → Actions → "Build, Test & Deploy Java App"

**Erwartete Laufzeit:** ~7 Minuten

### 5. App testen

```bash
# IP aus Workflow-Output
curl http://<EC2-IP>:8080
curl http://<EC2-IP>:8080/hello
curl http://<EC2-IP>:8080/hello/YourName
curl http://<EC2-IP>:8080/actuator/health
```

### 6. Destroy (Aufräumen!)

GitHub → Actions → Run workflow → Destroy läuft

---

## 📚 Dokumentation

### Für Teilnehmer:
📖 **TEILNEHMER_ARBEITSMAPPE.md**
- Komplette Schritt-für-Schritt Anleitung
- Code-Erklärungen
- Troubleshooting
- Erweiterte Aufgaben

### Für Dozenten:
👨‍🏫 **DOZENTEN_LEITFADEN.md**
- Workshop-Ablauf (3-4 Std)
- Zeitmanagement
- Häufige Probleme & Lösungen
- Erweiterte Themen

### Technisch:
🔧 **README.md**
- Projekt-Übersicht
- Lokales Testen
- Troubleshooting
- Tech Stack

---

## 🎓 Lernziele

Nach diesem Projekt können Teilnehmer:

### Java & Spring Boot
- ✅ Spring Boot Anwendungen verstehen
- ✅ REST Controller erstellen
- ✅ Maven Build-Prozess
- ✅ Unit Tests schreiben

### GitHub Actions
- ✅ Multi-Job Workflows erstellen
- ✅ Artifacts zwischen Jobs teilen
- ✅ GitHub Environments nutzen
- ✅ Job-Dependencies definieren

### AWS & Terraform
- ✅ EC2 Instances provisionieren
- ✅ VPC/Subnets/Security Groups
- ✅ User Data Scripts
- ✅ SSH-basierte Deployments

### DevOps
- ✅ CI/CD Pipeline implementieren
- ✅ Infrastructure as Code
- ✅ Automated Testing
- ✅ Production Deployment

---

## 🔍 Workflow im Detail

### Job 1: Build & Test
```yaml
Steps:
1. Checkout Code
2. Setup Java 17
3. Maven Build (mvn package)
4. Run Tests (mvn test)
5. Upload JAR as Artifact
```

### Job 2: Terraform Infrastructure
```yaml
Steps:
1. Configure AWS Credentials
2. Terraform Init
3. Terraform Plan
4. Terraform Apply
   → VPC, Subnet, Internet Gateway
   → Security Group (22, 8080)
   → EC2 Instance (Java pre-installed)
5. Extract EC2 IP
```

### Job 3: Deploy Application
```yaml
Steps:
1. Download JAR Artifact
2. Setup SSH Key
3. Wait for EC2 ready
4. Upload JAR to EC2
5. Start Systemd Service
6. Health Check
```

### Job 4: Destroy (Manual)
```yaml
Trigger: workflow_dispatch only
Steps:
1. Terraform Destroy
2. Remove all AWS resources
```

---

## 🚨 Wichtige Hinweise

### Sicherheit
- ⚠️ SSH Private Keys NIEMALS committen!
- ⚠️ AWS Credentials als Secrets speichern
- ⚠️ Security Group für Production einschränken

### Kosten
- 💰 EC2 t3.micro: ~$0.01/Stunde
- 💰 Free Tier: 750 Stunden/Monat
- 💰 **WICHTIG:** Nach Workshop destroyen!

### Best Practices
- ✅ Tests vor Deployment
- ✅ Health Checks nach Deployment
- ✅ Infrastructure as Code
- ✅ Secrets Management

---

## 🎯 Erweiterte Aufgaben

### Bonus 1: Eigenen Endpoint hinzufügen
```java
@GetMapping("/api/status")
public Map<String, Object> status() {
    // Implementation
}
```

### Bonus 2: Database Integration
- Add H2/PostgreSQL
- JPA Entities
- Repository Pattern

### Bonus 3: Docker Container
- Dockerfile erstellen
- Docker Compose
- Container Registry

### Bonus 4: Multi-Environment
- Development Environment
- Staging Environment
- Production Environment

---

## 📊 Projekt-Statistik

- **Dateien erstellt:** 15
- **Lines of Code:** ~800
- **Technologien:** 6
- **AWS Services:** 5
- **GitHub Actions Jobs:** 4
- **Endpoints:** 4

---

## ✅ Checkliste für Dozenten

### Vor dem Workshop:
- [ ] Alle Tools getestet (Java, Maven, Terraform)
- [ ] Demo-Repository funktioniert
- [ ] AWS Account mit Budget-Alert
- [ ] GitHub Environment vorbereitet
- [ ] SSH Keys generiert

### Während des Workshop:
- [ ] Teilnehmer-Fortschritt tracken
- [ ] Regelmäßige Pausen
- [ ] Häufige Probleme dokumentieren

### Nach dem Workshop:
- [ ] Alle Teilnehmer haben destroyed
- [ ] Feedback gesammelt
- [ ] Eigene Ressourcen gelöscht
- [ ] AWS Kosten geprüft

---

**🎉 Projekt ist bereit für den Workshop!**

Alle Dateien sind erstellt, getestet und dokumentiert.
Viel Erfolg! 🚀
