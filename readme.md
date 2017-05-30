Installing Docker Volume Driver for Azure File Storage on Azure Container Services
====

If you're reading this, it's probably because you are looking for a way for get an Azure Storage Account connected to Azure Container Services for persistent storage. One would think that Azure Container Services would have the ability to use Azure Storage for persistent storage for Docker Volumes. Out of the box, Azure Container Services does not come with the [Docker Volume Driver for Azure File Storage](https://github.com/Azure/azurefile-dockervolumedriver), rather it only includes the default drivers that are installed with Docker. To access Azure Storage with Azure Container Services, the driver has to be installed manually on each of the Swarm nodes (agent VM's) on the Swarm cluster. These scripts are useful for installing the driver on all the agents in Docker Swarm configuration on Azure Container Service.

One caveat though: if number of of nodes is ever scaled up, you'll need to rerun the scripts to install the drivers on the new nodes that Azure creates.

##Prerequisites

* An Azure Storage Account -- For best results, create the storage account in the same region as the container services. This will guarantee  the best possible speeds between the agents and the Azure Storage File Shares.
* Azure Container Services setup with Swarm Orchestration. These scripts assume Swarm or Kubernetes Orchestration and have not been tested on DC/OS. For Kubernetes instructions see below:
* An SSH client. This is built into MacOS and Linux. If you don't already have it, get [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) for Windows.
* An SCP client. This is built into MacOS and Linux. Get [PSCP](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) for Windows.
* [PuttyGen](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) for Windows

##Usage

1. Connect to the Swarm Master. [Follow the instructions here if you don't already know how](https://docs.microsoft.com/en-us/azure/container-service/container-service-connect).

1. Copy your SSH private key to the master node. This is the private key that was used to generate the public key that was provided to Azure when the instance of Azure Container Services was created. Odds are, you either used ssh-keygen on Mac or Linux or PuttyGen on Windows. The private key is needed to so that the Swarm Master can connect to the Agents with SSH and run scripts.

	**Mac and Linux**:

	Copying the key from a Mac or Linux box is a simple command:

	````
	scp ~/.ssh/id_rsa user@masterdns:~/.ssh/id_rsa
	````

	Replace **masterdns** with the same Master FQDN that was used to connect to the master node with SSH and replace the **user** with the admin user specified when the  cluster was created.

	**Windows**:

	Open **Puttygen** and load the .ppk used to generate the public key when you created your instance of Azure Container Services.

	On the **Conversion** menu, select **Export Open SSH Key**, and save the key without a password as **id_rsa**.

	Use the **PSCP** utility that came with Putty to copy the **id_rsa** file to the master node. The user is the admin user specified when the cluster was created and the master DNS is the FQDN of the master node.

	````
	\path\to\pscp.exe -i \path\to\key.ppk \path\to\id_rsa user@masterdns:.ssh
	````

	*Example*: This example placed the id_rsa in the same folder with the .ppk that was used to generate the id_rsa file. The example assumes the user changed directory to the path of these files (ie. cd \path\to\files).

	````
	C:\Users\blaize\Downloads\putty\pscp -i private.ppk id_rsa blaize@acsstoragedemomgmt.southcentralus.cloudapp.azure.com:.ssh
	````

1. On the Swarm Master, change directories to the SSH folder.

	````
	cd ~/.ssh
	````

1. Change the permissions in the key

	````
	chmod 600 id_rsa
	````

1. Install unzip.

	````
	sudo apt-get install -y unzip
	````

1. Change directories to the users home folder.

	````
	cd ~
	````

1. Download the scripts zip file.

	````
	wget https://github.com/theonemule/azure-file-storage-on-acs/archive/master.zip
	````

1. Unzip the scripts zip file.

	````
	unzip master.zip
	````

1. CD to scripts directory.

	````
	 cd azure-file-storage-on-acs-master
	````

1. Build the driver from the source. This script will install the build tools need to build the binary then build it.

	````
	sudo sh build.sh
	````

1. Edit install-local.sh

	````
	nano install-local.sh
	````

	* Replace "yourstorageaccount" with the name of your storage account. Leave the quoatation marks.
	* Replace "yourkey" with the key from your storage account. Leave the quotation marks.

1. Save the file by pressing Ctrl+O and exit nano with Ctrl+X

1. Run the **install-agent.sh** script. This script detects the nodes on the cluster, uploads the built binary, a config file, and install-local.sh script to each cluster. After uploading, it invokes the install script to install the driver on each node. This script does NOT use nano.


	**Swarm**:

	````
	sh install-agents.sh
	````

	**Kubernetes**:

	````
	sh install-agents-kubernetes.sh
	````

1. Test the install.

	**Swarm:**

	On the client machine, use the docker client to create a volume.

	````
	docker -H 127.0.0.1:22375 volume create -d azurefile -o share=myvol --name vol1
	````
	* -H specifies the local port that is forwarded to the master node by SSH.
	* -d specifies the driver
	* -o share sets the option of the share name. This is the share that is created in the Azure Storage Account
	* --name sets the name of the volume. The volume can then be mounted inside containers using the -v parameter when the docker run command is executed.

	**Kubernetes:**

	Follow the instructions here: https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/azure_file ignoring the installation of cifs-utils.
