from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class ALBHTTPRedirectCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure ALB HTTP listener redirects traffic to HTTPS"
        id = "CUSTOM_AWS_ALB_001"
        supported_resources = ["aws_lb_listener"]
        categories = [CheckCategories.LOAD_BALANCING]

        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        protocol = conf.get("protocol")
        port = conf.get("port")
        default_action = conf.get("default_action")

        if not protocol or not port:
            return CheckResult.FAILED

        if protocol[0] == "HTTP" and port[0] == 80:
            if not default_action:
                self.details = "HTTP listener must redirect traffic to HTTPS."
                return CheckResult.FAILED

            action = default_action[0]

            if action.get("type") != "redirect":
                self.details = "HTTP listener on port 80 must use a redirect action."
                return CheckResult.FAILED

            redirect = action.get("redirect", {})

            if (
                redirect.get("protocol") != "HTTPS"
                or redirect.get("port") != "443"
                or redirect.get("status_code") not in ["HTTP_301", "HTTP_302"]
            ):
                self.details = (
                    "HTTP listener redirect must point to HTTPS on port 443 "
                    "using status code HTTP_301 or HTTP_302."
                )
                return CheckResult.FAILED

        return CheckResult.PASSED
