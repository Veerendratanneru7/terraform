aws_region = "us-east-2"
env_id     = "prod"
owner      = "devops@smartvault.com"

portal_ami_id   = "ami-XXXXXXXXXXXXXXXXX"
webapps_ami_id  = "ami-XXXXXXXXXXXXXXXXX"
callback_ami_id = "ami-XXXXXXXXXXXXXXXXX"

ssl_policy             = "ELBSecurityPolicy-TLS13-1-2-2021-06"
upgrade_db             = false
mysql_engine_version   = "5.7.44-RDS.20240808"
rds_storage_type       = "gp3"

asg_min          = 2
asg_desired      = 2
asg_max          = 4
webapps_asg_max  = 10

mfa_version = "3.3.0"

secret_key_twilio = "twilio secret"
db_username       = "root"
db_password       = "db password"

weekly_schedule_up    = ""
weekend_schedule_down = ""

cost_saving_enabled = false
alarms_enabled      = true

restricted_users = []

deployment_color        = "blue"
enable_green_deployment = false
