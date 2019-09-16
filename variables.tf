#-------------------------------#
#   ENVIRONMENT SPECIFICATION   #
#-------------------------------#

variable "aws_account_id" {
  description = "The AWS account id"
  type        = number
}

variable "instance_name_without_version" {
}

variable "network" {
  type    = string
  default = "eu-west-1"
}

variable "regions" {
  type        = map(string)
  description = "Map of vpc ids"

  default = {
    eu-west-1        = "eu-west-1"
    eu-central-1-old = "eu-central-1"
    eu-central-1-new = "eu-central-1"
  }
}

variable "subnets" {
  type        = map(string)
  description = "Map of db_subnet_group_name"
}

variable "is_production" {
}

variable "env" {
  type        = map(string)
  description = "Map of credits for instances"

  default = {
    "1" = "prod"
    "0" = "non-prod"
  }
}

variable "read_replica" {
  type    = string
  default = "0"
}

variable "tribe" {
}

variable "responsible_people" {
}

variable "communication_slack_channel" {
}

variable "alert_slack_channel" {
}

variable "repository" {
}

variable "auto_statement_timeout_enabled" {
}

variable "com_kiwi_devops_auto_created" {
}

variable "extra_backup_copy_enabled" {
}

#----------------------------#
#   INSTANCE SPECIFICATION   #
#----------------------------#

variable "major_version" {
  type        = map(string)
  description = "Map of Postges versions"

  default = {
    # 10
    "10.1" = "10"
    "10.3" = "10"
    "10.4" = "10"
    "10.5" = "10"
    "10.6" = "10"

    # 11
    "11.1" = "11"
    "11.2" = "11"
    "11.4" = "11"
  }
}

variable "engine_version" {
}

variable "read_replica_engine_version" {
}

variable "instance_class" {
}

variable "read_replica_instance_class" {
}

variable "multi_az" {
}

variable "allocated_storage" {
}

variable "master_id" {
  type    = string
  default = ""
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "replica_performance_insights_enabled" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "replica_deletion_protection" {
  type    = bool
  default = false
}

#---------------------------------------------------#
#   INSTANCE SPECIFICATION / MASTER USER SETTINGS   #
#---------------------------------------------------#

variable "master_username" {
}

variable "master_password" {
}

#-------------------------------------------------#
#   INSTANCE SPECIFICATION / NETWORK & SECURITY   #
#-------------------------------------------------#

variable "publicly_accessible" {
}

variable "security_group" {
}

#------------------------------------------------#
#   INSTANCE SPECIFICATION / DATABASE OPTIONS    #
#------------------------------------------------#

variable "db_name" {
}

#-------------------------------------#
#   INSTANCE SPECIFICATION / BACKUP   #
#-------------------------------------#

variable "backup_retention_period" {
}

variable "backup_window" {
}

#-----------------------------------------#
#   INSTANCE SPECIFICATION / MONITORING   #
#-----------------------------------------#

variable "enhanced_monitoring" {
  type        = map(string)
  description = "Map of monitoring role arn"
}

#------------------------------------------#
#   INSTANCE SPECIFICATION / MAINTENANCE   #
#------------------------------------------#

variable "maintenance_window" {
}

#-------------------------------------------------#
#   PARAMETERS / CONNECTIONS AND AUTHENTICATION   #
#-------------------------------------------------#

variable "parameter_tcp_keepalives_idle" {
  type    = string
  default = "300"
}

variable "parameter_tcp_keepalives_interval" {
  type    = string
  default = "30"
}

variable "parameter_tcp_keepalives_count" {
  type    = string
  default = "3"
}

variable "parameter_max_connections" {
  type    = string
  default = "LEAST({DBInstanceClassMemory/9531392},5000)"
}

variable "parameter_rds_force_ssl" {
  type    = string
  default = "1"
}

#----------------------------------------------#
#   PARAMETERS / RESOURCE USAGE (EXCEPT WAL)   #
#----------------------------------------------#

variable "parameter_work_mem" {
  type    = string
  default = "{DBInstanceClassMemory/819200}"
}

variable "parameter_shared_preload_libraries" {
  type    = string
  default = "pg_stat_statements"
}

variable "parameter_vacuum_cost_limit" {
  type    = string
  default = "2000"
}

variable "parameter_bgwriter_delay" {
  type    = string
  default = "50"
}

variable "pg_max_worker_processes" {
  type        = map(string)
  description = "Map of Postges max_worker_processes"

  default = {
    # t2 instances
    "db.t2.micro"  = "1"
    "db.t2.small"  = "1"
    "db.t2.medium" = "2"
    "db.t2.large"  = "2"
    "db.t2.xlarge" = "4"

    # t2 instances
    "db.t3.micro"  = "2"
    "db.t3.small"  = "2"
    "db.t3.medium" = "2"
    "db.t3.large"  = "2"

    # m5 instances
    "db.m5.large"   = "2"
    "db.m5.xlarge"  = "4"
    "db.m5.2xlarge" = "8"
    "db.m5.4xlarge" = "16"

    # m4 instances
    "db.m4.large"   = "2"
    "db.m4.xlarge"  = "4"
    "db.m4.2xlarge" = "8"
    "db.m4.4xlarge" = "16"

    # m3 instances
    "db.m3.xlarge" = "4"

    # r5 instances
    "db.r5.large"   = "2"
    "db.r5.xlarge"  = "4"
    "db.r5.2xlarge" = "8"
    "db.r5.4xlarge" = "16"

    # r4 instances
    "db.r4.large"   = "2"
    "db.r4.xlarge"  = "4"
    "db.r4.2xlarge" = "8"
    "db.r4.4xlarge" = "16"

    # r3 instances
    "db.r3.4xlarge" = "16"
  }
}

variable "pg_max_parallel_workers_per_gather" {
  type        = map(string)
  description = "Map of Postges max_parallel_workers_per_gather"

  default = {
    # t2 instances
    "db.t2.micro"  = "0"
    "db.t2.small"  = "0"
    "db.t2.medium" = "1"
    "db.t2.large"  = "1"
    "db.t2.xlarge" = "2"

    # t2 instances
    "db.t3.micro"  = "1"
    "db.t3.small"  = "1"
    "db.t3.medium" = "1"
    "db.t3.large"  = "1"

    # m5 instances
    "db.m5.large"   = "1"
    "db.m5.xlarge"  = "2"
    "db.m5.2xlarge" = "4"
    "db.m5.4xlarge" = "8"

    # m4 instances
    "db.m4.large"   = "1"
    "db.m4.xlarge"  = "2"
    "db.m4.2xlarge" = "4"
    "db.m4.4xlarge" = "8"

    # m3 instances
    "db.m3.xlarge" = "2"

    # r5 instances
    "db.r5.large"   = "1"
    "db.r5.xlarge"  = "2"
    "db.r5.2xlarge" = "4"
    "db.r5.4xlarge" = "8"

    # r4 instances
    "db.r4.large"   = "1"
    "db.r4.xlarge"  = "2"
    "db.r4.2xlarge" = "4"
    "db.r4.4xlarge" = "8"

    # r3 instances
    "db.r3.4xlarge" = "8"
  }
}

#----------------------------------#
#   PARAMETERS / WRITE AHEAD LOG   #
#----------------------------------#

variable "parameter_checkpoint_timeout" {
  type = string

  # 5 minutes
  default = "300"
}

variable "parameter_max_wal_size" {
  type = string

  # 2 GB
  default = "192"
}

#------------------------------#
#   PARAMETERS / REPLICATION   #
#------------------------------#

variable "parameter_max_standby_streaming_delay" {
  type = string

  # 30 s
  default = "3000"
}

#-------------------------------#
#   PARAMETERS / QUERY TUNING   #
#-------------------------------#

variable "parameter_random_page_cost" {
  type    = string
  default = "1.1"
}

variable "parameter_effective_cache_size" {
  type = string

  # 3/4 of instance class
  default = "{DBInstanceClassMemory/10922}"
}

#----------------------------------------------#
#   PARAMETERS / ERROR REPORTING AND LOGGING   #
#----------------------------------------------#

variable "parameter_log_rotation_age" {
  type    = string
  default = "1440"
}

#-------------------------------------#
#   PARAMETERS / RUNTIME STATISTICS   #
#-------------------------------------#

variable "parameter_track_io_timing" {
  type    = string
  default = "0"
}

variable "parameter_track_activity_query_size" {
  type    = string
  default = "2048"
}

#-----------------------------#
#   PARAMETERS / AUTOVACUUM   #
#-----------------------------#

variable "parameter_log_autovacuum_min_duration" {
  type    = string
  default = "0"
}

variable "parameter_autovacuum_vacuum_threshold" {
  type    = string
  default = "100"
}

variable "parameter_autovacuum_analyze_threshold" {
  type    = string
  default = "100"
}

variable "parameter_autovacuum_vacuum_scale_factor" {
  type    = string
  default = "0.05"
}

#---------------------------------------------#
#   PARAMETERS / CLIENT CONNECTION DEFAULTS   #
#---------------------------------------------#

variable "parameter_idle_in_transaction_session_timeout" {
  default = "18000000"
}


#-------------------------#
#   PARAMETERS / CUSTOM   #
#-------------------------#

variable "parameter_pg_stat_statements_track" {
  type    = string
  default = "ALL"
}

#----------------------------#
#   MONITORING / CLOUDWATCH  #
#----------------------------#

variable "slack_lambda_sns_topic_arn" {
}

variable "pager_duty_sns_topic_arn" {
}

# Max values
variable "max_connection_counts" {
  type        = map(string)
  description = "Map of rds max connection counts"

  default = {
    # t2 instances
    "db.t2.micro"  = "87"
    "db.t2.small"  = "198"
    "db.t2.medium" = "413"
    "db.t2.large"  = "856"
    "db.t2.xlarge" = "1743"

    # t3 instances
    "db.t3.micro"  = "87"
    "db.t3.small"  = "193"
    "db.t3.medium" = "405"
    "db.t3.large"  = "844"

    # m5 instances
    "db.m5.large"   = "856"
    "db.m5.xlarge"  = "1743"
    "db.m5.2xlarge" = "3357"
    "db.m5.4xlarge" = "5000"

    # m4 instances
    "db.m4.large"   = "856"
    "db.m4.xlarge"  = "1743"
    "db.m4.2xlarge" = "3357"
    "db.m4.4xlarge" = "5000"

    # m3 instances
    "db.m3.xlarge" = "1689"

    # r5 instances
    "db.r5.large"   = "1660"
    "db.r5.xlarge"  = "3351"
    "db.r5.2xlarge" = "5000"
    "db.r5.4xlarge" = "5000"

    # r4 instances
    "db.r4.large"   = "1660"
    "db.r4.xlarge"  = "3351"
    "db.r4.2xlarge" = "5000"
    "db.r4.4xlarge" = "5000"

    # r3 instances
    "db.r3.4xlarge" = "5000"
  }
}

variable "db_instance_class_memory" {
  type        = map(string)
  description = "Map of db instance class memory"

  default = {
    # t2 instances
    "db.t2.micro"  = "1"
    "db.t2.small"  = "2"
    "db.t2.medium" = "4"
    "db.t2.large"  = "8"
    "db.t2.xlarge" = "16"

    # t3 instances
    "db.t3.micro"  = "1"
    "db.t3.small"  = "2"
    "db.t3.medium" = "4"
    "db.t3.large"  = "8"

    # m5 instances
    "db.m5.large"   = "8"
    "db.m5.xlarge"  = "16"
    "db.m5.2xlarge" = "32"
    "db.m5.4xlarge" = "64"

    # m4 instances
    "db.m4.large"   = "8"
    "db.m4.xlarge"  = "16"
    "db.m4.2xlarge" = "32"
    "db.m4.4xlarge" = "64"

    # m3 instances
    "db.m3.xlarge" = "15"

    # r5 instances
    "db.r5.large"   = "16"
    "db.r5.xlarge"  = "32"
    "db.r5.2xlarge" = "64"
    "db.r5.4xlarge" = "128"

    # r4 instances
    "db.r4.large"   = "15"
    "db.r4.xlarge"  = "30"
    "db.r4.2xlarge" = "61"
    "db.r4.4xlarge" = "122"

    # r3 instances
    "db.r3.4xlarge" = "0"
  }
}

variable "db_instance_max_cpu_credits" {
  type        = map(string)
  description = "Map of db instance max cpu credits"

  default = {
    # t2 instances
    "db.t2.micro"  = "144"
    "db.t2.small"  = "288"
    "db.t2.medium" = "576"
    "db.t2.large"  = "864"
    "db.t2.xlarge" = "1296"

    # t3 instances
    "db.t3.micro"  = "288"
    "db.t3.small"  = "576"
    "db.t3.medium" = "576"
    "db.t3.large"  = "864"

    # m5 instances (without credits)
    "db.m5.large"   = "0"
    "db.m5.xlarge"  = "0"
    "db.m5.2xlarge" = "0"
    "db.m5.4xlarge" = "0"

    # m4 instances (without credits)
    "db.m4.large"   = "0"
    "db.m4.xlarge"  = "0"
    "db.m4.2xlarge" = "0"
    "db.m4.4xlarge" = "0"

    # m3 instances (without credits)
    "db.m3.xlarge" = "0"

    # r5 instances (without credits)
    "db.r5.large"   = "0"
    "db.r5.xlarge"  = "0"
    "db.r5.2xlarge" = "0"
    "db.r5.4xlarge" = "0"
    "db.r5.8xlarge" = "0"

    # r4 instances (without credits)
    "db.r4.large"   = "0"
    "db.r4.xlarge"  = "0"
    "db.r4.2xlarge" = "0"
    "db.r4.4xlarge" = "0"
    "db.r4.8xlarge" = "0"

    # r3 instances (without credits)
    "db.r3.4xlarge" = "0"
  }
}

# storage alerts
variable "create_storage_80_alert" {
  type    = bool
  default = true
}

variable "create_storage_85_alert" {
  type    = bool
  default = true
}

variable "create_storage_90_alert" {
  type    = bool
  default = true
}

variable "create_storage_95_alert" {
  type    = bool
  default = true
}

# Connection count alerts
variable "create_connction_count_80_alert" {
  type    = bool
  default = true
}

variable "create_connction_count_90_alert" {
  type    = bool
  default = true
}

# CPU alerts
variable "create_cpu_95_alert" {
  type    = bool
  default = true
}

variable "cpu_alarm_enable_pd" {
  type    = bool
  default = false
}

variable "is_credit_instance" {
  type        = map(string)
  description = "Map of credits for instances"

  default = {
    # t2 instances
    "db.t2.micro"  = "1"
    "db.t2.small"  = "1"
    "db.t2.medium" = "1"
    "db.t2.large"  = "1"
    "db.t2.xlarge" = "1"

    # t3 instances
    "db.t3.micro"  = "1"
    "db.t3.small"  = "1"
    "db.t3.medium" = "1"
    "db.t3.large"  = "1"

    # m5 instances (without credits)
    "db.m5.large"   = "0"
    "db.m5.xlarge"  = "0"
    "db.m5.2xlarge" = "0"
    "db.m5.4xlarge" = "0"

    # m4 instances (without credits)
    "db.m4.large"   = "0"
    "db.m4.xlarge"  = "0"
    "db.m4.2xlarge" = "0"
    "db.m4.4xlarge" = "0"

    # m3 instances (without credits)
    "db.m3.xlarge" = "0"

    # r5 instances (without credits)
    "db.r5.large"   = "0"
    "db.r5.xlarge"  = "0"
    "db.r5.2xlarge" = "0"
    "db.r5.4xlarge" = "0"
    "db.r5.8xlarge" = "0"

    # r4 instances (without credits)
    "db.r4.large"   = "0"
    "db.r4.xlarge"  = "0"
    "db.r4.2xlarge" = "0"
    "db.r4.4xlarge" = "0"

    # r3 instances (without credits)
    "db.r3.4xlarge" = "0"
  }
}

# Memory alerts
variable "create_memory_80_alert" {
  type    = bool
  default = true
}

variable "create_memory_90_alert" {
  type    = bool
  default = true
}

# Replication alerts
variable "create_replica_lag_alert" {
  type    = bool
  default = false
}

variable "replica_lag_threshold" {
  type    = string
  default = "1800"
}
