# ===========================================
# RDS Instance (створюється якщо use_aurora = false)
# ===========================================
#
# Цей ресурс створює звичайний RDS інстанс (не Aurora).
# Використовується для dev/test середовищ або коли Aurora не потрібна.
#
# Умова створення: count = var.use_aurora ? 0 : 1
# Якщо use_aurora = true, цей ресурс НЕ створюється (count = 0)
# Якщо use_aurora = false, створюється 1 інстанс (count = 1)

resource "aws_db_instance" "main" {
  count = var.use_aurora ? 0 : 1

  # Унікальний ідентифікатор інстансу в AWS
  identifier = var.identifier

  # --- Налаштування Engine ---
  engine         = var.engine         # postgres, mysql, mariadb
  engine_version = var.engine_version # версія (напр. 15.4)
  instance_class = var.instance_class # клас інстансу (напр. db.t3.micro)

  # --- Налаштування сховища ---
  allocated_storage     = var.allocated_storage     # початковий розмір в GB
  max_allocated_storage = var.allocated_storage * 2 # автомасштабування до 2x
  storage_type          = "gp3"                     # тип сховища (gp3 - найновіший)
  storage_encrypted     = true                      # шифрування даних

  # --- Налаштування бази даних ---
  db_name  = var.db_name        # назва БД для створення
  username = var.db_username    # master username
  password = local.master_password # master password (може бути автогенерований)

  # --- Мережеві налаштування ---
  db_subnet_group_name   = aws_db_subnet_group.main.name # група підмереж
  vpc_security_group_ids = [aws_security_group.main.id]  # security groups
  publicly_accessible    = false                         # НЕ публічний (безпека!)
  port                   = local.db_port                 # порт (5432 для PG, 3306 для MySQL)

  # --- Висока доступність ---
  multi_az = var.multi_az # true = standby в іншій AZ (дорожче, але надійніше)

  # --- Parameter Group ---
  # Містить налаштування БД (max_connections, log_statement, work_mem)
  parameter_group_name = aws_db_parameter_group.main[0].name

  # --- Резервне копіювання ---
  backup_retention_period = var.backup_retention_period # днів зберігання бекапів
  backup_window           = "03:00-04:00"               # вікно бекапів (UTC)
  maintenance_window      = "Mon:04:00-Mon:05:00"       # вікно обслуговування

  # --- Захист від видалення ---
  skip_final_snapshot       = var.skip_final_snapshot # пропустити snapshot при delete
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"
  deletion_protection       = var.deletion_protection # захист від випадкового видалення

  # --- Performance Insights ---
  # Безкоштовно для t3 інстансів, допомагає аналізувати продуктивність
  performance_insights_enabled = true

  # --- Теги ---
  tags = merge(var.tags, {
    Name = var.identifier
  })
}
