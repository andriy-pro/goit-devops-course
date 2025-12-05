# Базовий образ
FROM python:3.9-slim

# Оптимізація Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Робоча директорія
WORKDIR /app

# Залежності
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Код застосунку
COPY app/ .

# Порт
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Запуск
CMD ["gunicorn", "main:application", "--bind", "0.0.0.0:8000", "--workers", "2"]
