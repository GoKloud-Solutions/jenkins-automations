<h1>Serverless Jenkins agents on AWS ECS Fargate</h1>

This is the walkthrough to setup Jenkins agents on AWS ECS Fargate. This repository contains all the supporting scripts to launch ECS cluster and step by step instruction to configure AWS ECS containers as Jenkins agents.

Jenkins agents are basically a machine which offloads the projects from its controller. The agents can be configured for various purposes like build and deploy a designated project, build only application jobs, run nightly jobs etc. Using ECS as jenkins agents will ease the dependancy of the application platform, infrastructure resources.

<h2>Pre-requisites</h2>

* An AWS account with required permissions to launch the resources.

* A Jenkins server controller or master to which ECS agents will be scheduled (Jenkins server version 2.176.1 or above).
* Terraform installed if terraform module is used to create the resources.
* AWS CLI installed if Cloudformation solution is used (Cloudformation console can be used to launch the stack).

<h2>How it works?</h2>

Before we start with how it works, this setup guide will help with the following.

* Create ECS cluster to host jenkins agents.
  * Jenkins agents can be launched as ```FARGATE``` and ```FARGATE_SPOT``` depending on ones requirement.
    * One utilizing the standard ```FARGATE``` capacity provider, which is to be used by the Jenkins controller and high priority agents.
    * One utilizing the ```FARGATE_SPOT``` capacity provider, which is to be used by Jenkins agents which handle lower priority jobs.

  * Security group which will allow Jenkins controller traffic to agent containers.

* IAM role for Jenkins controller to schedule ECS tasks on the cluster.
* Installation and configuration of Amazon ECS plugin.
* Configuring cloud as Jenkins node.
* Test run with a sample Jenkins pipeline job.

  ![Sample infrastructure diagram](https://user-images.githubusercontent.com/91467852/135419889-d5fbbeaa-fc75-4464-87a4-e080b5f4dbeb.png)
  
  
<h2>Setup deployment</h2>
<h3>ECS cluster setup</h3>
We need to create an ECS cluster to launch the agent containers. One can choose Terraform or Cloudformation solution to provision the underlying infrastructure.

**Terraform:** <link here>

**Cloudformation:** [Cloudformation Templates](https://github.com/GoKloud-Solutions/jenkins-automations/tree/feature-setup/jenkins-ecs-node/Cloudformation)

<h3>Permission and access</h3>
**IAM Permissions**
Create or update the IAM role attached to Jenkins controller to access/schedule the container tasks in ECS cluster. The following policy is expected to be attached to the Jenkins master.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecs:RegisterTaskDefinition",
                "ecs:ListClusters",
                "ecs:DescribeContainerInstances",
                "ecs:ListTaskDefinitions",
                "ecs:DescribeTaskDefinition",
                "ecs:DeregisterTaskDefinition"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ecs:ListContainerInstances",
                "ecs:DescribeClusters"
            ],
            "Resource": [
                "arn:aws:ecs:us-east-2:1234512345:cluster/<clusterName>"
            ],
            "Effect": "Allow"
        },
        {
            "Condition": {
                "ArnEquals": {
                    "ecs:cluster": [
                        "arn:aws:ecs:us-east-2:1234512345:cluster/<clusterName>"
                    ]
                }
            },
            "Action": [
                "ecs:RunTask"
            ],
            "Resource": "arn:aws:ecs:us-east-2:1234512345:task-definition/*",
            "Effect": "Allow"
        },
        {
            "Condition": {
                "ArnEquals": {
                    "ecs:cluster": [
                        "arn:aws:ecs:us-east-2:1234512345:cluster/<clusterName>"
                    ]
                }
            },
            "Action": [
                "ecs:StopTask"
            ],
            "Resource": "arn:aws:ecs:*:*:task/*",
            "Effect": "Allow"
        },
        {
            "Condition": {
                "ArnEquals": {
                    "ecs:cluster": [
                        "arn:aws:ecs:us-east-2:1234512345:cluster/<clusterName>"
                    ]
                }
            },
            "Action": [
                "ecs:DescribeTasks"
            ],
            "Resource": "arn:aws:ecs:*:*:task/*",
            "Effect": "Allow"
        },
                {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Resource": "*"
        }
    ]
}

```

Otherwise, the above IAM role can be created using CLoudformation or Terraform.

**Terraform:** 

**Cloudformation:** [IAM role for controller](https://github.com/GoKloud-Solutions/jenkins-automations/blob/feature-setup/jenkins-ecs-node/Cloudformation/iam_role_for_controller.json)

**Security Group**
You must open TCP port 5000 as inbound in the security group which will be attached to container. The will enable connection between the Jenkins master and the ECS cluster container instances.

The ECS cluster IaaC templates can create the security group with the above permissions and can use it create the security group. However, this is how the Security group permissions should look like.

PROTOCOL | PORT RANGE | SOURCE
----------|------------|-------
TCP | 5000 | Jenkins-controller-sg
TCP | 5000 | Jenkins-alb-sg (if any)

<h3>Install ECS plugin</h3>
Install [amazon-ecs-plugin](https://plugins.jenkins.io/amazon-ecs/)to enable AWS ECS as cloud node. This will enable us to add ECS containers as Jenkins agents.

<h3>Jenkins configurations</h3>

**Enable TCP port for inbound agents**

TCP port for inbound agents. Fix the TCP listen port for JNLP agents of the Jenkins master (e.g. 5000) navigating in the "Manage Jenkins / Configure Global Security" screen Allow TCP traffic from the ECS cluster container instances to the Jenkins master on the listen port for JNLP agents.
<img width="1092" alt="Screenshot 2021-09-29 at 7 22 40 PM" src="https://user-images.githubusercontent.com/91467852/135423608-2436a759-b8fe-4471-8362-b29c1e30db20.png">

Jenkins URL must be reachanble from agent container. Goto Manage Jenkins -> Configure System -> Jenkins Location -> Jenkins URL
<img width="1095" alt="Screenshot 2021-09-29 at 7 35 39 PM" src="https://user-images.githubusercontent.com/91467852/135423687-c4f25c53-2ea9-4325-9dc4-521c23d51af0.png">

If the global Jenkins URL configuration does not fit your needs (e.g. if your ECS agents must reach Jenkins through some kind of tunnel) you can also override the Jenkins URL in the Advanced Configuration of the ECS cloud.

<h3>Configure AWS ECS cloud in Jenkins</h3>

To configure Clouds in Jenkins, we can do it from the Jenkins UI or can use script approach using configuration-as-code.

```The Jenkins Amazon EC2 Container Service plugin will use this ECS cluster and will create automatically the required Task Definition.```

#### From Jenkins Console

**Step 1 :**

Select Manage Nodes and Clouds under Manage Jenkins.

<img width="1099" alt="Screenshot 2021-09-29 at 7 39 20 PM" src="https://user-images.githubusercontent.com/91467852/135424755-f57f209e-4a11-4532-b241-0a18c23a0b72.png">

**Step 2 :**

Select Configure Clouds.

<img width="1438" alt="Screenshot 2021-09-29 at 7 40 37 PM" src="https://user-images.githubusercontent.com/91467852/135424878-53bef2b7-47bd-4636-b4ce-3c1cbd353e33.png">

**Step 3 :**

Add a new cloud and select Amazon EC2 Container Service Cloud.

<img width="1103" alt="Screenshot 2021-09-29 at 7 44 03 PM" src="https://user-images.githubusercontent.com/91467852/135424944-07b0119e-6f0c-4b4a-b19a-8e80307e3cde.png">


**Step 4 :**

After ```Step 3```, thie will enable options to enter the following values.

OPTION | VALUE
----------|------------
Name | Name for your jenkins cloud agent
Amazon ECS Credentials | IAM Access credentials to create Task Definitions and Tasks on the desired ECS cluster
ECS Cluster | ECS cluster where the tasks will be created. ECS Template: Template for ECS task definition

<img width="1095" alt="Screenshot 2021-09-29 at 7 45 59 PM" src="https://user-images.githubusercontent.com/91467852/135425865-2827c89e-bfd6-41a3-9eca-d58ded50e91e.png">

**Enable ECS Slave template**

Click on "Add", this will open options to define your template.

OPTION | VALUE
----------|------------
Template name | Name for the task definition in ECS
Label | Lable name for the agent which can be referred in Jenkins jobs
Docker image | Docker image to launch jenkins agents
Filesystem root | working directory used by Jenkins (e.g. /home/jenkins/)
Memory | number of MiB of memory reserved for the container
CPU | The number of cpu units to reserve for the container
Override entrypoint | overwritten Docker image entrypoint
JVM arguments | additional arguments for the JVM, such as -XX:MaxPermSize or GC options

<img width="1148" alt="135289085-b78723e6-3bef-48e7-8782-1bcfda10f1ef" src="https://user-images.githubusercontent.com/91467852/135427326-71b933f1-edb6-47ba-9dcb-2c52e8b57b1e.png">

```For docker image to act as a Jenkins JNLP agent, can use this one. [jenkins/inbound-agent](https://hub.docker.com/r/jenkins/inbound-agent/)```
We can also copy this docker image to ECR and use to lauch ECS agent containers or buid image of our own.


#### Using configuration-as-code

Install [configuration-as-code](https://plugins.jenkins.io/configuration-as-code/) plugin. This will enable the configuration to be written in YAML and it will reduce the manual effort of managing jenkins. The applicability of this plugin is way beyond just configuring the node but in this article we'll be using it to configure a cloud node.

Once the CASC (configuration-as-code) plugin is installed, use this [jenkins.yml](https://github.com/GoKloud-Solutions/jenkins-automations/blob/feature-setup/jenkins-ecs-node/configuraition-as-code/jenkins.yml) YAML file to configure the cloud. This option will enable additional options while configuring. For example, you can select ECS task launch type, Securtiy groups, subnets etc.

Goto Manage Jenkins -> configuration-as-code -> Paste the path of jekins.yml file. 
  - This can be URL where the YAML file is stored (must be public or Jenkins controller must have access to this file)
  - Absolute path from the server where the YAML file is located (Jenkins controller must have read permission to the file). 
 
In this example, I'll be using raw URL of jenkins.yml file located here. [jenkins.yml](https://github.com/GoKloud-Solutions/jenkins-automations/blob/feature-setup/jenkins-ecs-node/configuraition-as-code/jenkins.yml)

 <img width="1171" alt="Screenshot 2021-09-30 at 3 11 14 PM" src="https://user-images.githubusercontent.com/91467852/135428597-eb8148c2-77c4-4e18-be04-153c5deedc81.png">

Once path is added, wait till it says ```The configuration can be applied```. If there are any errors in the yaml file then it'll show what is the error and that needs to be resolved.

Next, click on apply configuration.

Now, if the configuration is applied successfully, you can see the cloud added under Configure Clouds section.


<h3>Test with Jenkins job</h3>

The ECS agents can be used for any job and any type of job (Freestyle job, Maven job, Workflow job...), you just have to restrict the execution of the jobs on one of the labels used in the ECS Agent Template configuration. You can either restrict the job to run on a specific label only via the UI or directly in the pipeline.

#### Example 1 : using declarative pipeline
```
pipeline {
  agent none

  stages {
       stage('PublishAndTests') {
          environment {
              STAGE='prod'
          }
          agent {
            label 'build-python36'
          }
      }
      steps {
        sh 'java -version'
      }
    }
  }

```

#### Example 2 : Declatative pipeline with "inheritFrom"

"inheritFrom" You can also reuse pre-configured templates and override certain settings using inheritFrom to reference the Label field of the template that you want to use as preconfigured. Only one label is expected to be specified.

When using inheritFrom, the label will not copied. Instead, a new label will be generated based on the following schema {job-name}-{job-run-number}-{5-random-chars} e.g. "pylint-543-b4f42". This guarantees that there will not be conflicts with the parent template or other runs of the same job, as well as making it easier to identify the labels in Jenkins.

```
pipeline {
    agent {
       ecs {
           inheritFrom 'my-ecs-agent'
       }
   }
   stages {
     stage('Test') {
         steps {
             script {
                 sh "echo This is a test job!!"
             }
             sh 'sleep 120'
             sh 'echo sleep is done'
         }
     }
   }
}
```
### Results

**Running Jenkins job**
<img width="1440" alt="Screenshot 2021-09-29 at 8 47 09 PM" src="https://user-images.githubusercontent.com/91467852/135430409-bb958b4e-0533-479c-87d5-28c2484499f6.png">

**Jenkins agent created**
<img width="1434" alt="Screenshot 2021-09-29 at 8 46 48 PM" src="https://user-images.githubusercontent.com/91467852/135430603-cd6d2c32-2c5a-43b2-bc9e-173bff7fcffe.png">

**ECS task running**
<img width="1181" alt="Screenshot 2021-09-29 at 8 46 35 PM" src="https://user-images.githubusercontent.com/91467852/135430663-882882da-0c85-4fa5-a86b-47bf9674f59d.png">

<img width="1160" alt="Screenshot 2021-09-29 at 8 48 39 PM" src="https://user-images.githubusercontent.com/91467852/135430722-b9a47d9a-8b68-49e9-992d-2f53e71893e0.png">


