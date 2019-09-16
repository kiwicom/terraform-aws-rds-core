#----------------------------#
#   INSTANCE SPECIFICATION   #
#----------------------------#

resource "aws_db_instance" "instance" {
  engine                       = "postgres"
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  multi_az                     = var.multi_az
  storage_type                 = "gp2"
  allocated_storage            = var.allocated_storage
  provider                     = aws
  performance_insights_enabled = var.performance_insights_enabled
  deletion_protection          = var.deletion_protection

  #------------------------------------------------#
  #   INSTANCE SPECIFICATION / INSTANCE SETTINGS   #
  #------------------------------------------------#

  identifier           = "${var.instance_name_without_version}-v${var.major_version[var.engine_version]}"
  parameter_group_name = aws_db_parameter_group.parameter_group.name
  tags                 = {
    "env"                            = var.env[var.is_production]
    "communication_slack_channel"    = var.communication_slack_channel
    "alert_slack_channel"            = var.alert_slack_channel
    "tribe"                          = var.tribe
    "responsible_people"             = var.responsible_people
    "repository"                     = var.repository
    "auto_statement_timeout_enabled" = var.auto_statement_timeout_enabled
    "com_kiwi_devops_auto_created"   = var.com_kiwi_devops_auto_created
    "extra_backup_copy_enabled"      = var.extra_backup_copy_enabled
  }

  #---------------------------------------------------#
  #   INSTANCE SPECIFICATION / MASTER USER SETTINGS   #
  #---------------------------------------------------#

  username = var.master_username
  password = var.master_password

  #-------------------------------------------------#
  #   INSTANCE SPECIFICATION / NETWORK & SECURITY   #
  #-------------------------------------------------#

  db_subnet_group_name   = var.subnets[var.network]
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

  backup_retention_period = var.is_production * var.backup_retention_period
  backup_window           = var.backup_window
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
  maintenance_window         = var.maintenance_window

  #--------------------------------------------#
  #   INSTANCE SPECIFICATION / APPLY OPTIONS   #
  #--------------------------------------------#

  apply_immediately = true
}

resource "aws_db_parameter_group" "parameter_group" {
  name     = "${var.instance_name_without_version}-v${var.major_version[var.engine_version]}"
  family   = "postgres${var.major_version[var.engine_version]}"
  provider = aws

  #-------------------------------------------------#
  #   PARAMETERS / CONNECTIONS AND AUTHENTICATION   #
  #-------------------------------------------------#

  parameter {
    # (s) Time between issuing TCP keepalives.
    name         = "tcp_keepalives_idle"
    value        = var.parameter_tcp_keepalives_idle
    apply_method = "immediate"
  }
  parameter {
    # (s) Time between TCP keepalive retransmits.
    name         = "tcp_keepalives_interval"
    value        = var.parameter_tcp_keepalives_interval
    apply_method = "immediate"
  }
  parameter {
    # Specifies the number of TCP keepalives that can be lost before the server's connection to the client is considered dead.
    name         = "tcp_keepalives_count"
    value        = var.parameter_tcp_keepalives_count
    apply_method = "immediate"
  }
  parameter {
    # Sets the maximum number of concurrent connections.
    name         = "max_connections"
    value        = var.parameter_max_connections
    apply_method = "pending-reboot"
  }
  parameter {
    # Enforce SSL connection.
    name         = "rds.force_ssl"
    value        = var.parameter_rds_force_ssl
    apply_method = "pending-reboot"
  }

  #----------------------------------------------#
  #   PARAMETERS / RESOURCE USAGE (EXCEPT WAL)   #
  #----------------------------------------------#

  parameter {
    # (kB) Sets the maximum memory to be used for query workspaces.
    name         = "work_mem"
    value        = var.parameter_work_mem
    apply_method = "immediate"
  }
  parameter {
    # Lists shared libraries to preload into server.
    name         = "shared_preload_libraries"
    value        = var.parameter_shared_preload_libraries
    apply_method = "pending-reboot"
  }
  parameter {
    # The accumulated cost that will cause the vacuuming process to sleep. The default value is 200.
    name         = "vacuum_cost_limit"
    value        = var.parameter_vacuum_cost_limit
    apply_method = "immediate"
  }
  parameter {
    # (ms) Specifies the delay between activity rounds for the background writer. The default value 200.
    name         = "bgwriter_delay"
    value        = var.parameter_bgwriter_delay
    apply_method = "immediate"
  }
  parameter {
    # Sets the maximum number of concurrent worker processes.
    name         = "max_worker_processes"
    value        = var.pg_max_worker_processes[var.instance_class]
    apply_method = "pending-reboot"
  }
  parameter {
    # Sets the maximum number of concurrent worker processes.
    name         = "max_parallel_workers"
    value        = var.pg_max_worker_processes[var.instance_class]
    apply_method = "immediate"
  }
  parameter {
    # Sets the maximum number of parallel processes per executor node.
    name         = "max_parallel_workers_per_gather"
    value        = var.pg_max_parallel_workers_per_gather[var.instance_class]
    apply_method = "immediate"
  }

  #----------------------------------#
  #   PARAMETERS / WRITE AHEAD LOG   #
  #----------------------------------#

  # - Checkpoints -
  # Following parameters are related to each other. When changed, checkpoint_timeout recommendation is 30 - 60 minut.
  # According to that change, max_wal_size should be set according to https://blog.2ndquadrant.com/basics-of-tuning-checkpoints/
  parameter {
    # (s) Maximum time between automatic WAL checkpoints. The valid range is between 30 seconds and one hour.
    # The default is five minutes (5min). Increasing this parameter can increase the amount of time needed for crash recovery.
    name = "checkpoint_timeout"

    value        = var.parameter_checkpoint_timeout
    apply_method = "immediate"
  }
  parameter {
    # (16MB) Sets the WAL size that triggers a checkpoint.
    name         = "max_wal_size"
    value        = var.parameter_max_wal_size
    apply_method = "immediate"
  }

  #------------------------------#
  #   PARAMETERS / REPLICATION   #
  #------------------------------#

  parameter {
    # (ms) Sets the maximum delay before canceling queries when a hot standby server is processing streamed WAL data.
    name         = "max_standby_streaming_delay"
    value        = var.parameter_max_standby_streaming_delay
    apply_method = "immediate"
  }

  #-------------------------------#
  #   PARAMETERS / QUERY TUNING   #
  #-------------------------------#

  parameter {
    # Sets the planners estimate of the cost of a nonsequentially fetched disk page.
    name         = "random_page_cost"
    value        = var.parameter_random_page_cost
    apply_method = "immediate"
  }
  parameter {
    # (8kB) Sets the planners assumption about the size of the disk cache.
    name         = "effective_cache_size"
    value        = var.parameter_effective_cache_size
    apply_method = "immediate"
  }

  #----------------------------------------------#
  #   PARAMETERS / ERROR REPORTING AND LOGGING   #
  #----------------------------------------------#

  parameter {
    # Causes the duration of each completed statement to be logged if the statement ran for at least the specified number of milliseconds.
    name         = "log_rotation_age"
    value        = var.parameter_log_rotation_age
    apply_method = "immediate"
  }

  #-------------------------------------#
  #   PARAMETERS / RUNTIME STATISTICS   #
  #-------------------------------------#

  parameter {
    # Use this parmater if monitored by pganalyze. Collects timing statistics on database IO activity. This parameter is off by default,
    # because it will repeatedly query the operating system for the current time, which may cause significant overhead on some platforms.
    name = "track_io_timing"

    value        = var.parameter_track_io_timing
    apply_method = "immediate"
  }
  parameter {
    # (B) Sets the size reserved for pg_stat_activity.current_query.
    name         = "track_activity_query_size"
    value        = var.parameter_track_activity_query_size
    apply_method = "pending-reboot"
  }

  #-----------------------------#
  #   PARAMETERS / AUTOVACUUM   #
  #-----------------------------#

  parameter {
    # (ms) Sets the minimum execution time above which autovacuum actions will be logged.
    name         = "log_autovacuum_min_duration"
    value        = var.parameter_log_autovacuum_min_duration
    apply_method = "immediate"
  }
  parameter {
    # Minimum number of tuple updates or deletes prior to vacuum.
    name         = "autovacuum_vacuum_threshold"
    value        = var.parameter_autovacuum_vacuum_threshold
    apply_method = "immediate"
  }
  parameter {
    # Minimum number of tuple inserts, updates or deletes prior to analyze.
    name         = "autovacuum_analyze_threshold"
    value        = var.parameter_autovacuum_analyze_threshold
    apply_method = "immediate"
  }
  parameter {
    # Number of tuple updates or deletes prior to vacuum as a fraction of reltuples.
    name         = "autovacuum_vacuum_scale_factor"
    value        = var.parameter_autovacuum_vacuum_scale_factor
    apply_method = "immediate"
  }

  #---------------------------------------------#
  #   PARAMETERS / CLIENT CONNECTION DEFAULTS   #
  #---------------------------------------------#

  parameter {
    # (ms) Sets the maximum allowed duration of any idling transaction.
    name         = "idle_in_transaction_session_timeout"
    value        = var.parameter_idle_in_transaction_session_timeout
    apply_method = "immediate"
  }

  #-------------------------#
  #   PARAMETERS / CUSTOM   #
  #-------------------------#


  parameter {
    # Selects which statements are tracked by pg_stat_statements.
    name         = "pg_stat_statements.track"
    value        = var.parameter_pg_stat_statements_track
    apply_method = "immediate"
  }
}

#----------------------------#
#   MONITORING / CLOUDWATCH  #
#----------------------------#

module "cloudwatch_alert" {
  source  = "kiwicom/rds-alarms/aws"
  version = "2.0.0"

  create_alarms = var.is_production

  database_identifier        = "${var.instance_name_without_version}-v${var.major_version[var.engine_version]}"
  network                    = var.network
  database_storage           = var.allocated_storage
  slack_lambda_sns_topic_arn = var.slack_lambda_sns_topic_arn
  pager_duty_sns_topic_arn   = var.pager_duty_sns_topic_arn
  slack_channel              = "#${var.alert_slack_channel}"
  region                     = var.regions[var.network]

  # Max values
  max_connection_count        = var.max_connection_counts[var.instance_class]
  db_instance_class_memory    = var.db_instance_class_memory[var.instance_class]
  db_instance_max_cpu_credits = var.db_instance_max_cpu_credits[var.instance_class]

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
  create_replica_lag_alert = "0"
  replica_lag_threshold    = var.replica_lag_threshold

  providers = {
    aws = aws
  }
}

#--------------------------#
#   MONITORING / DATADOG   #
#--------------------------#

module "dd_rds_dashboard_test_modules" {
  source  = "kiwicom/rds-timeboard/datadog"
  version = "2.0.0"

  create_dashboard = var.is_production

  database_identifier = "${var.instance_name_without_version}-v${var.major_version[var.engine_version]}"
  hostname            = aws_db_instance.instance.address

  providers = {
    aws = aws
  }
}
