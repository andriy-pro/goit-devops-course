# Урок 10: Гнучкий Terraform-модуль для баз даних

## Опис

Універсальний Terraform-модуль `rds` для створення AWS RDS Instance або Aurora
Cluster з автоматичним створенням DB Subnet Group, Security Group та Parameter
Group.

## Архітектура

```
┌─────────────────────────────────────────────────────────────┐
│                           VPC                               │
│  ┌─────────────────────┐    ┌─────────────────────┐        │
│  │ Private Subnet 1    │    │ Private Subnet 2    │        │
│  │ (eu-north-1a)       │    │ (eu-north-1b)       │        │
│  └──────────┬──────────┘    └──────────┬──────────┘        │
│             │                          │                    │
│             └──────────┬───────────────┘                    │
│                        │                                    │
│              ┌─────────▼─────────┐                         │
│              │  DB Subnet Group  │                         │
│              └─────────┬─────────┘                         │
│                        │                                    │
│    ┌───────────────────┼───────────────────┐               │
│    │                   │                   │               │
│    ▼                   ▼                   ▼               │
│ ┌──────────┐    ┌─────────────┐    ┌──────────────┐       │
│ │ Security │    │  Parameter  │    │    RDS або   │       │
│ │  Group   │───▶│   Group     │───▶│    Aurora    │       │
│ └──────────┘    └─────────────┘    └──────────────┘       │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Структура проєкту

```
lesson-10/
├── main.tf              # Приклад використання модуля
├── providers.tf         # AWS provider
├── outputs.tf           # Outputs
├── README.md            # Цей файл
└── modules/
    ├── vpc/             # Мінімальний VPC
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── rds/             # Головний модуль
        ├── rds.tf       # RDS Instance
        ├── aurora.tf    # Aurora Cluster
        ├── shared.tf    # Спільні ресурси
        ├── variables.tf # Змінні
        ├── outputs.tf   # Outputs
        └── README.md    # Документація модуля
```

## Швидкий старт

### 1. Ініціалізація

```bash
cd lesson-10
terraform init
```

### 2. Перевірка плану

```bash
terraform plan
```

### 3. Застосування (ПЛАТНО!)

> ⚠️ **УВАГА:** RDS коштує ~$0.02/год для db.t3.micro

```bash
terraform apply
```

### 4. Отримання credentials

```bash
# Endpoint
terraform output rds_endpoint

# Password
terraform output -raw rds_password
```

### 5. Cleanup (ОБОВ'ЯЗКОВО!)

```bash
terraform destroy
```

## Приклади використання

### RDS PostgreSQL (за замовчуванням)

```hcl
module "rds_postgres" {
  source = "./modules/rds"

  identifier     = "my-postgres"
  use_aurora     = false          # RDS Instance
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"

  db_name     = "myapp"
  db_username = "admin"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

### Aurora PostgreSQL

```hcl
module "aurora_postgres" {
  source = "./modules/rds"

  identifier     = "my-aurora"
  use_aurora     = true           # Aurora Cluster
  engine         = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.t3.medium" # Aurora мінімум t3.medium

  db_name     = "myapp"
  db_username = "admin"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

## Документація модуля

Детальна документація: [modules/rds/README.md](modules/rds/README.md)

## Вартість

| Ресурс | Вартість/год |
|--------|--------------|
| RDS db.t3.micro | ~$0.02 |
| Aurora db.t3.medium | ~$0.08 |
| VPC (без NAT) | $0 |

**Рекомендація:** Тестуйте з `terraform plan`, apply тільки для фінальної
перевірки. Після тестування **ОБОВ'ЯЗКОВО** виконайте `terraform destroy`.

## Автор

Урок 10 — Гнучкий Terraform-модуль для баз даних  
GoIT DevOps Course
