# ============================================
# Terraform Configuration - Java App auf AWS EC2
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend-Konfiguration ist in backend.tf
  # WICHTIG: backend.tf muss erst aktiviert werden (siehe bootstrap-backend.sh)
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project     = "GitHubActions-Java-Workshop"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Application = "Spring-Boot-Demo"
  }
}

# ============================================
# VPC und Netzwerk
# ============================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ============================================
# Security Group
# ============================================

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for Java Spring Boot application"
  vpc_id      = aws_vpc.main.id

  # SSH (Port 22) - Für Deployment
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Port 8080) - Spring Boot App
  ingress {
    description = "Spring Boot App"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ausgehender Traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-app-sg"
  })
}

# ============================================
# SSH Key Pair
# ============================================

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-deployer-key"
  public_key = var.ssh_public_key

  tags = local.common_tags
}

# ============================================
# User Data Script
# ============================================

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    echo "=== Starting EC2 Setup ==="

    # System aktualisieren
    apt-get update
    apt-get upgrade -y

    # Java 17 installieren
    apt-get install -y openjdk-17-jre-headless

    # Benutzer für die Anwendung erstellen
    useradd -m -s /bin/bash appuser

    # Verzeichnis für die Anwendung
    mkdir -p /opt/demo-app
    chown appuser:appuser /opt/demo-app

    # Systemd Service erstellen
    cat > /etc/systemd/system/demo-app.service <<'SERVICE'
    [Unit]
    Description=Spring Boot Demo Application
    After=network.target

    [Service]
    Type=simple
    User=appuser
    WorkingDirectory=/opt/demo-app
    ExecStart=/usr/bin/java -jar /opt/demo-app/demo-app.jar
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target
    SERVICE

    # Service aktivieren (aber noch nicht starten - JAR kommt später)
    systemctl daemon-reload
    systemctl enable demo-app.service

    echo "=== EC2 Setup Complete ==="
  EOF
}

# ============================================
# EC2 Instanz
# ============================================

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.deployer.key_name

  user_data = local.user_data

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-root-volume"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-app-server"
  })
}
