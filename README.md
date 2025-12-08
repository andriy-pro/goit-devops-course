# Фінальний проєкт: DevOps інфраструктура на AWS

## Зміст

1. [Опис проєкту](#опис-проєкту)
2. [Архітектура](#архітектура)
3. [Компоненти](#компоненти)
4. [Структура проєкту](#структура-проєкту)
5. [Швидкий старт](#швидкий-старт)
6. [Доступ до сервісів](#доступ-до-сервісів)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Моніторинг](#моніторинг)
9. [Можливі проблеми та рішення](#можливі-проблеми-та-рішення)
10. [Cleanup](#cleanup)
11. [Скріншоти](#скріншоти)

---

## Опис проєкту

<!-- TODO: Додати опис -->

---

## Архітектура

<!-- TODO: Додати Mermaid діаграму -->

---

## Компоненти

| Компонент | Призначення | Статус |
|-----------|-------------|--------|
| VPC | Мережева ізоляція | ✅ |
| EKS | Kubernetes кластер | ✅ |
| ECR | Docker registry | ✅ |
| RDS | PostgreSQL база даних | ✅ |
| Jenkins | CI/CD сервер | ✅ |
| Argo CD | GitOps deployment | ✅ |
| Prometheus | Збір метрик | ⏳ |
| Grafana | Візуалізація | ⏳ |

---

## Структура проєкту

<!-- TODO: Додати структуру -->

---

## Швидкий старт

<!-- TODO: Додати кроки -->

---

## Доступ до сервісів

<!-- TODO: Додати інструкції port-forward -->

---

## CI/CD Pipeline

<!-- TODO: Додати опис pipeline -->

---

## Моніторинг

<!-- TODO: Додати опис моніторингу -->

---

## Можливі проблеми та рішення

### 1. Terraform `-target` Warning

**Проблема:**
```
Warning: Resource targeting is in effect
```

**Причина:** Використання `-target` для створення S3 backend перед міграцією state.

**Рішення:** Це очікувана поведінка. Після створення S3 bucket:
1. Розкоментувати `backend.tf`
2. Виконати `terraform init -migrate-state`

---

### 2. EKS Node Group — Free Tier обмеження

**Проблема:**
```
AsgInstanceLaunchFailures: Could not launch On-Demand Instances. 
InvalidParameterCombination - The specified instance type is not eligible for Free Tier.
```

**Причина:** Free Tier не підтримує EKS nodes.

**Рішення:** Використовувати SPOT інстанси:
```hcl
capacity_type  = "SPOT"
instance_types = ["t3.medium", "t3.small"]
```

---

### 3. Helm Release — Context Deadline Exceeded

**Проблема:**
```
Error: context deadline exceeded
with module.monitoring.helm_release.prometheus
```

**Причина:** Helm чекає поки всі поди будуть Ready, але timeout (5 хв) закінчується раніше.

**Рішення:** Додати в `helm_release`:
```hcl
timeout = 600  # 10 хвилин
wait    = false  # Не чекати Ready
```

---

### 4. Prometheus/Grafana — Pod Pending (PVC)

**Проблема:**
```
Warning: FailedScheduling - pod has unbound immediate PersistentVolumeClaims
```

**Причина:** Helm chart за замовчуванням створює PVC, але StorageClass не налаштований.

**Рішення:** Вимкнути persistence в values:
```yaml
server:
  persistentVolume:
    enabled: false

alertmanager:
  enabled: false  # Також потребує PVC
```

---

### 5. Prometheus/Grafana — Pod Pending (Too Many Pods)

**Проблема:**
```
Warning: FailedScheduling - 0/2 nodes are available: 2 Too many pods
```

**Причина:** 
- t3.medium має ліміт ~17 pods (ENI limit)
- t3.small має ліміт ~11 pods
- Кластер перевантажений

**Рішення варіант 1:** Збільшити кількість nodes:
```hcl
desired_nodes = 3
min_nodes     = 3
```

**Рішення варіант 2:** Зменшити ресурси для monitoring:
```yaml
# values-prometheus.yaml
server:
  resources:
    requests:
      memory: 128Mi
      cpu: 50m

# values-grafana.yaml
resources:
  requests:
    memory: 64Mi
    cpu: 25m
```

---

### 6. RDS — Reserved Username

**Проблема:**
```
InvalidParameterValue: MasterUsername admin cannot be used as it is a reserved word
```

**Причина:** `admin` — зарезервоване слово для PostgreSQL.

**Рішення:** Використовувати інше ім'я:
```hcl
db_username = "dbadmin"
```

---

### 7. AWS Description — Кирилиця

**Проблема:**
```
"description" doesn't comply with restrictions: "Опис українською"
```

**Причина:** AWS API не підтримує Unicode в полі `description`.

**Рішення:** Використовувати англійську для AWS description:
```hcl
description = "Security group for database"  # Не "Група безпеки"
```

---

## Cleanup

<!-- TODO: Додати кроки cleanup -->

---

## Скріншоти

<!-- TODO: Додати скріншоти -->

---

## Вартість

| Ресурс | Вартість/год |
|--------|--------------|
| EKS Control Plane | $0.10 |
| EKS Nodes (2x t3.medium SPOT) | ~$0.02 |
| RDS db.t3.micro | $0.02 |
| NAT Gateway | $0.05 |
| **Загалом** | **~$0.20/год** |

⚠️ **УВАГА:** Після завершення обов'язково виконайте `terraform destroy`!
