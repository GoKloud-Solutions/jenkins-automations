<h1>Setup ECS containers as Jenkins agents</h1>

Jenkins is built for distributed build environments. It enables us to utilize distinct settings for each construction project, balancing the burden among several agents working on multiple jobs at the same time. 

A Jenkins controller(Master) is included with the standard Jenkins installation, and in this setup, the controller manages all of your build system's tasks.The Jenkins controller administers the Jenkins agents and orchestrates their work, including scheduling jobs on agents and monitoring agents. Agents may be connected to the Jenkins controller using either local or cloud computers.

**Jenkins Agents:**

An agent is a Java executable that runs on a remote machine. Following are the characteristics of Jenkins agents:
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
