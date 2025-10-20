# Java Spring Boot - AWS Deployment mit GitHub Actions

Eine vollständige CI/CD-Pipeline für eine Java Spring Boot Anwendung mit GitHub Actions und Terraform.

## Was macht dieses Projekt?

Diese Demo zeigt eine komplette CI/CD-Pipeline:

1. **Build & Test** - Java Spring Boot App kompilieren und testen
2. **Infrastructure** - AWS EC2 mit Terraform provisionieren
3. **Deploy** - Anwendung auf EC2 deployen
4. **Destroy** - Alle Ressourcen wieder löschen (manuell)

## Projektstruktur

```
action3/
├── src/                          # Java Spring Boot Anwendung
│   ├── main/java/                # Hauptcode
│   └── test/java/                # Tests
├── terraform/                    # Terraform Konfiguration
│   ├── main.tf                   # AWS Infrastruktur
│   ├── variables.tf              # Variablen
│   └── outputs.tf                # Outputs
├── .github/workflows/            # GitHub Actions
│   └── deploy.yml                # CI/CD Pipeline
├── scripts/                      # Deployment Scripts
│   └── deploy.sh                 # Deploy-Script
└── pom.xml                       # Maven Konfiguration
```

## Voraussetzungen

### 1. AWS Account
- IAM User mit EC2/VPC-Berechtigungen
- Access Key ID + Secret Access Key

### 2. SSH Key-Pair generieren

```bash
ssh-keygen -t rsa -b 4096 -f deployer-key -N ""
# Public Key:  deployer-key.pub
# Private Key: deployer-key
```

### 3. GitHub Environment "production" erstellen

**Settings → Environments → New environment → "production"**

**Environment Variables:**
- `AWS_REGION` = `eu-north-1`
- `AMI_ID` = `ami-0a716d3f3b16d290c` (Ubuntu 22.04 LTS)
- `INSTANCE_TYPE` = `t3.micro`

**Environment Secrets:**
- `AWS_ACCESS_KEY_ID` = Dein AWS Access Key
- `AWS_SECRET_ACCESS_KEY` = Dein AWS Secret Key
- `SSH_PUBLIC_KEY` = Inhalt von `deployer-key.pub`
- `SSH_PRIVATE_KEY` = Inhalt von `deployer-key`

## Lokales Testen

### Java App lokal bauen und testen:

```bash
# Build
mvn clean package

# Tests
mvn test

# Lokal starten
java -jar target/demo-app.jar

# Testen
curl http://localhost:8080
curl http://localhost:8080/hello
curl http://localhost:8080/actuator/health
```

## CI/CD Pipeline

### Vereinfachter Workflow

**Besonderheit:** Alles läuft in **einem einzigen Job**!

Dadurch bleibt der Terraform State während der gesamten Workflow-Ausführung erhalten, und `destroy` funktioniert problemlos.

### Workflow-Ablauf:

```
┌──────────────────────────────────────┐
│  DEPLOY (automatisch bei push)       │
├──────────────────────────────────────┤
│ 1. Checkout & Setup                  │
│ 2. Maven Build & Test                │
│ 3. Terraform Apply (EC2 erstellen)   │
│ 4. SSH Deploy                         │
│ 5. Health Check                       │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  DESTROY (manuell via Actions UI)    │
├──────────────────────────────────────┤
│ 1. Checkout & Setup                  │
│ 2. Terraform Destroy                  │
│ 3. Cleanup Complete                   │
└──────────────────────────────────────┘
```

### Workflow starten:

**Automatisch:** Bei Push auf `main` Branch → Deploy

**Manuell:**
- GitHub → Actions → "Deploy Java App to AWS" → Run workflow
- Aktion wählen: `deploy` oder `destroy`

### Infrastructure löschen:

- GitHub → Actions → "Deploy Java App to AWS" → Run workflow
- Aktion: **`destroy`** auswählen
- Branch: `main`
- Run workflow

**Wichtig:** Terraform State bleibt im Workflow erhalten, deshalb funktioniert Destroy zuverlässig!

## Endpoints

Nach dem Deployment:

- **Home:** `http://<EC2-IP>:8080/`
- **Hello:** `http://<EC2-IP>:8080/hello`
- **Personalized:** `http://<EC2-IP>:8080/hello/{name}`
- **Health:** `http://<EC2-IP>:8080/actuator/health`

## Troubleshooting

### Problem: Tests schlagen fehl

```bash
# Lokal testen
mvn test

# Einzelnen Test
mvn test -Dtest=HelloControllerTest
```

### Problem: Deployment schlägt fehl

**SSH-Verbindung prüfen:**
```bash
ssh -i deployer-key ubuntu@<EC2-IP>
```

**App-Logs auf EC2:**
```bash
ssh -i deployer-key ubuntu@<EC2-IP>
sudo journalctl -u demo-app.service -f
```

### Problem: App startet nicht

**Service-Status:**
```bash
sudo systemctl status demo-app.service
```

**Java-Version:**
```bash
java -version  # Sollte Java 17 sein
```

## Kosten

**Geschätzte AWS-Kosten:**
- EC2 t3.micro: ~$0.01/Stunde (Free Tier: 750h/Monat)
- VPC/Subnet: Kostenlos
- Internet Gateway: Kostenlos

**Wichtig:** Destroy nach dem Workshop ausführen!

## Weitere Informationen

- [Spring Boot Dokumentation](https://spring.io/projects/spring-boot)
- [GitHub Actions Dokumentation](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

-Erster offizieller Test
- Zweiter Test
- dritter Test
- vierter Test
- fünfter Test
- sechster Test
- Test 7
- Test 8
