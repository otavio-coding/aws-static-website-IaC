/*
  This file contains resources related to the TSL/SSL certificate.
*/


data "aws_acm_certificate" "issued" {
  domain = var.acm_domain_name
}
