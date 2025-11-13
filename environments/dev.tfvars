aws_region = "us-east-2"
owner      = "devops@smartvault.com"

portal_ami_id   = "ami-03d900e98e70accc9"
webapps_ami_id  = "ami-0bbc596e2ce654da8"
callback_ami_id = "ami-02aea9aab788c2631"

ssl_policy             = "ELBSecurityPolicy-TLS13-1-2-2021-06"
upgrade_db             = false
mysql_engine_version   = "5.7.44-RDS.20240808"
rds_storage_type       = "gp3"

asg_min          = 1
asg_desired      = 1
asg_max          = 1
webapps_asg_max  = 5

mfa_version = "3.3.0"

secret_key_twilio = "twilio secret"
db_username       = "root"
db_password       = "db password"

weekly_schedule_up    = "15 13 * * 1-5"
weekend_schedule_down = "15 3 * * 6"

cost_saving_enabled = false
alarms_enabled      = true

restricted_users = []

deployment_color        = "blue"
enable_green_deployment = false
