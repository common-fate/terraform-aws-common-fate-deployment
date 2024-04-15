# alerts

Alerting module for a Common Fate deployment.

Common Fate has several SNS topics used as alert channels:

| Topic         | Emits alerts for                |
| ------------- | ------------------------------- |
| `deployments` | Common Fate service deployments |
| `jobs`        | Common Fate background jobs     |

When setting up alerts you can specify a level for each topic - either `errors` or `all`. By default, all topics are set to the `error` level.

In production we recommend using the `errors` level only to prevent noise. You can use the `all` level to verify that your subscription to the SNS topic is working as expected.

Here's an example of how to configure the alert topics in Terraform:

```hcl
module "common-fate" {
    alerts = {
        deployments = "all"
        jobs        = "error"
    }
}
```
