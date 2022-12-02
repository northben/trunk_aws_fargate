README
===

This repo contains a terraform template that will deploy Splunk Enterprise in a container with [Trunk](https://github.com/northben/trunk) and [TA-trello-webhook](https://github.com/northben/ta-trello-webhook) preconfigured to index Trello Webhooks in a new VPC using AWS Fargate. 

Prerequisites
---
* The Trunk image using your DNS name and Trello key, and uploaded to AWS ECR. Use the packer template in the [trunk_container](https://github.com/northben/trunk_container) repo.

* [install terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

* A Route53 zone in AWS with working public DNS resolution in order for Trello webhook events to be indexed by the Fargate container. This template also creates a DNS alias in this zone so that you can access the Splunk Web interface.

Deployment steps
---
1. Clone this repo
1. Rename __variables_default_tf__ to __variables.tf__ and provide values for the empty variables
1. Run `terraform apply -auto-approve`
1. Access the Splunk instance with Trunk installed at the __trunk_dns_name__ specified in `variables.tf`.

Additional info
---

The `terraform apply` command is provided for VS Code. Use keyboard shortcut: `⌘ ⇧ B` and select __terraform apply__.
