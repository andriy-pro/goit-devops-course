# ===========================================
# Локальні змінні
# ===========================================
#
# locals - це обчислювані значення, які використовуються в модулі.
# Вони спрощують код та уникають повторень.

locals {
  # Порт залежить від типу engine:
  # - PostgreSQL (postgres, aurora-postgresql): 5432
  # - MySQL/MariaDB (mysql, mariadb, aurora-mysql): 3306
  db_port = contains(["postgres", "aurora-postgresql"], var.engine) ? 5432 : 3306

  # Parameter family визначає набір параметрів для конкретної версії БД.
  # Формат залежить від engine:
  # - postgres15, postgres14, ...
  # - mysql8.0, mysql5.7, ...
  # - aurora-postgresql15, aurora-mysql8.0, ...
  parameter_family = lookup({
    "postgres"          = "postgres${split(".", var.engine_version)[0]}"
    "mysql"             = "mysql${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
    "mariadb"           = "mariadb${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
    "aurora-postgresql" = "aurora-postgresql${split(".", var.engine_version)[0]}"
    "aurora-mysql"      = "aurora-mysql${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
  }, var.engine, "postgres15")

  # Master password: або заданий користувачем, або автогенерований
  master_password = var.db_password != null ? var.db_password : random_password.master[0].result
}

# ===========================================
# Генерація пароля (якщо не задано)
# ===========================================
#
# Якщо користувач не передав db_password, генеруємо випадковий.
# Це безпечніше, ніж hardcoded паролі в коді.

resource "random_password" "master" {
  # Створюється тільки якщо пароль не заданий
  count = var.db_password == null ? 1 : 0

  length           = 16                          # довжина пароля
  special          = true                        # включати спецсимволи
  override_special = "!#$%&*()-_=+[]{}<>:?"     # дозволені спецсимволи
}

# ===========================================
# DB Subnet Group
# ===========================================
#
# DB Subnet Group визначає, в яких підмережах може працювати БД.
# Для Multi-AZ потрібно мінімум 2 підмережі в різних AZ.

resource "aws_db_subnet_group" "main" {
  name        = "${var.identifier}-subnet-group"
  description = "Subnet group for ${var.identifier}" # AWS не підтримує кирилицю
  subnet_ids  = var.subnet_ids # список приватних підмереж

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# ===========================================
# Security Group
# ===========================================
#
# Security Group контролює мережевий доступ до БД.
# За замовчуванням заборонено все, ми явно дозволяємо тільки потрібний трафік.

resource "aws_security_group" "main" {
  name        = "${var.identifier}-sg"
  description = "Security group for ${var.identifier} database" # AWS не підтримує кирилицю
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.identifier}-sg"
  })
}

# --- Вхідний трафік від Security Groups ---
# Дозволяє доступ від інших ресурсів (напр. EC2, EKS) через їх SG
resource "aws_security_group_rule" "ingress_sg" {
  count = length(var.allowed_security_groups)

  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = aws_security_group.main.id
  description              = "Allow from security group" # AWS не підтримує кирилицю
}

# --- Вхідний трафік від CIDR блоків ---
# Дозволяє доступ від IP-адрес/підмереж (напр. VPC CIDR)
resource "aws_security_group_rule" "ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = local.db_port
  to_port           = local.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.main.id
  description       = "Allow from CIDR blocks" # AWS не підтримує кирилицю
}

# --- Вихідний трафік ---
# Дозволяємо весь вихідний трафік (потрібно для оновлень тощо)
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"        # -1 = всі протоколи
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
  description       = "Allow all outbound" # AWS не підтримує кирилицю
}

# ===========================================
# Parameter Group (для RDS Instance)
# ===========================================
#
# Parameter Group містить налаштування БД:
# - max_connections: максимум одночасних з'єднань
# - log_statement: рівень логування SQL (PostgreSQL)
# - work_mem: пам'ять для операцій сортування (PostgreSQL)

resource "aws_db_parameter_group" "main" {
  # Створюється тільки для RDS (НЕ Aurora)
  count = var.use_aurora ? 0 : 1

  name        = "${var.identifier}-params"
  family      = local.parameter_family
  description = "Parameter group for ${var.identifier}" # AWS не підтримує кирилицю

  # --- PostgreSQL параметри ---
  # Ці параметри специфічні для PostgreSQL
  dynamic "parameter" {
    for_each = contains(["postgres"], var.engine) ? [1] : []
    content {
      name         = "max_connections"
      value        = var.max_connections
      apply_method = "pending-reboot" # статичний параметр, вимагає reboot
    }
  }

  dynamic "parameter" {
    for_each = contains(["postgres"], var.engine) ? [1] : []
    content {
      name  = "log_statement"
      value = var.log_statement # none, ddl, mod, all
    }
  }

  dynamic "parameter" {
    for_each = contains(["postgres"], var.engine) ? [1] : []
    content {
      name  = "work_mem"
      value = var.work_mem # в KB
    }
  }

  # --- MySQL параметри ---
  dynamic "parameter" {
    for_each = contains(["mysql", "mariadb"], var.engine) ? [1] : []
    content {
      name         = "max_connections"
      value        = var.max_connections
      apply_method = "pending-reboot" # статичний параметр
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-params"
  })

  # Створити новий перед видаленням старого (уникає помилок)
  lifecycle {
    create_before_destroy = true
  }
}

# ===========================================
# Cluster Parameter Group (для Aurora)
# ===========================================
#
# Aurora використовує окремий тип parameter group для кластера.

resource "aws_rds_cluster_parameter_group" "main" {
  # Створюється тільки для Aurora
  count = var.use_aurora ? 1 : 0

  name        = "${var.identifier}-cluster-params"
  family      = local.parameter_family
  description = "Cluster parameter group for ${var.identifier}" # AWS не підтримує кирилицю

  # --- Aurora PostgreSQL параметри ---
  dynamic "parameter" {
    for_each = var.engine == "aurora-postgresql" ? [1] : []
    content {
      name         = "max_connections"
      value        = var.max_connections
      apply_method = "pending-reboot" # статичний параметр
    }
  }

  dynamic "parameter" {
    for_each = var.engine == "aurora-postgresql" ? [1] : []
    content {
      name  = "log_statement"
      value = var.log_statement
    }
  }

  dynamic "parameter" {
    for_each = var.engine == "aurora-postgresql" ? [1] : []
    content {
      name  = "work_mem"
      value = var.work_mem
    }
  }

  # --- Aurora MySQL параметри ---
  dynamic "parameter" {
    for_each = var.engine == "aurora-mysql" ? [1] : []
    content {
      name         = "max_connections"
      value        = var.max_connections
      apply_method = "pending-reboot" # статичний параметр
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-cluster-params"
  })

  lifecycle {
    create_before_destroy = true
  }
}
