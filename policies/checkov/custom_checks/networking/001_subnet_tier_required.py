from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class SubnetTierTagRequired(BaseResourceCheck):
    def __init__(self):
        name = "Ensure that AWS Subnets have a 'Tier' tag"
        id = "CUSTOM_AWS_VPC_001"
        supported_resources = ['aws_subnet']
        categories = [CheckCategories.NETWORKING]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)
    
    def scan_resource_conf(self, conf):
        tags = conf.get("tags")

        if not tags:
            return CheckResult.FAILED
        
        tags = tags[0]
        tier = tags.get("Tier")

        if not tier or not tier[0]:
            return CheckResult.FAILED
        return CheckResult.PASSED

