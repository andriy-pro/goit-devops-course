# ===========================================
# Aurora Cluster (створюється якщо use_aurora = true)
# ===========================================
#
# Aurora - це cloud-native база даних від AWS з покращеною продуктивністю.
# Відмінності від звичайного RDS:
# - Автоматичне масштабування сховища (10GB - 128TB)
# - Швидший failover (секунди замість хвилин)
# - До 15 read replicas
# - Сумісність з PostgreSQL та MySQL
#
# Структура Aurora:
# 1. aws_rds_cluster - сам кластер (зберігає дані)
# 2. aws_rds_cluster_instance - інстанси (writer/reader)

resource "aws_rds_cluster" "main" {
  count = var.use_aurora ? 1 : 0

  # Унікальний ідентифікатор кластеру
  cluster_identifier = var.identifier

  # --- Налаштування Engine ---
  # Для Aurora: aurora-postgresql або aurora-mysql
  engine         = var.engine
  engine_version = var.engine_version

  # --- Налаштування бази даних ---
  database_name   = var.db_name          # назва БД
  master_username = var.db_username      # master username
  master_password = local.master_password # master password

  # --- Мережеві налаштування ---
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]
  port                   = local.db_port

  # --- Parameter Group ---
  # Для Aurora використовується cluster parameter group
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main[0].name

  # --- Шифрування ---
  storage_encrypted = true # завжди шифруємо дані

  # --- Резервне копіювання ---
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "03:00-04:00" # вікно бекапів (UTC)

  # --- Захист від видалення ---
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"
  deletion_protection       = var.deletion_protection

  tags = merge(var.tags, {
    Name = var.identifier
  })
}

# ===========================================
# Aurora Writer Instance (основний інстанс)
# ===========================================
#
# Writer - це інстанс, який обробляє всі write операції.
# В Aurora завжди є один writer.

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.identifier}-writer"
  cluster_identifier = aws_rds_cluster.main[0].id

  # Engine налаштування (мають співпадати з кластером)
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class # для Aurora мінімум db.t3.medium

  # Мережа
  db_subnet_group_name = aws_db_subnet_group.main.name
  publicly_accessible  = false # НЕ публічний!

  # Performance Insights для моніторингу
  performance_insights_enabled = true

  tags = merge(var.tags, {
    Name = "${var.identifier}-writer"
    Role = "writer"
  })
}

# ===========================================
# Aurora Reader Instance (для HA та балансування навантаження)
# ===========================================
#
# Reader - це інстанс для read операцій.
# Створюється тільки якщо multi_az = true.
# Переваги:
# - Розвантажує writer від read операцій
# - Автоматично стає writer при failover
# - Можна використовувати reader_endpoint для read-only з'єднань

resource "aws_rds_cluster_instance" "reader" {
  # Створюється тільки якщо use_aurora = true І multi_az = true
  count = var.use_aurora && var.multi_az ? 1 : 0

  identifier         = "${var.identifier}-reader"
  cluster_identifier = aws_rds_cluster.main[0].id

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_subnet_group_name = aws_db_subnet_group.main.name
  publicly_accessible  = false

  performance_insights_enabled = true

  tags = merge(var.tags, {
    Name = "${var.identifier}-reader"
    Role = "reader"
  })
}
