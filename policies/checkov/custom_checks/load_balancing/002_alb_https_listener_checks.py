from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class ALBHTTPSListenerCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure ALB HTTPS listener uses TLS with certificate and SSL policy"
        id = "CUSTOM_AWS_ALB_002"
        supported_resources = ["aws_lb_listener"]
        categories = [CheckCategories.LOAD_BALANCING]

        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        protocol = conf.get("protocol")
        port = conf.get("port")

        if not protocol or not port:
            return CheckResult.FAILED

        if protocol[0] == "HTTPS" and port[0] == 443:
            if not conf.get("certificate_arn"):
                self.details = "HTTPS listener on port 443 must define certificate_arn."
                return CheckResult.FAILED

            if not conf.get("ssl_policy"):
                self.details = "HTTPS listener on port 443 must define an ssl_policy."
                return CheckResult.FAILED

        return CheckResult.PASSED
