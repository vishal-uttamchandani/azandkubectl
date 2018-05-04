### Running Az and Kubectl

#### Running Az from Git Bash on windows

There are several issues in running Azure CLI 2.0 tool from git bash:

- Install python
- Install Az tool
- python 2.7 is not automatically added to PATH. python 3 does have an option to automatically be added to the PATH
- Az is not added to the PATH. Also az is not an exe. But rather a bash script. So the path that needs to be added is of a bash script "az" file.
- After all this, when running az it displays an error "module azure not found"

>**Note**: The above issues are only for git bash. If you run from Azure command prompt it should run just fine. But I want to keep using git bash (mainly for 2 reasons: unix tools and fira code)

According to the azure cli team, they don't officially support running az cli from git bash :(. See github issue [here](https://github.com/Azure/azure-cli/issues/3445)

#### Overview

Things to know:

- Az is a tool to manage azure resources.
- Kubectl is a tool to interact with kubernetes cluster.
- We need Az to create a kubernetes cluster on AKS and Kubectl to create resources on that cluster
- In order for kubectl to connect to a kubernetes cluster it needs a config file containing the 
cluster context. This file can be auto populated with use of Az tool.
- Kubectl runs just fine from Git bash.

So here is a solution:

- Run Az inside a docker container
- Install Kubectl inside the container
- Create kubernetes cluster using Az tool
- Update the kubectl config file with context of the newly created cluster using Az tool
- Copy the config file from the container to your host
- Use Kubectl from localhost

The benefit we get out of running Kubectl from localhost is that now we can run a proxy to access the kubernetes cluster dashboard. This cannot be done from inside the container without some docker network setting.

#### Commands

>**Note**: For windows, make sure to go to docker settings and select the shared drive of your choice to be made available to the container. In this case I have chosen "C:" drive.

- ```winpty docker run -v C:\Users\vishal:/root -it microsoft/azure-cli```
- ```az aks install-cli```  (this will install kubectl)
- ```az aks get-credentials -n <cluster-name> -g <resourcegroup-name>``` (this will update the kubectl config file located at ~/.kube/config)
- Exit out of the container
- ```docker cp container-name:/root/.kube/config ~/.kube/config``` (this will copy kubectl config from the container to the host machine) 
- Run ```kubectl get nodes``` to retrieve nodes from the cluster
- To access the kubernetes dashboard run ```kubectl proxy```
