# Java Spring Boot - AWS Deployment mit GitHub Actions

**Willkommen zum Java Workshop!**

Heute lernst du, wie man eine **Java Spring Boot Anwendung** mit **GitHub Actions** automatisch baut, testet und auf **AWS EC2** deployed.

---

## Was bauen wir?

Eine **komplette CI/CD-Pipeline**:

```
Code Push → Build → Test → Infrastructure → Deploy → Running App!
```

**Am Ende hast du:**
- ✅ Java Spring Boot REST API
- ✅ Automatische Tests
- ✅ AWS EC2 Infrastruktur (Terraform)
- ✅ Automatisches Deployment
- ✅ Live-Application in der Cloud!

---

# Teil 1: Java Spring Boot Anwendung verstehen

## Die Anwendung

**Was ist Spring Boot?**
- Java-Framework für Web-Anwendungen
- Sehr beliebt in der Enterprise-Welt
- Einfach zu starten, produktionsreif

**Unsere App hat 4 Endpoints:**
- `GET /` → Home-Seite mit Info
- `GET /hello` → Einfache Begrüßung
- `GET /hello/{name}` → Personalisierte Begrüßung
- `GET /actuator/health` → Health Check

## Aufgabe 1: Code verstehen

### Schritt 1: Projekt-Struktur anschauen

```
action3/
├── src/main/java/com/workshop/demo/
│   ├── DemoApplication.java          # Hauptklasse
│   └── controller/HelloController.java # REST Controller
├── src/test/java/                    # Tests
├── pom.xml                            # Maven Config
└── .github/workflows/deploy.yml      # CI/CD Pipeline
```

### Schritt 2: Hauptklasse verstehen

**`DemoApplication.java`:**
```java
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

**Was passiert:**
- `@SpringBootApplication` → Spring Boot App
- `main()` → Startet den Server
- Läuft auf Port 8080

### Schritt 3: Controller verstehen

**`HelloController.java`:**
```java
@RestController
public class HelloController {

    @GetMapping("/hello")
    public Map<String, String> hello() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello from Spring Boot!");
        return response;
    }
}
```

**Was passiert:**
- `@RestController` → REST API Controller
- `@GetMapping("/hello")` → Endpoint für GET-Request
- Gibt JSON zurück: `{"message": "Hello from Spring Boot!"}`

---

# Teil 2: Lokales Testen

## Aufgabe 2: Anwendung lokal bauen und testen

### Voraussetzung: Java 17 installiert

```bash
java -version  # Sollte Java 17 zeigen
```

Falls nicht installiert:
- **macOS:** `brew install openjdk@17`
- **Linux:** `sudo apt install openjdk-17-jdk`
- **Windows:** [AdoptOpenJDK](https://adoptium.net/)

### Schritt 1: Build

```bash
cd action3
mvn clean package
```

**Was passiert:**
- Maven lädt Dependencies
- Kompiliert Java-Code
- Erstellt JAR-Datei in `target/demo-app.jar`

### Schritt 2: Tests ausführen

```bash
mvn test
```

**Was getestet wird:**
- Spring Boot Context startet
- Controller-Endpoints funktionieren
- JSON-Responses korrekt

**Erwartetes Ergebnis:**
```
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

### Schritt 3: Lokal starten

```bash
java -jar target/demo-app.jar
```

**Output:**
```
Started DemoApplication in 2.5 seconds
Tomcat started on port(s): 8080
```

### Schritt 4: Testen

**In einem neuen Terminal:**
```bash
# Home
curl http://localhost:8080

# Hello
curl http://localhost:8080/hello

# Mit Name
curl http://localhost:8080/hello/Max

# Health Check
curl http://localhost:8080/actuator/health
```

**✅ Wenn alles funktioniert, Strg+C drücken**

---

# Teil 3: AWS Setup

## Aufgabe 3: SSH Key-Pair generieren

**Warum SSH Keys?**
- Für sicheren Zugriff auf EC2
- GitHub Actions deployed über SSH
- Private Key → GitHub Secret
- Public Key → Terraform → EC2

### Schritt 1: Key generieren

```bash
ssh-keygen -t rsa -b 4096 -f deployer-key -N ""
```

**Erstellt zwei Dateien:**
- `deployer-key` → **Private Key** (geheim!)
- `deployer-key.pub` → **Public Key** (für EC2)

### Schritt 2: Keys anschauen

```bash
# Public Key
cat deployer-key.pub

# Private Key
cat deployer-key
```

**⚠️ WICHTIG:** Private Key NIEMALS committen!

---

## Aufgabe 4: GitHub Environment erstellen

### Schritt 1: Environment anlegen

- [ ] GitHub Repository → **Settings**
- [ ] **Environments** → **New environment**
- [ ] Name: `production`
- [ ] **Configure environment**

### Schritt 2: Environment Variables

**Klicke "Add variable":**

**Variable 1:**
- Name: `AWS_REGION`
- Value: `eu-north-1`

**Variable 2:**
- Name: `AMI_ID`
- Value: `ami-0a716d3f3b16d290c`

**Variable 3:**
- Name: `INSTANCE_TYPE`
- Value: `t3.micro`

### Schritt 3: Environment Secrets

**Klicke "Add secret":**

**Secret 1:**
- Name: `AWS_ACCESS_KEY_ID`
- Value: Dein AWS Access Key

**Secret 2:**
- Name: `AWS_SECRET_ACCESS_KEY`
- Value: Dein AWS Secret Key

**Secret 3:**
- Name: `SSH_PUBLIC_KEY`
- Value: Inhalt von `deployer-key.pub` (kopieren!)

**Secret 4:**
- Name: `SSH_PRIVATE_KEY`
- Value: Inhalt von `deployer-key` (kopieren!)

**✅ Fertig! 3 Variables + 4 Secrets**

---

# Teil 4: GitHub Actions Workflow verstehen

## Der vereinfachte Workflow

**Besonderheit:** Alles läuft in **einem einzigen Job**!

### Warum nur ein Job?

**Das Problem mit mehreren Jobs:**
- Terraform State geht zwischen Jobs verloren
- Destroy-Job findet keinen State → Löscht nichts!

**Die Lösung:**
- Alles in einem Job → State bleibt erhalten
- Manueller Start mit Auswahl: **Deploy** oder **Destroy**
- Keine komplizierte Remote State Konfiguration nötig!

### Deploy-Flow:
```yaml
1. Repository auschecken
2. Java 17 einrichten
3. AWS Credentials konfigurieren
4. Terraform Setup
5. Maven Build (JAR erstellen)
6. Tests ausführen
7. Terraform Apply (EC2 erstellen)
8. SSH Key vorbereiten
9. Application deployen
10. Summary anzeigen
```

### Destroy-Flow:
```yaml
1. Repository auschecken
2. AWS Credentials konfigurieren
3. Terraform Setup
4. Terraform Destroy (alles löschen)
5. Summary anzeigen
```

## Aufgabe 5: Workflow-Datei verstehen

- [ ] Öffne `.github/workflows/deploy.yml`
- [ ] Finde den Trigger:
```yaml
on:
  push:
    branches:
      - main
  workflow_dispatch:    # Manueller Start!
    inputs:
      action:
        description: 'Aktion'
        type: choice
        options:
          - deploy     # Standard
          - destroy    # Zum Aufräumen
```

- [ ] Verstehe die bedingten Schritte:
```yaml
# Nur bei Deploy:
if: github.event.inputs.action != 'destroy'

# Nur bei Destroy:
if: github.event.inputs.action == 'destroy'
```

**Wichtig:**
```yaml
environment: production  # Bindet Environment mit vars und secrets!
```

---

# Teil 5: Deployment durchführen!

## Aufgabe 6: Pipeline starten

### Schritt 1: Code pushen

```bash
git add .
git commit -m "Initial Java Spring Boot App"
git push origin main
```

### Schritt 2: Workflow beobachten

- [ ] GitHub → **Actions**
- [ ] Workflow: "Deploy Java App to AWS"
- [ ] Beobachte den Job (läuft alles durch):
  1. ✅ Build & Test (ca. 2 Min)
  2. ✅ Provision Infrastructure (ca. 3 Min)
  3. ✅ Deploy Application (ca. 2 Min)

**Gesamt: ca. 7-8 Minuten**

### Schritt 3: Deployment Summary anschauen

Am Ende siehst du:
```
🚀 Deployment Complete!

Application URL: http://16.171.XXX.XXX:8080

Endpoints:
- GET / - Home
- GET /hello - Hello Message
- GET /hello/{name} - Personalized Greeting
- GET /actuator/health - Health Check
```

### Schritt 4: Anwendung testen!

**Ersetze `<IP>` mit deiner EC2-IP:**

```bash
# Home
curl http://<IP>:8080

# Hello
curl http://<IP>:8080/hello

# Mit deinem Namen
curl http://<IP>:8080/hello/DeinName

# Health Check
curl http://<IP>:8080/actuator/health
```

**Im Browser öffnen:**
- `http://<IP>:8080`

**✅ Wenn du JSON siehst → Erfolgreich deployed!**

---

# Teil 6: Aufräumen

## Aufgabe 7: Infrastruktur löschen

**⚠️ WICHTIG:** Vergiss nicht aufzuräumen, um Kosten zu vermeiden!

### Via GitHub Actions (empfohlen)

- [ ] GitHub → **Actions**
- [ ] Workflow: "Deploy Java App to AWS"
- [ ] **Run workflow** (Button rechts oben)
- [ ] **Aktion auswählen:** `destroy` (statt deploy)
- [ ] Branch: `main` auswählen
- [ ] **Run workflow** klicken

**Was passiert:**
- Terraform destroy läuft
- EC2, VPC, Security Group, Key Pair → alles weg
- Dauert ca. 2-3 Minuten

**Wichtig:**
- Der Workflow lädt den State aus dem letzten Deploy
- Deshalb funktioniert Destroy problemlos!
- Keine manuelle Konfiguration nötig!

---

# Zusammenfassung

## Was hast du gelernt?

### Java & Spring Boot
- ✅ Spring Boot Anwendung verstehen
- ✅ REST Controller erstellen
- ✅ Maven Build & Tests
- ✅ JAR-Datei erstellen

### GitHub Actions
- ✅ Multi-Job Workflow
- ✅ Artifacts zwischen Jobs
- ✅ GitHub Environments nutzen
- ✅ Secrets & Variables

### AWS & Terraform
- ✅ EC2 mit Terraform provisionieren
- ✅ VPC, Subnets, Security Groups
- ✅ User Data Scripts
- ✅ SSH-basiertes Deployment

### CI/CD Pipeline
- ✅ Build → Test → Deploy Workflow
- ✅ Automatisches Deployment
- ✅ Infrastructure as Code
- ✅ Destroy-Funktion

---

# Erweiterte Aufgaben

## Bonus 1: Eigenen Endpoint hinzufügen

**Datei:** `HelloController.java`

```java
@GetMapping("/time")
public Map<String, String> currentTime() {
    Map<String, String> response = new HashMap<>();
    response.put("time", LocalDateTime.now().toString());
    return response;
}
```

- [ ] Code ändern
- [ ] Pushen
- [ ] Pipeline beobachten
- [ ] Neuen Endpoint testen: `curl http://<IP>:8080/time`

## Bonus 2: Test hinzufügen

**Datei:** `HelloControllerTest.java`

```java
@Test
void testTime() throws Exception {
    mockMvc.perform(get("/time"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.time").exists());
}
```

## Bonus 3: Environment Variables in App nutzen

**application.properties:**
```properties
app.welcome.message=Welcome to ${ENVIRONMENT:dev}!
```

**Controller:**
```java
@Value("${app.welcome.message}")
private String welcomeMessage;
```

---

# Troubleshooting

## Problem: Maven Build schlägt fehl

**Fehler:** `Could not resolve dependencies`

**Lösung:**
```bash
mvn clean  # Cache löschen
mvn package -U  # Dependencies neu laden
```

## Problem: Tests schlagen fehl

**Lösung:**
```bash
mvn test -X  # Verbose Output
mvn test -Dtest=HelloControllerTest  # Einzelner Test
```

## Problem: Deployment schlägt fehl

**SSH-Verbindung testen:**
```bash
ssh -i deployer-key ubuntu@<EC2-IP>
```

**App-Logs auf EC2:**
```bash
ssh -i deployer-key ubuntu@<EC2-IP>
sudo journalctl -u demo-app.service -f
```

## Problem: App startet nicht auf EC2

**Service-Status prüfen:**
```bash
sudo systemctl status demo-app.service
sudo journalctl -u demo-app.service --no-pager -n 50
```

**Manuell starten:**
```bash
cd /opt/demo-app
java -jar demo-app.jar
```

---

**🎉 Gratulation! Du hast eine vollständige CI/CD-Pipeline für Java Spring Boot gemeistert!**
