# Launch Template Configuration
variable "name" {
  description = "Name of the Auto Scaling Group and Launch Template"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Key name for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to instances"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs to attach to instances"
  type        = list(string)
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for instances"
  type        = bool
  default     = true
}

# User Data Configuration (Flexible)
variable "user_data" {
  description = "User data script as a string (base64 encoding will be handled automatically)"
  type        = string
  default     = null
}

variable "user_data_template_file" {
  description = "Path to user data template file (will use templatefile function)"
  type        = string
  default     = null
}

variable "user_data_template_vars" {
  description = "Variables to pass to the user data template file"
  type        = map(any)
  default     = null
}

# Tag Specifications
variable "tag_specifications" {
  description = "List of tag specifications for launch template resources"
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the launch template"
  type        = map(string)
  default     = {}
}

# Auto Scaling Group Configuration
variable "subnet_ids" {
  description = "List of subnet IDs where instances will be launched"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to attach to the ASG"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Type of health check (EC2 or ELB)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
}

variable "default_cooldown" {
  description = "Time (in seconds) between a scaling activity and the next"
  type        = number
  default     = 300
}

variable "launch_template_version" {
  description = "Launch template version to use (e.g., $Latest, $Default, or version number)"
  type        = string
  default     = "$Latest"
}

variable "enabled_metrics" {
  description = "List of metrics to enable for the ASG"
  type        = list(string)
  default     = ["GroupInServiceInstances"]
}

variable "asg_tags" {
  description = "Map of tags to apply to the ASG and propagate to instances"
  type = map(object({
    value               = string
    propagate_at_launch = bool
  }))
  default = {}
}

variable "ignore_changes" {
  description = "List of attributes to ignore changes on (e.g., [desired_capacity])"
  type        = list(string)
  default     = ["desired_capacity"]
}

variable "timeout_delete" {
  description = "Timeout for ASG deletion"
  type        = string
  default     = "15m"
}

# Target Tracking Scaling Policy
variable "enable_target_tracking_scaling" {
  description = "Enable target tracking scaling policy"
  type        = bool
  default     = false
}

variable "target_tracking_configuration" {
  description = "Configuration for target tracking scaling policy"
  type = object({
    predefined_metric_type = optional(string)
    customized_metric_specification = optional(object({
      namespace        = string
      metric_name      = string
      statistic        = string
      unit             = optional(string)
      metric_dimensions = optional(list(object({
        name  = string
        value = string
      })))
    }))
    target_value = number
  })
  default = null
}

# Scheduled Scaling
variable "autoscaling_schedules" {
  description = "Map of scheduled scaling actions"
  type = map(object({
    min_size         = optional(number)
    max_size         = optional(number)
    desired_capacity = optional(number)
    recurrence       = optional(string)
    start_time       = optional(string)
    end_time         = optional(string)
  }))
  default = {}
}

