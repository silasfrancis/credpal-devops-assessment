from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class InternetAndNatGatewaySanityCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure Internet and NAT Gateways are correctly configured"
        id = "CUSTOM_AWS_NW_004"
        supported_resources = ["aws_internet_gateway", "aws_nat_gateway"]
        categories = [CheckCategories.NETWORKING]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)  

    def scan_resource_conf(self, conf):
        if self.entity_type == "aws_internet_gateway":
            if not conf.get("vpc_id"):
                self.details = (
                    "Internet Gateway is not attached to any VPC. "
                    "All IGWs must be associated with a VPC."
                )
                return CheckResult.FAILED

        if self.entity_type == "aws_nat_gateway":
            if not conf.get("allocation_id"):
                self.details = (
                    "NAT Gateway does not have an Elastic IP (allocation_id). "
                    "NAT Gateways must use an EIP for outbound internet access."
                )
                return CheckResult.FAILED

            if not conf.get("subnet_id"):
                self.details = (
                    "NAT Gateway is not associated with a subnet. "
                    "NAT Gateways must be placed in a public subnet."
                    )
                return CheckResult.FAILED

        return CheckResult.PASSED
