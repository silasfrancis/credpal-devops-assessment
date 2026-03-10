from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class BucketVersioningCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure that S3 buckets have versioning enabled"
        id = "CUSTOM_AWS_S3_001"
        supported_resources = ['aws_s3_bucket_versioning']
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        versioning = conf.get("versioning_configuration")

        if not versioning:
            self.details = "S3 bucket does not have versioning configuration defined."
            return CheckResult.FAILED

        status = versioning[0].get("status")

        if not status or status[0] != "Enabled":
            self.details = "S3 bucket versioning is not enabled."
            return CheckResult.FAILED

        return CheckResult.PASSED