#!/usr/bin/env bash

# Скрипт для встановлення інструментів розробки:
# Docker, Docker Compose, Python (>= 3.9) та Django

set -e  # Зупиняємо скрипт при помилці

echo "=== Встановлення інструментів розробки ==="

# Оновлюємо список пакетів
echo "Оновлення списку пакетів..."
apt-get update -y

# ============================================
# Встановлення Docker
# ============================================
if command -v docker >/dev/null 2>&1; then
  echo "✓ Docker вже встановлено: $(docker --version)"
else
  echo "Встановлення Docker..."
  apt-get install -y docker.io
  echo "✓ Docker встановлено: $(docker --version)"
fi

# ============================================
# Встановлення Docker Compose
# ============================================
if docker compose version >/dev/null 2>&1; then
  echo "✓ Docker Compose вже встановлено: $(docker compose version --short)"
else
  echo "Встановлення Docker Compose..."
  apt-get install -y docker-compose-plugin
  echo "✓ Docker Compose встановлено: $(docker compose version --short)"
fi

# ============================================
# Встановлення Python
# ============================================
if command -v python3 >/dev/null 2>&1; then
  PYTHON_VERSION=$(python3 --version | grep -oP '\d+\.\d+')
  REQUIRED_VERSION="3.9"
  
  # Порівнюємо версії
  if awk "BEGIN {exit !($PYTHON_VERSION >= $REQUIRED_VERSION)}"; then
    echo "✓ Python вже встановлено: $(python3 --version)"
  else
    echo "Python версії $PYTHON_VERSION < $REQUIRED_VERSION. Оновлення..."
    apt-get install -y python3 python3-pip
    echo "✓ Python оновлено: $(python3 --version)"
  fi
else
  echo "Встановлення Python..."
  apt-get install -y python3 python3-pip
  echo "✓ Python встановлено: $(python3 --version)"
fi

# ============================================
# Встановлення Django
# ============================================
if python3 -m django --version >/dev/null 2>&1; then
  echo "✓ Django вже встановлено: $(python3 -m django --version)"
else
  echo "Встановлення Django..."
  apt-get install -y python3-django
  echo "✓ Django встановлено: $(python3 -m django --version)"
fi

echo ""
echo "=== Встановлення завершено ==="
