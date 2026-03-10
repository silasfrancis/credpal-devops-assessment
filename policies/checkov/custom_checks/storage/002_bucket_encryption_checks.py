from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck     

class BucketEncryptionCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure that S3 buckets have encryption enabled"
        id = "CUSTOM_AWS_S3_002"
        supported_resources = ['aws_s3_bucket_server_side_encryption_configuration']
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        rules = conf.get("rule")

        if not rules:
            self.details = "S3 bucket does not have a server-side encryption configuration."
            return CheckResult.FAILED

        rule = rules[0]

        if "apply_server_side_encryption_by_default" not in rule:
            self.details = (
                "S3 bucket encryption rule is missing "
                "'apply_server_side_encryption_by_default'."
            )
            return CheckResult.FAILED

        encryption_settings = rule.get("apply_server_side_encryption_by_default", [])

        if not encryption_settings:
            self.details = "S3 bucket encryption settings are empty."
            return CheckResult.FAILED

        sse_algorithm = encryption_settings[0].get("sse_algorithm")

        if not sse_algorithm or not sse_algorithm[0]:
            self.details = (
                "S3 bucket does not have a valid server-side encryption algorithm configured."
            )
            return CheckResult.FAILED

        return CheckResult.PASSED

        