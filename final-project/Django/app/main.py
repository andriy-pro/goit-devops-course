import os
import sys

from django.conf import settings
from django.core.wsgi import get_wsgi_application
from django.http import HttpResponse, JsonResponse
from django.urls import path

# Конфігурація Django
if not settings.configured:
    settings.configure(
        DEBUG=os.environ.get("DEBUG", "False").lower() == "true",
        SECRET_KEY=os.environ.get("SECRET_KEY", "lesson-9-secret-key"),
        ROOT_URLCONF=__name__,
        ALLOWED_HOSTS=["*"],
        # Для спрощення - SQLite
        DATABASES={
            "default": {
                "ENGINE": "django.db.backends.sqlite3",
                "NAME": "/tmp/db.sqlite3",
            }
        },
    )


def index(request):
    """Головна сторінка"""
    pod_name = os.environ.get("HOSTNAME", "unknown")
    version = "2.0.0"  # Оновлена версія для демонстрації CI/CD
    return HttpResponse(
        f"<h1>🚀 Lesson-9: CI/CD Pipeline SUCCESS!</h1>"
        f"<p><strong>Django працює в Kubernetes!</strong></p>"
        f"<p>Version: <code>{version}</code></p>"
        f"<p>Pod: <code>{pod_name}</code></p>"
        f"<p>Environment: <code>{os.environ.get('APP_ENV', 'not set')}</code></p>"
        f"<p>🎉 <em>Автоматично задеплоєно через Jenkins + Argo CD!</em></p>"
        f"<p style='color: green;'>✅ GitOps in action!</p>"
    )


def health(request):
    """Health check для Kubernetes probes"""
    return JsonResponse({"status": "healthy"})


def ready(request):
    """Readiness check"""
    return JsonResponse({"status": "ready"})


urlpatterns = [
    path("", index),
    path("health", health),
    path("ready", ready),
]

application = get_wsgi_application()

if __name__ == "__main__":
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)
