---
title: Talk – Practical Lambda for Ops Types
date: 2017-03-18
tags:
  - Lambda
  - Serverless
  - AWS
---

At the beginning of this week I gave a talk to the [Serverless Hamburg Meetup Group](https://www.meetup.com/Serverless-Hamburg/) entitled [Practical Lambda for Ops Types](https://docs.google.com/presentation/d/1VCP4AQBKjSgC_sFSJr1EduxkNLHJy6ECuXOoxbOFurg/edit#slide=id.p). The talk describes making use of AWS events and Lambda to automate registration of newly launched proprietary security appliance instances with the vendor's registry. The creation of a mock registration service as an example of an application that uses AWS API Gateway, Lambda and DynamoDB also forms part of the talk.

The source code is linked to at the end of the slides but for the impatient [here it is](https://github.com/btisdall/serverless-hh-2017-03-13).

I would like to acknowledge two resources that were invaluable in enabling me to put the talk together on a tight schedule:

* [AWS CloudFormation and API Gateway](https://medium.com/@onclouds/aws-cloudformation-and-api-gateway-2de3ef858c0b#.gkj8ywob4)
* [Integrate SQS and Lambda: serverless architecture for asynchronous workloads](https://cloudonaut.io/integrate-sqs-and-lambda-serverless-architecture-for-asynchronous-workloads/)
