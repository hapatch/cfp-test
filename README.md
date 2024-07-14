# Running this repository

## Requirements

### Manual Installations
WINDOWS:
- [Docker](https://docs.docker.com/desktop/install/windows-install/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-cli)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

MACOS:
- [Docker](https://docs.docker.com/desktop/install/mac-install/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Azure CLI - use brew (brew install azure-cli)](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos)

### Package Manager Installations
Windows / Chocolatey
```bash
choco install docker-desktop terraform azure-cli just
```


or MacOS / Homebrew
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform azure-cli just
```
For Docker, you will need to download the installer from the website for simplicity.


### Running locally

To run the application and database locally we are going to make use of docker-compose.

This means that building, and running the application is as simple as running
The following from the project's root directory:

```bash
docker-compose up
```

This will build the application and database, and then run them in the same network.

Allowing you to access the application at `http://localhost:3000/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL`


### Running in Azure

This part of the process is a bit more involved, but it is still quite simple.
You will need to be logged into your Azure account and have the necessary permissions to create resources.

First, you will need to perform the login step for Azure:

```bash
az login
```

This will prompt you to login through your browser, please also select an appropriate subscription if you have multiple.

--- 
From there Terraform is able to handle the rest.

For this purpose I have written a script that will handle the creation of the resources in Azure:

If you installed `just` you can run the following command:

```bash
just run_cloud
```

Otherwise, if you are on windows you can run the following command:

```bash
run.bat
```

Or if you are on a Unix based system you can run the following command:

```bash
./run.sh
```

Note:
This script will prompt you for creating the Azure Registry resource.

This will create the necessary resources in Azure for us to push our docker images to. 
It will then push those images, and create a terraform plan for us to apply.

If you are happy with the plan you can run the following command:

```bash
terraform apply tfplan
```

This will create the resources in Azure, and you will be able to access the application at the public IP address that is outputted at the end of the apply process.

> [!WARNING]
> You will need to wait about 5 minutes for the VM resources to be fully created and the containers to start up.

### Cleaning up
Cleaning up all your cloud resources is as easy as running:
```bash
terraform destroy
```

This will remove all the resources that were created by terraform.

# Conclusion

## Tools used and why

### Docker
I made use of Docker so that I could virtualize the environment that the application would be running in. This allows for a consistent environment across all machines.

It also allows for ease of deployment, as the application can be run in the same way on any machine that has docker installed.

### Terraform
I needed to automate the setup of the infrastructure, and Terraform is the best tool for that job. 
While not specific to Azure like Bicep/ARM templates, it is a tool that I am (slightly) more familiar with and can use across multiple cloud providers.

### Azure CLI
I made use of the Azure CLI to handle the login process for Azure.

It is a requirement to have some sort of login mechanism, and this provides that

### Just
I made use of Just to handle the running of the cloud script.

It is also extremely useful in standardizing the way that scripts are run across machines, with good flexibility for tackling complex problems.
