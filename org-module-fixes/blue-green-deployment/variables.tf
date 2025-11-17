# ==============================================================================
# BLUE-GREEN DEPLOYMENT VARIABLES
# ==============================================================================

# Application Identification
variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "component_name" {
  description = "Name of the component (portal, webapps, callback)"
  type        = string
}

# Deployment Configuration
variable "active_deployment_color" {
  description = "Currently active deployment color (blue or green)"
  type        = string
  default     = "blue"

  validation {
    condition     = contains(["blue", "green"], var.active_deployment_color)
    error_message = "Active deployment color must be either 'blue' or 'green'"
  }
}

variable "active_traffic_weight" {
  description = "Percentage of traffic to route to active deployment (0-100)"
  type        = number
  default     = 100

  validation {
    condition     = var.active_traffic_weight >= 0 && var.active_traffic_weight <= 100
    error_message = "Traffic weight must be between 0 and 100"
  }
}

# Weighted Routing Configuration
variable "enable_weighted_routing" {
  description = "Enable weighted target group routing for gradual traffic shift"
  type        = bool
  default     = true
}

variable "listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "priority" {
  description = "Priority for the listener rule"
  type        = number
  default     = 100
}

variable "blue_target_group_arn" {
  description = "ARN of the blue target group"
  type        = string
}

variable "green_target_group_arn" {
  description = "ARN of the green target group"
  type        = string
}

variable "enable_stickiness" {
  description = "Enable session stickiness during traffic shift"
  type        = bool
  default     = true
}

variable "stickiness_duration" {
  description = "Duration of session stickiness in seconds"
  type        = number
  default     = 3600
}

variable "host_header" {
  description = "Host header for listener rule condition"
  type        = string
  default     = null
}

variable "path_pattern" {
  description = "Path pattern for listener rule condition"
  type        = string
  default     = null
}

# CodeDeploy Configuration
variable "enable_codedeploy" {
  description = "Enable AWS CodeDeploy for blue-green deployments"
  type        = bool
  default     = true
}

variable "codedeploy_service_role_arn" {
  description = "IAM role ARN for CodeDeploy service"
  type        = string
  default     = ""
}

variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration name"
  type        = string
  default     = "CodeDeployDefault.AllAtOnce"
}

variable "terminate_blue_instances_action" {
  description = "Action to take on blue instances after successful deployment (TERMINATE or KEEP_ALIVE)"
  type        = string
  default     = "KEEP_ALIVE"

  validation {
    condition     = contains(["TERMINATE", "KEEP_ALIVE"], var.terminate_blue_instances_action)
    error_message = "Must be either TERMINATE or KEEP_ALIVE"
  }
}

variable "blue_termination_wait_time" {
  description = "Wait time in minutes before terminating blue instances"
  type        = number
  default     = 5
}

variable "deployment_ready_action" {
  description = "When to reroute traffic to new deployment (CONTINUE_DEPLOYMENT or STOP_DEPLOYMENT)"
  type        = string
  default     = "CONTINUE_DEPLOYMENT"

  validation {
    condition     = contains(["CONTINUE_DEPLOYMENT", "STOP_DEPLOYMENT"], var.deployment_ready_action)
    error_message = "Must be either CONTINUE_DEPLOYMENT or STOP_DEPLOYMENT"
  }
}

variable "deployment_ready_wait_time" {
  description = "Wait time in minutes before rerouting traffic (if STOP_DEPLOYMENT)"
  type        = number
  default     = 0
}

variable "test_listener_arn" {
  description = "ARN of test traffic listener (optional)"
  type        = string
  default     = null
}

variable "blue_target_group_name" {
  description = "Name of the blue target group"
  type        = string
}

variable "green_target_group_name" {
  description = "Name of the green target group"
  type        = string
}

variable "enable_alarm_rollback" {
  description = "Enable automatic rollback based on CloudWatch alarms"
  type        = bool
  default     = true
}

variable "rollback_alarm_names" {
  description = "List of CloudWatch alarm names that trigger rollback"
  type        = list(string)
  default     = []
}

variable "autoscaling_group_names" {
  description = "List of Auto Scaling Group names for the deployment"
  type        = list(string)
  default     = []
}

# Deployment Tracking
variable "enable_deployment_tracking" {
  description = "Enable SSM parameters to track deployment state"
  type        = bool
  default     = true
}

# Automated Traffic Shifting
variable "enable_automated_traffic_shift" {
  description = "Enable automated gradual traffic shifting via Lambda"
  type        = bool
  default     = false
}

variable "lambda_execution_role_arn" {
  description = "IAM role ARN for Lambda function execution"
  type        = string
  default     = ""
}

variable "traffic_shift_schedule" {
  description = "EventBridge schedule expression for traffic shifting (e.g., 'rate(5 minutes)')"
  type        = string
  default     = null
}

variable "traffic_shift_increment" {
  description = "Percentage increment for each traffic shift step"
  type        = number
  default     = 10

  validation {
    condition     = var.traffic_shift_increment > 0 && var.traffic_shift_increment <= 100
    error_message = "Traffic shift increment must be between 1 and 100"
  }
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
