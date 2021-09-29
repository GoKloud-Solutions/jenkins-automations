<h1>Setup ECS containers as Jenkins agents</h1>

Managing Jenkins is a tidious task. One need to decide what should be the configuration of the Jenkins, what kind of jobs we are running, how much load we are expecting on the Jenkins server and how to scale the Jenkins infrastructure. To ease this process, Jenkins provides distributed build architecture which can distribute the load between Jenkins controller and the agents. Once we decided to go ahead with Jenkins distributed architecture, the next step will be configuring Jenkins agents.

As a best practice, rather building a "standalone" jenkins it's good to have a scalable and distributed build architecture. Also, if we follow standalone architecture and executing jobs on the controller introduces a "security" issue: the "jenkins" user that Jenkins uses to run the jobs would have full permissions on all Jenkins resources on the controller. This means that, with a simple script, a malicious user can have direct access to private information whose integrity and privacy could be compromised.

<h2>What are Jenkins agents? </h2>
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


1. Create or Update IAM for Jenkins agent to run tasks on ECS.
2. Create or Update security group for agent.
3. Install Amazon ECS plugin.
4. Configure node/cloud.
5. Test with a job.
