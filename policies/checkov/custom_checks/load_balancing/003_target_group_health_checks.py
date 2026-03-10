from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class TargetGroupHealthCheckEnabled(BaseResourceCheck):
    def __init__(self):
        name = "Ensure Target Group has health checks enabled"
        id = "CUSTOM_AWS_LB_003"
        supported_resources = ["aws_lb_target_group"]
        categories = [CheckCategories.LOAD_BALANCING]

        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        vpc_id = conf.get("vpc_id")
        health_check = conf.get("health_check")

        if not vpc_id or not health_check:
            return CheckResult.FAILED
        
        health_check = health_check[0]
        path = health_check.get("path")
        matcher = health_check.get("matcher")

        if not path or not matcher:
            self.details = "Health check must have a valid path and matcher."
            return CheckResult.FAILED



