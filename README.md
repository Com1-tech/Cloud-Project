# Cloud-Project
Azure Environment
## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, selected portions of the yaml file may be used to install only certain pieces of it, such as Filebeat.
  - elk.yml
  
  This document contains the following details:
- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build
- Access Policies

### Description of the Topology
This repository includes code defining the infrastructure below. 

![](Images/Network-Diagram.png)

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available, in addition to restricting inbound access to the network. The off-loading function of a load balancer defends an organization against distributed denial-of-service (DDoS) attacks. It does this by shifting attack traffic from the corporate server to a public cloud provider.

A jumpbox creates a separation between networks with different security requirements. Acts as a single audit point for traffic and a single place where user accounts can be managed. Provides auditing control. 

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the "file systems of the VMs on network" and "system metrics".
- Filebeats watch for log info about file systems and files that have changed and when.
- Metricbeat records and detects changes in system metrics, such as CPU usage, failed SSH login attempts, failed sudo escalations and CPU/RAM statistics.

The configuration details of each machine may be found below.
_Note: Use the [Markdown Table Generator](http://www.tablesgenerator.com/markdown_tables) to add/remove values from the table_.

| Name       | Function   | IP Address | Operating System |
|------------|------------|------------|------------------|
| Jump Box   | Gateway    | 10.0.0.4   |Linux/Ubuntu 18.04|
| Web-1      | Web Server | 10.0.0.5   |Linux/Ubuntu 18.04|
| Web-2      | Web Server | 10.0.0.6   |Linux/Ubuntu 18.04|
| Web-3      | Web Server | 10.0.0.8   |Linux/Ubuntu 18.04|
| Elk-Server | Monitoring | 10.1.0.4   |Linux/Ubuntu 18.04|

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the _Jumpbox_ machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- 10.0.0.5
- 10.0.0.6
- 10.0.0.8

Machines within the network can only be accessed by SSH.
- Elk VM - 10.1.0.4
- JumpBox VM - 104.45.196.7

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses |
|----------|---------------------|----------------------|
| Jump Box | Yes/No              | 104.45.196.7         |
| ELK      | No                  | 10.1.0.4             |
| Web-1    | No                  | 10.0.0.5             |
| Web-2    | No                  | 10.0.0.6             |
| Web-3    | No                  | 10.0.0.8             |

### Elk Configuration

The ELK VM exposes an Elastic Stack instance. **Docker** is used to download and manage an ELK container
Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because multiple VMs can be updated, configured automatically. 

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because all settings are pre-configured

The playbook implements the following tasks:
- Configure ELK VM with Docker
- Gathering Facts
- Install docker.io
- Install pip3
- Install Docker python module
- Increase Memory
- Download and Launch a docker elk container

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![TODO: Update the path with the name of your screenshot of docker ps output](Images/docker_ps_output.png)

The playbook is duplicated below.

```yaml
---
# install_elk.yml
- name: Configure Elk VM with Docker
  hosts: elkservers
  remote_user: elk
  become: true
  tasks:
    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        name: docker.io
        state: present

      # Use apt module
    - name: Install pip3
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

      # Use pip module
    - name: Install Docker python module
      pip:
        name: docker
        state: present

      # Use command module
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144

      # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: "262144"
        state: present
        reload: yes

      # Use docker_container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        published_ports:
          - 5601:5601
          - 9200:9200
          - 5044:5044
```

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
- 10.0.0.5
- 10.0.0.6	
- 10.0.0.8

We have installed the following Beats on these machines:
-filebeats
-metricbeats

These Beats allow us to collect the following information from each machine:
- Filebeat: Detects changes to the filesystem. Collect Apache Logs
- Metricbeat: Detects changes in system metrics 
    -CPU Usage
    -Detect SSH login attempts
    -Failed sudo escalations
    -CPU/RAM statistics

The playbook below installs Metricbeat on the target hosts. The playbook for installing Filebeat is not included, but looks essentially identical — simply replace `metricbeat` with `filebeat`, and it will work as expected.

```yaml
---
- name: Install metric beat
  hosts: webservers
  become: true
  tasks:
    # Use command module
  - name: Download metricbeat
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.4.0-amd64.deb

    # Use command module
  - name: install metricbeat
    command: dpkg -i metricbeat-7.4.0-amd64.deb

    # Use copy module
  - name: drop in metricbeat config
    copy:
      src: /etc/ansible/files/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

    # Use command module
  - name: enable and configure docker module for metric beat
    command: metricbeat modules enable docker

    # Use command module
  - name: setup metric beat
    command: metricbeat setup

    # Use command module
  - name: start metric beat
    command: service metricbeat start
    
### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the playbooks to the Ansible Control Node
- Update the correct IP addreses and Ports
- Run the playbook, and navigate to web servers check that the installation worked as expected.

The easiest way to copy the playbooks is to use Git:

```bash
$ cd /etc/ansible
$ mkdir files
# Clone Repository + IaC Files
$ git clone https://github.com/Com1-tech/Cloud-Project.git
# Move Playbooks and hosts file Into `/etc/ansible`
$ cp Cloud-Project/playbooks/* .
$ cp Cloud-Project/files/* ./files
```

This copies the playbook files to the correct place.

Next, you must create a `hosts` file to specify which VMs to run each playbook on. Run the commands below:

```bash
$ cd /etc/ansible
$ cat > hosts <<EOF
[webservers]
10.0.0.5
10.0.0.6
10.0.0.8

[elk]
10.1.0.4
EOF
```

After this, the commands below run the playbook:

 ```bash
 $ cd /etc/ansible
 $ ansible-playbook install_elk.yml elk
 $ ansible-playbook install_filebeat.yml webservers
 $ ansible-playbook install_metricbeat.yml webservers
 ```

To verify success, wait five minutes to give ELK time to start up. 

Then, run: `curl http://10.1.0.4:5601`. This is the address of Kibana. If the installation succeeded, this command should print HTML to the console.
