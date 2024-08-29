# Terraform-EKS-GitHub-Actions

Automation is at the heart of modern software development, and tools like GitHub Actions, AWS EKS, and Terraform are transforming how developers manage and deploy applications. GitHub Actions enables seamless CI/CD pipelines, automating everything from code integration to deployment. When combined with AWS EKS, developers can efficiently manage Kubernetes clusters, ensuring scalable and resilient applications. Terraform adds another layer by automating infrastructure as code, making the entire deployment process smoother and more reliable. In this repository, I will demonstrate how these technologies work together to streamline development and deployment workflows.

![intro](https://github.com/user-attachments/assets/6cb57f8f-ae58-4075-93f9-01ce9b7f7401)


## Prerequisites

1. **AWS Account:** Sign up at [aws.amazon.com](https://aws.amazon.com/).
2. **DockerHub Account:** For deploying a containerized application, register for [DockerHub](https://hub.docker.com/).
3. **Slack Account:** To get pipeline feedback in Slack channel. Sign up at [slack.com](https://slack.com/).


## Steps to deploy Application in EKS

### Step 1: Steup EC2 Instance

1. #### Create EC2 Instance

    To launch an AWS EC2 instance with Ubuntu latest (24.04) using the AWS Management Console, sign in to your AWS account, access the EC2 dashboard, and click “Launch Instances.” In “Step 1,” select “Ubuntu 24.04” as the AMI, and in “Step 2,” choose “t3.medium” as the instance type. Configure the instance details, storage (20 GB), tags , and security group ( make sure to create inbound rules to allow tcp traffic on port 22, 80, 443, 9000, 3000 [optional] ) settings according to your requirements. Review the settings, create or select a key pair for secure access, and launch the instance. Once launched, you can connect to it via SSH using the associated key pair or through management console as well.

   ![ec2-instance](https://github.com/user-attachments/assets/2ba64114-e17d-497e-8933-5c18a5a9272a)


3. #### Create IAM Role

    To create a new role for manage AWS resource through EC2 Instance in AWS, start by navigating to the AWS Console and typing “IAM” to access the Identity and Access Management service. Click on “Roles,” then select “Create role.” Choose “AWS service” as the trusted entity and select “EC2” from the available services. Proceed to the next step and use the “Search” field to add the necessary permissions policies, such as "Administrator Access" or "EC2 Full Access", "AmazonS3FullAccess" and "EKS Full Access". After adding these permissions, click "Next." In the “Role name” field, enter “EC2 Instance Role” and complete the process by clicking “Create role”.

   ![ec2-role-1](https://github.com/user-attachments/assets/c4221c37-fef4-4388-9fc0-e30314f771b3)
   
   ![ec2-role-2](https://github.com/user-attachments/assets/10e24038-b0a4-4362-9194-f32726c53566)
   
   ![ec2-role-3](https://github.com/user-attachments/assets/6c0e9cd2-ccc6-456e-9049-9c540d22171b)


2. #### Attach IAM Role

    To assign the newly created IAM role to an EC2 instance, start by navigating to the EC2 dashboard in the AWS Console. Locate the specific instance where you want to add the role, then select the instance and choose "Actions." From the dropdown menu, go to "Security" and click on "Modify IAM role." In the next window, select the newly created role from the list and click on "Update IAM role" to apply the changes.

   ![attach-role-1](https://github.com/user-attachments/assets/ee567f65-4bfe-4c42-a18b-ae673a651c8c)

   ![attach-role-2](https://github.com/user-attachments/assets/a5d214e3-9ef3-4a78-9155-ad575dd92cca)


### Step 2: Setup Self-Hosted Runner on EC2

1. #### In GitHub

    To set up a self-hosted GitHub Actions runner, start by navigating to your GitHub repository and clicking on Settings. Go to the Actions tab and select Runners. Click on New self-hosted runner and choose Linux as the operating system with X64 as the architecture. Follow the provided instructions to copy the commands required for installing the runner (Settings --> Actions --> Runners --> New self-hosted runner).

    **Download Code**
    ```bash
    # Create a folder
    $ mkdir actions-runner && cd actions-runner
    # Download the latest runner package
    $ curl -o actions-runner-linux-x64-2.319.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
    # Optional: Validate the hash
    $ echo "3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464  actions-runner-linux-x64-2.319.1.tar.gz" | shasum -a 256 -c
    # Extract the installer
    $ tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz
    ```

    **Configure Code**
    ```bash
    # Create the runner and start the configuration experience
    $ ./config.sh --url https://github.com/Roni-Boiz/terraform-eks-tic-tac-toe-cicd --token <your-token>
    # Last step, run it!
    $ ./run.sh
    ```
    
    ![runner-1](https://github.com/user-attachments/assets/69db1f8a-2366-4cf4-9b63-a04c9d462688)


3. #### In EC2 Instance

    Next, connect to your EC2 instance via SSH or management console, and paste the commands in the terminal to complete the setup and register the runner. When you enter `./config.sh` enter follwoing details:

    - runner group --> keep as default
    - name of runner --> git-workflow
    - runner labels --> git-workflow
    - work folder --> keep default

    ![runner-2](https://github.com/user-attachments/assets/dfc3aeb2-a175-4f1d-966f-dadf8fafa816)


> [!TIP]
> At the end you should see **Connected to GitHub** message upon successful connection

### Step 3: Setup SonarQube

1. #### Install 

    Once the runner is setup it will start accepting pending jobs in the queue. First it will install all requrest software packeges to EC2 instance (docker, trivy, java, aws cli, kubectl, terraform). 

    ![sonar-0](https://github.com/user-attachments/assets/358d5933-b7c2-4b3c-ad96-5981b067b2d3)

    So once the `docker` is installed, in meantime you can setup `sonarqube` in EC2 instance. For that execute following code in EC2 instance,

    ```bash
    $ docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
    ```
    
    ![sonar-1](https://github.com/user-attachments/assets/027b32bd-3d87-404f-af44-c8bc8d54aa7d)

2. #### Integrate

    To integrate SonarQube with GitHub Actions for automatic code quality and security analysis, begin by copying the IP address of your EC2 instance (formatted as <ec2-public-ip:9000>) and logging into SonarQube using the default credentials (**username: admin, password: admin**). Once logged in, update your password, and you will reach the SonarQube dashboard. Click on Manually to create a new project, provide a project name and branch name, and click on Set up. On the next page, choose With GitHub Actions to receive integration instructions.
    
    ![sonar-2](https://github.com/user-attachments/assets/d49fe5d7-a2ad-4be9-95d9-3edf01d20f3c)

    ![sonar-3](https://github.com/user-attachments/assets/05f03908-0792-4ac2-a7ea-96259d42177c)

    ![sonar-4](https://github.com/user-attachments/assets/f029bc5a-f004-45bc-8b63-096841887bce)

    ![sonar-5](https://github.com/user-attachments/assets/ecaece76-a6e5-4f5e-a6de-5e6a8748b7af)

    ![sonar-6](https://github.com/user-attachments/assets/baf91fe9-ed24-4242-b1c0-d73a12dd3d2b)

    Open your GitHub repository, go to Settings, and navigate to Secrets and variables under Actions. Click New repository secret. Return to the SonarQube dashboard, generate a token under `SONAR_TOKEN`, copy it, and add it as a secret in GitHub with the name `SONAR_TOKEN`. Repeat this process to add other required secret `SONAR_HOST_URL`.

    ![sonar-7](https://github.com/user-attachments/assets/e1a2027b-d383-45fb-96f3-f710d12e5627)
   
    ![sonar-8](https://github.com/user-attachments/assets/012bb460-31c1-4513-96e3-b77e9c104089)
   
    ![sonar-9](https://github.com/user-attachments/assets/f27a5994-260a-48fb-964b-b546b0053167)
   
    ![sonar-10](https://github.com/user-attachments/assets/1f9dcf37-a443-48da-9a96-d1739903e93f)

    Back on the SonarQube dashboard, click Continue and create a workflow file for your project, selecting the appropriate framework (e.g., React JS). SonarQube will generate the necessary workflow file. Go to GitHub, click Add file, and create a new file named `sonar-project.properties` with the provided content, such as `sonar.projectKey=tic-tac-toe`. This file ensures the integration is set up properly, allowing SonarQube to analyze your code as part of your CI/CD pipeline (this part is already done, you need to update them accordingly).

    ![sonar-11](https://github.com/user-attachments/assets/eb553229-fb52-4684-9f13-3f71d93309cd)
   

### Sept 4: Setup DockerHub

1. #### Create Access Token

    To create a Personal Access Token for your Docker Hub account, start by navigating to Docker Hub, clicking on your profile, and selecting Account settings. Go to Security and click on New access token. Provide a name for your token and click Generate token. Make sure to copy the token and save it in a secure location, as it will not be shown again.

    ![docker-1](https://github.com/user-attachments/assets/6c89c10c-8e85-451f-830d-5c6d0e445633)


2. #### Create Repository Secrets

    Next, go to your GitHub repository, click on Settings, and navigate to Secrets and variables under Actions. Click New repository secret and add your Docker Hub username with the secret name `DOCKERHUB_USERNAME`. Click Add Secret. Then, create another repository secret by clicking New repository secret again, name it `DOCKERHUB_TOKEN`, paste the generated token, and click Add secret.

    ![docker-2](https://github.com/user-attachments/assets/5eac0ea9-b3fe-4cc7-b0ab-1818c58b61c5)
   
    ![docker-3](https://github.com/user-attachments/assets/5d19bc39-d754-4568-ad56-f75c954d9def)

This securely stores your Docker Hub credentials in GitHub for use in your workflows.

![docker-4](https://github.com/user-attachments/assets/07e58675-6723-4b29-a643-f92507c37f8a)

> [!NOTE]
> Don't forget to update the image tag/name in all the places `.github/workflows/cicd.yml` and `manifests/deployment-service.yml`


### Step 5: Setup Slack

1. #### Create Channel

    To set up Slack notifications for your GitHub Actions workflow, start by creating a Slack channel `github-actions` if you don't have one. Go to your Slack workspace, create a channel specifically for notifications, and then click on Home.

    ![slack-1](https://github.com/user-attachments/assets/a9ff50f7-ed1b-4c1e-9f4a-4e764b065e42)


2. #### Create App

    From the Home click on Add apps than click App Directory. This opens a new tab; click on Manage then click on Build and then Create New App.

    ![slack-2](https://github.com/user-attachments/assets/a31ad468-9245-4910-a7d9-0917c3d9fbde)
   
    ![slack-3](https://github.com/user-attachments/assets/6f8c4597-5080-432e-9e7d-9bc93216ea4b)
   
    ![slack-4](https://github.com/user-attachments/assets/c2bdad8a-594a-47c9-9790-efe640055f4c)
   
    ![slack-5](https://github.com/user-attachments/assets/af997c64-8ce0-451b-a19f-590fd2612299)

    Choose From scratch, provide a name for your app, select your workspace, and click Create. Next, enable Incoming Webhooks by setting it to "on," and click Add New Webhook to Workspace. Select the newly created channel for notifications and grant the necessary permissions.

    ![slack-6](https://github.com/user-attachments/assets/4d3f5de1-787a-4f2b-9564-51ef30419b8e)
   
    ![slack-7](https://github.com/user-attachments/assets/ae41c68a-eb0b-4a67-99c8-80c2911d670e)
   
    ![slack-8](https://github.com/user-attachments/assets/258e8a84-3d4e-46e3-9781-fee3cd5a115a)
   
    ![slack-9](https://github.com/user-attachments/assets/3dbbc36c-ebef-4dcc-b191-e0d837ebb0ce)


3. #### Create Repository Secret

    This generates a webhook URL—copy it and go to your GitHub repository settings. Navigate to Secrets > Actions > New repository secret and add the webhook URL as a `SLACK_WEBHOOK_URL` secret.

    ![slack-10](https://github.com/user-attachments/assets/d5d52a5b-da70-413d-b659-1b31019cb029)
   
    ![slack-11](https://github.com/user-attachments/assets/3bde28ac-2bca-4b85-b852-a58966feb135)

This setup ensures that Slack notifications are sent using the act10ns/slack action, configured to run "always"—regardless of job status—sending messages to the specified Slack channel via the webhook URL stored in the secrets.

> [!NOTE]
> Don't forget to update the **channel name** (not the app name) you have created in all the places `.github/workflows/terrafrom.yml`, `.github/workflows/cicd.yml`, `.github/workflows/destroy.yml`.


### Step 6: Pipeline

Following workflows will execute in background `Script --> Terraform --> CI/CD Pipeline`. Wait till the pipeline finishes to build and deploy the application to kubernetes cluster.

**Script Pipeline**

![script-pipeline](https://github.com/user-attachments/assets/c7c229f8-0029-42bf-8a58-f6ef551ad011)

**Terraform Pipeline**

![terraform-pipeline](https://github.com/user-attachments/assets/4085ae9e-fe32-46ed-ab04-ba0e4916e138)

**CICD Pipeline**

![cicd-pipeline](https://github.com/user-attachments/assets/70f401aa-128c-42fc-8768-cfd4f8eea226)

After ppipeline finished you can access the application. Following images showcase the output results.

**SonarQube Output**

![sonar-out](https://github.com/user-attachments/assets/701db533-8c1e-4ce4-befc-84c77064d6f2)

**Cluster Output**

```bash
$ kubectl get all
```

![k8s](https://github.com/user-attachments/assets/5ef9c347-6772-4f1d-b990-88a89e5c23b8)

> [!NOTE]
> Copy the EXTERNAL-IP of application service (`service/tic-tac-toe-service`) and paste on browser to access the application

**Slack Channel Output**

![slack-channel-1](https://github.com/user-attachments/assets/c846bf6b-d87e-4988-9ac0-7d5c9de822ab)

**Application**

![app](https://github.com/user-attachments/assets/204088cc-b56d-4b12-ad05-0fef04eef024)

### Step 7: Destroy Resources

Finally if you need to destroy all the resources. For that run the `destroy pipeline` manually in github actions.

**Destroy Pipeline**

![destroy-pipeline](https://github.com/user-attachments/assets/a22c92b9-f699-4516-989c-c7b7befec45a)

**Slack Channel Output**

![slack-channel-2](https://github.com/user-attachments/assets/3c053af8-b313-4539-975a-f8eb36f28355)


### Step 8: Remove Self-Hosted Runner

Finally, you need remove the self-hosted runner and terminate the instance.

1. #### Open your repository 

    Go to Settings --> Actions --> Runners --> Select your runner (git-workflow) --> Remove Runner. Then you will see steps safely remove runner from EC2 instance.

2. #### Remove runner 
    
    Go to your EC2 instance and execute the command

    ```bash
    # Remove the runner
    $ ./config.sh remove --token <your-token>
    ```
    
    ![runner-remove](https://github.com/user-attachments/assets/fc0e9117-00a5-478d-974d-3d428e49c381)

> [!WARNING]
> Make sure you are in the right folder `~/actions-runner`

3. **Terminate Instance**

    Go to your AWS Management console --> EC2 terminate the created instance (git-workflow) and then remove any additional resources (vpc, security groups, s3 buckets, dynamodb tables, load balancers, volumes, auto scaling groups, etc)

    **Verify that every resource is removed or terminated**
