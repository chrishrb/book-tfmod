# ****************************************************************************
#
# E X T E R N A L - Example service
#
# ****************************************************************************

resource "aws_sns_topic" "example" {
  name = "${var.service_prefix}-external-example-service"
}
