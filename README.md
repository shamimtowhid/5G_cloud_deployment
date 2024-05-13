## Introduction
This repository deploys 5G core networks (implemented by [free5gc](https://github.com/free5gc/free5gc)) with UE and GNB (implemented by [UERANSIM](https://github.com/aligungr/UERANSIM)) to AWS cloud in a distributed manner. The following sections describe how to setup the environments to run the automation scripts.
For now, the repository deploys all the core functions (including UPF) to one region in AWS, the UE and GNB are co-located in a separate region. In the future, this repository will be extended
to cover multiple scenarios. 

## Requirements
- Terraform 1.6.6
- AWS-CLI 2.15.6
- Packer 1.10.0
- Ansible 2.15.8
- Python >= 3.6.8

The repository is tested with Ubuntu 22.04 LTS (Kernel 6.5.0-28-generic) as the control (Local) node. The remote hosts are running Ubuntu Server 22.04 LTS as OS. 

## How to set up the environment
After installing all the required packages, configure your AWS-CLI with the appropriate credentials. It is recommended to create an account in AWS with appropriate privileges so that the 
account can create Amazon Machine Images (AMI) and launch EC2 instances. 

After creating the account and access keys in AWS, copy the "aws_access_key_id" and "aws_secret_access_key" from AWS account. Put the copied credentials in '/home/<user_name>/.aws/credentials' file.

Now, create key pairs from AWS in the regions where you want to deploy the networks and UEs. For example, if you want to deploy core networks in "US-East2" and the UEs in "US-WEST2" then 
create key pairs from these two regions in AWS. Store the key pairs file in a safe location. 

## Change Configurations
There are two configuration files you need to change before deploying the networks. These files can be found in the "cfg" directory. The "control_cfg.json" is for core networks and the "ue_cfg.json"
is for the UE and GNB.

Example control_cfg.json

```
{
  "source_ami": "ami_id_from_AWS",
  "aws_instance": "t2.small",
  "aws_region": "us-east-2",
  "zone": "us-east-2a",
  "infra_env": "staging",
  "infra_name": "5G_core",
  "ssh_username": "<username>",
  "key_pair": "<key_pair_name>",
  "wg0": "11.0.0.1/24",
  "wg1": "12.0.0.1/24"
}
```
In the above configuration file, you need to pass AMI id of the Amazon Machine Image you want to use for deploying the core part. In our experiment, we used the AMI id for Ubuntu Server 22.04 LTS
from that specific region (us-east-2). The minimum instance type required for the core part is "t2.small". If you select "t2.micro", the build will not work because node.js requires at least 2GB
memory to build properly. 

The key_pair file path for this specific region should be given in the "key_pair" field. You downloaded this file from AWS during setting up the environment. 

The "wg0" and "wg1" are IP addresses for the Wireguard interfaces. We need to set up VPN connections between GNB-AMF (NGAP) and GNB-UPF (GTP-tunnel). These are the ip addresses for those two 
Wireguard interfaces. If you are not sure what to put here, you can keep it as it is. 

Change region and zone according to your needs. Just make sure you put the correct AMI ID and key_pairs. A username can be any valid username for the remote hosts. 

Prepare the "us_cfg.json" similar to the "control_cfg.json". 

## Deployment
After setting up the environment properly and configuring the two JSON files, you are all set to start the deployment. You need to run seven Ansible playbooks in total to deploy the networks.
To run a playbook, enter the following command in the terminal. 
```
ansible-playbook -i inventory.ini <playbook_path>
```

- The first playbook "playbook-1_build_ami" will create new AMI in respective regions. These new AMIs will have everything installed in it and the host network will be configured as necessary. This playbook will update the configuration files with the created AMI ID in AWS. This AMI ID will be used later. 
- The second playbook "playbook-2_provision_resources.yml" will create all the required resources (i.e., VPC, Internet Gateway, Security Groups) in AWS and launch the EC2 instances from the AMI created in the previous step. This playbook will edit the configuration files to add the public IP of the created EC2 instances which will be used later.
- The third playbook "playbook-3_setting_interfaces" will create Wireguard interfaces and configure them as necessary. This playbook will use a local Python script "convert_json.py".
- The fourth playbook "playbook-4_configure_nf" will change configurations for AMF, SMF, UPF, GNB as necessary.
- The fifth playbook "playbook-5_run_core" will run each function of the core networks. It will also launch the web console for registering UE to the core networks.
- In step 6, you need to go to the web console of free5gc to register the UE. To go to the web console just look at the public IP of the launched EC2 for core networks from its configuration file. Then open the following link 'http://<public_ip>:5000' in a browser. 
  The default password and username for free5gc is "free5gc" and "admin", respectively. To register the UE please look at the UE configuration file present in the "nf_cfg" directory of this repo. You should register a UE by following the same configuration mentioned in "nf_cfg/free5gc-ue.yaml" file.
- Once you register the UE, go back to the terminal and run 6th playbook "playbook-6_run_ue". This will run the GNB and UE both. Now, if you ssh into the EC2 instance for UE using the key_pair file for that region and the username you provided in the "ue_cfg.json" file, you will see there is an interface called "uesimtun0" in this EC2 instance.
  If you see the interface, it means everything is correct. If you don't that means something went wrong.
- If everything is correct so far, you can test the network connections by sending ping to "google.com" using "ping -c 5 -I uesimtun0 google.com" command. If you are getting reply from the ping request, that means the deployment is successful.


## Acknowledgement
This repository is motivated by the work of [5G-mec-infra](https://github.com/piotmni/5g-mec-infra/tree/master)

## References
[1] [Free5GC](https://github.com/free5gc/free5gc)
[2] [UERANSIM](https://github.com/aligungr/UERANSIM)
[3] [5G-Mec-Infra](https://github.com/piotmni/5g-mec-infra/tree/master)
