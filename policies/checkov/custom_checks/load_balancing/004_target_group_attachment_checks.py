from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class TargetGroupAttachmentCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure Target Group has at least one attachment"
        id = "CUSTOM_AWS_LB_004"
        supported_resources = ["aws_lb_target_group_attachment"]
        categories = [CheckCategories.LOAD_BALANCING]

        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        target_group_arn = conf.get("target_group_arn")
        target_id = conf.get("target_id")

        if not target_group_arn or not target_id:
            self.details = "Target Group Attachment must specify both the load balancer arn and id of the target instance"
            return CheckResult.FAILED

        return CheckResult.PASSED