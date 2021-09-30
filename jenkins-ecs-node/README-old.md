<h1>Setup ECS containers as Jenkins agents</h1>

Managing Jenkins is a tidious task. One need to decide what should be the configuration of the Jenkins, what kind of jobs we are running, how much load we are expecting on the Jenkins server and how to scale the Jenkins infrastructure. To ease this process, Jenkins provides distributed build architecture which can distribute the load between Jenkins controller and the agents. Once we decided to go ahead with Jenkins distributed architecture, the next step will be configuring Jenkins agents.

As a best practice, rather building a "standalone" jenkins it's good to have a scalable and distributed build architecture. Also, if we follow standalone architecture and executing jobs on the controller introduces a "security" issue: the "jenkins" user that Jenkins uses to run the jobs would have full permissions on all Jenkins resources on the controller. This means that, with a simple script, a malicious user can have direct access to private information whose integrity and privacy could be compromised.

<h2>What is a Jenkins agent? </h2>
An agent is a machine set up to offload projects from the controller. The method with which builds are scheduled depends on the configuration given to each project. For example, some projects may be configured to "restrict where this project is run" which ties the project to a specific agent or set of labeled agents. Other projects which omit this configuration will select an agent from the available pool in Jenkins.

Following are the characteristics of Jenkins agents:
* It hears requests from the Jenkins Master instance.
* Slaves can run on a variety of operating systems.
* The job of a Slave is to do as they are told to, which involves executing build jobs dispatched by the Master.
* You can configure a project to always run on a particular Slave machine or a particular type of Slave machine, or simply let Jenkins pick the next available Slave.

**There are multiple options to run the Jenkins agent.**

* EC2 instance as agent
* Docker container as agent
* ECS containers as agent
* Kubernetes pods as agents

In this article, we'll be using AWS ECS container as Jenkins agents.

To achieve this we'll be needing the following :
* An AWS account with
  * ECS cluster where Jenkins agents can be hosted.
  * IAM permissions for ECS tasks.
  * ECR repository where Jenkins agent image can be stored.
  * Security group with required permissions.
* Running Jenkins server (controller).
  * Amazon ECS plugin installed on Jenkins controller.
  * Credentials to access AWS resources from Jenkins or IAM assume roles.

<h2>How to start? </h2>

**Assuming that we already have**
* A Jenkins server up and running.

1. Amazon ECS cluster

As a pre-requisite, you must have created an Amazon ECS cluster with associated ECS instances. These instances can be statically associated with the ECS cluster or can be dynamically created with Amazon Auto Scaling.

The Jenkins Amazon EC2 Container Service plugin will use this ECS cluster and will create automatically the required Task Definition.

**Create ECS Cluster**
Cloudformation : <link>
Terraform : <link>

2. Create or Update IAM for Jenkins agent to run tasks on ECS.

Create an IAM policy like below to attach to task.

Cloudformation template to create the role : <link>
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


3. Create or Update security group for agent.
* You must open TCP port 5000 as inbound in the security group which will be attached to container. The will enable connection between the Jenkins master and the ECS cluster container instances.

* TCP port for inbound agents. Fix the TCP listen port for JNLP agents of the Jenkins master (e.g. 5000) navigating in the "Manage Jenkins / Configure Global Security" screen Allow TCP traffic from the ECS cluster container instances to the Jenkins master on the listen port for JNLP agents.

    <img width="1092" alt="Screenshot 2021-09-29 at 7 22 40 PM" src="https://user-images.githubusercontent.com/91467852/135282371-6021ea3f-46ab-4d5e-8efc-2620c98ba115.png">


5. Install Amazon ECS plugin.

Install [amazon-ecs](https://plugins.jenkins.io/amazon-ecs/) plugin to enable AWS ECS as cloud node. This will enable us to add ECS containers as Jenkins agents.

7. Configure Jenkins and node/cloud.

**Jenkins configuration**

1. Jenkins URL must be reachanble from agent container.
   Goto Manage Jenkins -> Configure System -> Jenkins Location -> Jenkins URL
   
   <img width="1095" alt="Screenshot 2021-09-29 at 7 35 39 PM" src="https://user-images.githubusercontent.com/91467852/135284780-8acf2482-979a-4db7-b96f-d5d94a2b7878.png">
   
 2. If the global Jenkins URL configuration does not fit your needs (e.g. if your ECS agents must reach Jenkins through some kind of tunnel) you can also override the Jenkins URL in the Advanced Configuration of the ECS cloud.  
   
**Amazon ECS Cloud**
1. Select Manage Nodes and Clouds under Manage Jenkins.
   <img width="1099" alt="Screenshot 2021-09-29 at 7 39 20 PM" src="https://user-images.githubusercontent.com/91467852/135285521-bb8c27d6-876d-4410-a34f-298f4f783901.png">

2. Selct Configure Clouds and 
   <img width="1438" alt="Screenshot 2021-09-29 at 7 40 37 PM" src="https://user-images.githubusercontent.com/91467852/135285762-231118aa-815c-41e6-8896-5091a8f0b042.png">

3. Add a new cloud and select Amazon EC2 Container Service Cloud.

   <img width="1103" alt="Screenshot 2021-09-29 at 7 44 03 PM" src="https://user-images.githubusercontent.com/91467852/135286428-d97052d0-64c4-4747-8468-349d27d6f7c2.png">

4. This will enable options to enter the following values.
   Name: Name for your jenkins cloud agent.
   Amazon ECS Credentials: IAM Access credentials to create Task Definitions and Tasks on the desired ECS cluster.
   ECS Cluster: ECS cluster where the tasks will be created.
   ECS Template: Template for ECS task definition.
   <img width="1095" alt="Screenshot 2021-09-29 at 7 45 59 PM" src="https://user-images.githubusercontent.com/91467852/135287228-1381924b-fc14-47c8-bd25-fec15ae97d5d.png">

   **Create ECS slave template**
   Click on "Add", this will open options to define your template.
   
   Template name : for the task definition in ECS.
   
   Label: Lable name for the agent which can be referred in Jenkins jobs.
   
   Docker image: Docker image to launch jenkins agents.
   
   Filesystem root: working directory used by Jenkins (e.g. /home/jenkins/). 
   
   Memory: number of MiB of memory reserved for the container.
   
   CPU : The number of cpu units to reserve for the container. 
   
   Advanced Configuration
   
     Override entrypoint: overwritten Docker image entrypoint.
     
     JVM arguments: additional arguments for the JVM, such as -XX:MaxPermSize or GC options.
     <img width="1148" alt="Screenshot 2021-09-29 at 7 58 30 PM" src="https://user-images.githubusercontent.com/91467852/135289085-b78723e6-3bef-48e7-8782-1bcfda10f1ef.png">


Alternative way to add a cloud node : 

Install [configuration-as-code]() plugin. This will enable the configuration to be written in YAML and it will reduce the manual effort of managing jenkins. The applicability of this plugin is way beyond just configuring the node but in this article we'll be using it to configure a cloud node.

Once the CASC (configuration-as-code) plugin is installed, use this <> YAML file to configure the cloud. This option will enable additional options while configuring. For example, you can select ECS task launch type, Securtiy groups, subnets etc.

Goto Manage Jenkins -> configuration-as-code -> Paste the path of jekins.yaml file. 
    This can be URL or absolute path from the server. I have copied jenkins.yaml file to my Jenkins controller to the location in the image.

   <img width="945" alt="Screenshot 2021-09-29 at 8 41 25 PM" src="https://user-images.githubusercontent.com/91467852/135297473-77a61334-113e-447c-b60f-a3edbfae808f.png">


Once path is added, wait till it says "The configuration can be applied". If there are any errors in the yaml file then it'll show what is the error and that needs to be resolved.

Next, click on apply configuration.

Now, if the configuration is applied successfully, you can see the cloud added under Configure Clouds section.

<img width="1439" alt="Screenshot 2021-09-29 at 8 42 44 PM" src="https://user-images.githubusercontent.com/91467852/135297743-5e48927c-bf95-4ceb-83b5-103ff6e636e7.png">


9. Test with a job.
 Congratulations, now you have configured the cloud. Now the time is to test it with a Jenkins job. I have created a pipeline job which will create a Jenkins agennt container in ECS.

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
 * Jenkins job running
    <img width="1440" alt="Screenshot 2021-09-29 at 8 47 09 PM" src="https://user-images.githubusercontent.com/91467852/135298800-7794f636-d38b-460f-af2a-b87dc669607f.png">
 
 * Jenkins agent created
   <img width="1434" alt="Screenshot 2021-09-29 at 8 46 48 PM" src="https://user-images.githubusercontent.com/91467852/135298862-6c8e925f-9b4d-4351-80a7-6479a6a7e1a4.png">


 * ECS task running
 
 <img width="1181" alt="Screenshot 2021-09-29 at 8 46 35 PM" src="https://user-images.githubusercontent.com/91467852/135298903-6f583923-23fe-4ee0-b3b9-96fdb0f82b24.png">

 <img width="1160" alt="Screenshot 2021-09-29 at 8 48 39 PM" src="https://user-images.githubusercontent.com/91467852/135298943-4e91a4d4-f731-4240-8876-424749da9481.png">
