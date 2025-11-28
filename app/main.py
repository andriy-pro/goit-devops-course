import os
import sys

from django.conf import settings
from django.core.wsgi import get_wsgi_application
from django.db import connection
from django.http import HttpResponse
from django.urls import path

# 1. Конфігурація Django "на льоту"
if not settings.configured:
    settings.configure(
        DEBUG=os.environ.get("DEBUG", "False") == "True",
        SECRET_KEY=os.environ.get("SECRET_KEY", "secret-key-change-me"),
        ROOT_URLCONF=__name__,
        ALLOWED_HOSTS=["*"],
        DATABASES={
            "default": {
                "ENGINE": "django.db.backends.postgresql",
                "NAME": os.environ.get("DB_NAME", "postgres"),
                "USER": os.environ.get("DB_USER", "postgres"),
                "PASSWORD": os.environ.get("DB_PASSWORD", "postgres"),
                "HOST": os.environ.get("DB_HOST", "db"),
                "PORT": "5432",
            }
        },
    )


# 2. View (Логіка відповіді)
def health_check(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version();")
            row = cursor.fetchone()
            db_version = row[0]
        return HttpResponse(
            f"<h1>Lesson-4</h1><p>Django працює - завдання ВИКОНАНО!</p><p>DB: {db_version}</p>"
        )
    except Exception as e:
        return HttpResponse(f"<h1>Error</h1><p>{str(e)}</p>", status=500)


# 3. URL Routing
urlpatterns = [
    path("", health_check),
]

# 4. WSGI application (Точка входу для Gunicorn)
application = get_wsgi_application()

if __name__ == "__main__":
    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)
