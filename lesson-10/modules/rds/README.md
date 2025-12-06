# Terraform RDS/Aurora модуль

Універсальний модуль для створення AWS RDS Instance або Aurora Cluster.

## Можливості

- ✅ Підтримка RDS Instance (PostgreSQL, MySQL, MariaDB)
- ✅ Підтримка Aurora Cluster (PostgreSQL, MySQL)
- ✅ Автоматичне створення DB Subnet Group
- ✅ Автоматичне створення Security Group
- ✅ Parameter Group з налаштуваннями (max_connections, log_statement, work_mem)
- ✅ Автогенерація пароля (якщо не задано)

## Використання

### RDS Instance (PostgreSQL)

```hcl
module "db" {
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

  # Налаштування Parameter Group
  max_connections = 100
  log_statement   = "ddl"
  work_mem        = 4096
}
```

### Aurora Cluster (PostgreSQL)

```hcl
module "db" {
  source = "./modules/rds"

  identifier     = "my-aurora"
  use_aurora     = true                # Aurora Cluster
  engine         = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.t3.medium"      # Aurora мінімум t3.medium
  multi_az       = true                # Створить reader instance

  db_name     = "myapp"
  db_username = "admin"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

### MySQL RDS

```hcl
module "db" {
  source = "./modules/rds"

  identifier     = "my-mysql"
  use_aurora     = false
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.micro"

  db_name     = "myapp"
  db_username = "admin"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

## Змінні

### Основні

| Змінна | Тип | За замовч. | Опис |
|--------|-----|------------|------|
| `use_aurora` | bool | `false` | Використовувати Aurora замість RDS |
| `identifier` | string | - | Унікальний ідентифікатор БД |
| `engine` | string | `postgres` | Engine: postgres, mysql, mariadb, aurora-postgresql, aurora-mysql |
| `engine_version` | string | `15.4` | Версія engine |
| `instance_class` | string | `db.t3.micro` | Клас інстансу |
| `allocated_storage` | number | `20` | Розмір сховища GB (тільки RDS) |
| `multi_az` | bool | `false` | Висока доступність |

### База даних

| Змінна | Тип | За замовч. | Опис |
|--------|-----|------------|------|
| `db_name` | string | - | Назва бази даних |
| `db_username` | string | `admin` | Master username |
| `db_password` | string | `null` | Master password (автогенерується якщо null) |

### Мережа

| Змінна | Тип | За замовч. | Опис |
|--------|-----|------------|------|
| `vpc_id` | string | - | ID VPC |
| `subnet_ids` | list(string) | - | Приватні підмережі |
| `allowed_security_groups` | list(string) | `[]` | Security Groups з доступом |
| `allowed_cidr_blocks` | list(string) | `[]` | CIDR блоки з доступом |

### Parameter Group

| Змінна | Тип | За замовч. | Опис |
|--------|-----|------------|------|
| `max_connections` | number | `100` | Максимум з'єднань |
| `log_statement` | string | `none` | Логування SQL (none/ddl/mod/all) |
| `work_mem` | number | `4096` | Пам'ять для сортування (KB) |

### Backup

| Змінна | Тип | За замовч. | Опис |
|--------|-----|------------|------|
| `backup_retention_period` | number | `7` | Днів зберігання бекапів |
| `skip_final_snapshot` | bool | `true` | Пропустити snapshot при delete |
| `deletion_protection` | bool | `false` | Захист від видалення |

## Outputs

| Output | Опис |
|--------|------|
| `endpoint` | Endpoint для підключення |
| `reader_endpoint` | Reader endpoint (тільки Aurora) |
| `port` | Порт БД |
| `db_name` | Назва БД |
| `db_username` | Username |
| `db_password` | Password (sensitive) |
| `security_group_id` | ID Security Group |
| `connection_string` | Connection string |

## Як змінити тип БД

### З RDS на Aurora

1. Змінити `use_aurora = true`
2. Змінити `engine` на `aurora-postgresql` або `aurora-mysql`
3. Змінити `instance_class` мінімум на `db.t3.medium`

### Змінити engine

```hcl
# PostgreSQL → MySQL
engine         = "mysql"
engine_version = "8.0.35"
```

### Змінити instance class

```hcl
# Dev → Prod
instance_class = "db.r6g.large"
multi_az       = true
```

## Особливості

- **RDS** створює `aws_db_instance` + `aws_db_parameter_group`
- **Aurora** створює `aws_rds_cluster` + `aws_rds_cluster_instance` + `aws_rds_cluster_parameter_group`
- Порт визначається автоматично: PostgreSQL = 5432, MySQL = 3306
- Password генерується автоматично якщо не задано

## Важливо

⚠️ **УВАГА:** Не забудьте `terraform destroy` після тестування!

Вартість:
- RDS db.t3.micro: ~$0.02/год
- Aurora db.t3.medium: ~$0.08/год
