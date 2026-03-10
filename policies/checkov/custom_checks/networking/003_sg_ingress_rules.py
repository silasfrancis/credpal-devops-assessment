from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class SGIngressRulesRestrictions(BaseResourceCheck):
    def __init__(self):
        name = "Ensure that Security Group Ingress rules are not wide open"
        id = "CUSTOM_AWS_SG_001"
        supported_resources = ['aws_vpc_security_group_ingress_rule']
        categories = [CheckCategories.NETWORKING]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        tags = conf.get("tags")
        from_port = conf.get("from_port")
        to_port = conf.get("to_port")
        cidr_ipv4 = conf.get("cidr_ipv4")
        referenced_security_group_id = conf.get("referenced_security_group_id")


        if not tags:
            return CheckResult.FAILED
        
        tags = tags[0]
        Resource = tags.get("Resource")

        if not Resource or not Resource[0]:
            return CheckResult.FAILED
        
        if Resource[0] == "ALB":
            if cidr_ipv4 and cidr_ipv4[0] == "0.0.0.0/0":
                if from_port and from_port[0] not in [80, 443]:
                    return CheckResult.FAILED
                if to_port and to_port[0] not in [80, 443]:
                    return CheckResult.FAILED
        
        if Resource[0] == "EC2":
            if (cidr_ipv4 and cidr_ipv4[0] == "0.0.0.0/0"):
                return CheckResult.FAILED
            if not referenced_security_group_id:
                return CheckResult.FAILED

        if Resource[0] == "RDS":
            if (cidr_ipv4 and cidr_ipv4[0] == "0.0.0.0/0"):
                return CheckResult.FAILED
            if not referenced_security_group_id:
                return CheckResult.FAILED
        return CheckResult.PASSED