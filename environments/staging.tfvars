aws_region = "us-east-2"
env_id     = "stg"
owner      = "devops@smartvault.com"

portal_ami_id   = "ami-XXXXXXXXXXXXXXXXX"
webapps_ami_id  = "ami-XXXXXXXXXXXXXXXXX"
callback_ami_id = "ami-XXXXXXXXXXXXXXXXX"

ssl_policy             = "ELBSecurityPolicy-TLS13-1-2-2021-06"
upgrade_db             = false
mysql_engine_version   = "5.7.44-RDS.20240808"
rds_storage_type       = "gp3"

asg_min          = 1
asg_desired      = 1
asg_max          = 2
webapps_asg_max  = 5

mfa_version = "3.3.0"

secret_key_twilio = "twilio secret"
db_username       = "root"
db_password       = "db password"

weekly_schedule_up    = "15 13 * * 1-5"
weekend_schedule_down = "15 3 * * 6"

cost_saving_enabled = true
alarms_enabled      = true

restricted_users = []

deployment_color        = "blue"
enable_green_deployment = false
