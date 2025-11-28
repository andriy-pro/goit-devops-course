# 1. Базовий образ (Best Practice: конкретна версія, slim)
FROM python:3.9-slim

# 2. Змінні середовища для оптимізації Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Робоча директорія
WORKDIR /app

# 4. Спочатку копіюємо requirements (Кешування шарів!)
COPY requirements.txt .

# 5. Встановлюємо залежності
RUN pip install --no-cache-dir -r requirements.txt

# 6. Копіюємо код застосунку
COPY app/ .

# 7. Команда запуску (Gunicorn замість runserver для "production-ready")
CMD ["gunicorn", "main:application", "--bind", "0.0.0.0:8000"]
