#----------------------------#
#   INSTANCE SPECIFICATION   #
#----------------------------#

resource "aws_db_instance" "instance-replica" {
  count = var.read_replica ? 1 : 0

  engine                       = "postgres"
  engine_version               = var.read_replica_engine_version
  instance_class               = var.read_replica_instance_class
  multi_az                     = "0"
  storage_type                 = "gp2"
  allocated_storage            = var.allocated_storage
  replicate_source_db          = aws_db_instance.instance.id
  provider                     = aws
  performance_insights_enabled = var.replica_performance_insights_enabled
  deletion_protection          = var.replica_deletion_protection

  #------------------------------------------------#
  #   INSTANCE SPECIFICATION / INSTANCE SETTINGS   #
  #------------------------------------------------#

  identifier           = "${var.instance_name_without_version}-replica-v${var.major_version[var.engine_version]}"
  parameter_group_name = aws_db_parameter_group.parameter_group.name
  tags                 = {
    "env"                          = var.env[var.is_production]
    "communication_slack_channel"  = var.communication_slack_channel
    "alert_slack_channel"          = var.alert_slack_channel
    "tribe"                        = var.tribe
    "responsible_people"           = var.responsible_people
    "repository"                   = var.repository
    "com_kiwi_devops_auto_created" = var.com_kiwi_devops_auto_created
  }

  #-------------------------------------------------#
  #   INSTANCE SPECIFICATION / NETWORK & SECURITY   #
  #-------------------------------------------------#

  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = [
    var.security_group,
  ]

  #------------------------------------------------#
  #   INSTANCE SPECIFICATION / DATABASE OPTIONS    #
  #------------------------------------------------#

  name = var.db_name

  #-------------------------------------#
  #   INSTANCE SPECIFICATION / BACKUP   #
  #-------------------------------------#

  backup_retention_period = "0"
  backup_window           = "00:00-00:30"
  skip_final_snapshot     = "false"

  #-----------------------------------------#
  #   INSTANCE SPECIFICATION / MONITORING   #
  #-----------------------------------------#

  monitoring_interval = var.is_production * 60
  monitoring_role_arn = var.enhanced_monitoring[var.is_production]

  #------------------------------------------#
  #   INSTANCE SPECIFICATION / MAINTENANCE   #
  #------------------------------------------#

  auto_minor_version_upgrade = "true"
  maintenance_window         = "Mon:03:30-Mon:04:00"

  #--------------------------------------------#
  #   INSTANCE SPECIFICATION / APPLY OPTIONS   #
  #--------------------------------------------#

  apply_immediately = true
}

#----------------------------#
#   MONITORING / CLOUDWATCH  #
#----------------------------#

module "replica_cloudwatch_alert" {
  source  = "kiwicom/rds-alarms/aws"
  version = "2.0.0"

  database_identifier        = "${var.instance_name_without_version}-replica-v${var.major_version[var.engine_version]}"
  network                    = var.network
  database_storage           = var.allocated_storage
  slack_lambda_sns_topic_arn = var.slack_lambda_sns_topic_arn
  pager_duty_sns_topic_arn   = var.pager_duty_sns_topic_arn
  slack_channel              = "#${var.alert_slack_channel}"
  region                     = var.regions[var.network]
  create_alarms              = (var.is_production * var.read_replica) > 0

  # Max values
  max_connection_count        = var.max_connection_counts[var.read_replica_instance_class]
  db_instance_class_memory    = var.db_instance_class_memory[var.read_replica_instance_class]
  db_instance_max_cpu_credits = var.db_instance_max_cpu_credits[var.read_replica_instance_class]

  # Storage alerts
  create_storage_80_alert = var.create_storage_80_alert
  create_storage_85_alert = var.create_storage_85_alert
  create_storage_90_alert = var.create_storage_90_alert
  create_storage_95_alert = var.create_storage_95_alert

  # Connection count alerts
  create_connction_count_80_alert = var.create_connction_count_80_alert
  create_connction_count_90_alert = var.create_connction_count_90_alert

  # CPU alerts
  create_cpu_95_alert     = var.create_cpu_95_alert
  cpu_alarm_enable_pd     = var.cpu_alarm_enable_pd
  create_cpu_credit_alert = var.is_credit_instance[var.instance_class]

  # Memory alerts
  create_memory_80_alert = var.create_memory_80_alert
  create_memory_90_alert = var.create_memory_90_alert

  # Replication alerts
  create_replica_lag_alert = var.create_replica_lag_alert
  replica_lag_threshold    = var.replica_lag_threshold
}

#--------------------------#
#   MONITORING / DATADOG   #
#--------------------------#

module "replica_dd_rds_dashboard_test_modules" {
  source  = "kiwicom/rds-timeboard/datadog"
  version = "2.0.0"

  create_dashboard = (var.is_production * var.read_replica) > 0

  database_identifier = "${var.instance_name_without_version}-replica-v${var.major_version[var.engine_version]}"
  hostname            = aws_db_instance.instance.address
}
