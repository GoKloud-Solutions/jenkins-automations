# Run your Cloudformation template

You can directly download the cloudformation template and create a stack in Cloudformation AWS console. Otherwise, you can use AWS CLI command to create the stack.

Creating resources with AWL CLI.

First, update the parameters.json file with actual parameter values from your environment. Once done, run the following command.

Make sure you have required permission to run these commands and create the resources.

```
 aws cloudformation create-stack \
--stack-name my-ecs-stack \
--template-body file://jenkins-ecs-agent.json \
--parameter-overrides file://parameters.json
```
