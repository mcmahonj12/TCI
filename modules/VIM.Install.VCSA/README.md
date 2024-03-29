# Install vCenter Server Appliance
Use PowerCLI to deploy vCenter Server appliances in a fully automated manner without the ISO or CLI. Deploying the vCenter Server OVA with Import-vApp or New-VM would halt the deployment at Stage 2 requiring manual intervention from there.

Install-vCSA enables the ability to load a module into a PowerShell session and use it to deploy any desired number of vCSA appliances using a JSON payload and OVA.

The module has a 25 minute timeout built into it. The timeout is so long because it can take as long as 20 minutes to perform a full configuration of the appliance.

## Purpose
VCF or VMC environments are my primary targets so a way to avoid the need to put a Jump Host inside the environment is highly desired. You cannot simply deploy VCSA to VMC without jumping through some hoops first. William Lam documents the issue on his blog well: https://williamlam.com/2019/05/deploying-a-vcenter-server-appliance-vcsa-in-vmc.html

I use this module to get around the VMC permissions challenge as well as mitigate security concerns with unmanaged Jump Hosts and ISO mount permissions.

The CLI can be exported from the ISO and placed on a terminal somewhere. It will perform "mass" deployments but in an asyrchronous form. With this module I have been able to create a PowerShell job and deploy as many vCenter Servers as are configuration JSONs in a folder at the same time in the same amount of time as a single VC deployment.

## Use Cases
In some cases it may be required to install many vCenter Server appliances rapidly at a desired scale, or deploy new appliances to rehydrate their configurations as a restoration method. Some use cases include:
- Lab redeploys
- Mass deployments to management clusters
- Deployment without the requirement for other automation tools
- Deploy vCenter Server from a limited permissions VDI or terminal session (no permissions to mount an ISO)
- You prefer to use PowerShell

# Support
This module is not supported by VMware or myself. It may not be kept up with other versions of vCenter Server. Use at your own risk. Always try to use vendor supported solutions first. VMware recommends using the vCenter CLI or UI installer found on the vCenter Server installation ISO.

While there are some basic error handling capabilities in this module it's by no means perfect. This module cannot provide a level of troubleshooting detail the CLI installer can using OVFTool.

# Prerequisites
This module requires additional modules to be loaded to work properly. If the modules are not installed the Install-vCSA module will not load until the modules listed below are loaded.

## Infrastructure
An existing management vCenter Server with vSphere cluster resources must be deployed and used as the destination such as VMware Cloud on AWS or VMWare Cloud Foundation. 
- Destination vCenter Server
- Destination vSphere Cluster or Host managed by the destination vCenter Server
- Content Library on the destination vCenter Server with the vCenter Server appliance OVA

## Versions
The following vCenter Server versions were tested with this module:
- vCenter Server 7.0.3.x

## Modules
Below are a list of required modules to install before using this module.

| Module   |Description              |PowerCLI for Windows|PowerCLI Core|
|----------|-------------------------|--------------------|-------------|
| VMOvFProperty     |vCenter and ESXi Cmdlets | √ | √|
| VMWare.PowerCLI     |vSphere Distributed Switch Cmdlets | √ | √ |

```
Install-Module -Name VMware.PowerCLI
Install-Module -Path "D:\scripts\modules\VM.Ovf.Property\VM.Ovf.Property"
```

NOTE: Change the path variable for the VM.Ovf.Property module to the location where you have downloaded the module.

## OVA
Currently the vCenter Server OVA must be stored in a vCenter server Content Library. This module is not yet capable of deploying vCenter Server appliances to an unmanaged standalone ESXi host.

# Procedure
The following procedure will assist with the usage of the Install-vCSA module to deploy a vCenter Server appliance. The steps below assume you have already installed the latest VMware.PowerCLI module.

## Create a vCenter Server JSON Payload
The json configuration is based on the vmware-installer-cli tool found in the vCenter Server ISO. You may use the "Deployment Configuration Parameters" article for help making the necessary changes for your requirements: https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vcenter.install.doc/GUID-457EAE1F-B08A-4E64-8506-8A3FA84A0446.html

An example JSON can be found in \config\vcenter\appliances.

## Usage
Install-vCSA -JSONPath $file -$OVAName "vCenter-Server-Appliance-7"

## Install vCenter Server
1. Download the project folder structure. Use your favorit git platform or the GitHub Desktop.
2. On a Windows computer, click Start > Windows PowerShell > Right-Click Windows PowerShell > Click Run as Administrator.
3. At the command prompt change the working directory to the root of the project folder where the project was downloaded:
 ```
 cd C:\Users\<username>\Documents\GitHub\TCI
 ```
4. At the command prompt import the required modules:
```
Import-Module "C:\Users\<username>\Documents\GitHub\TCI\modules\VM.Ovf.Property\VM.Ovf.Property.psm1"
Import-Module "C:\Users\<username>\Documents\GitHub\TCI\modules\VIM.Install.VCSA\VIM.Install.VCSA.psm1"
```
5. At the PowerShell command prompt connect to the destination vCenter Server:
``` 
Connect-VIServer -Server vcenter.fartknocker.org -Credential (Get-Credential)
```
6. Load the json config into a string variable:
```
$json = Get-Content "C:\Users\<username>\Documents\GitHub\TCI\config\vcenter\appliances\vcsa_config.json" | Out-String
```
7. Set a powershell string variable to set the name of the vCenter Serer OVA in the Content Library you wish to deploy. If the name is unknown, run the command Get-ContentLibraryItem | Select Name to get a list of content library names.
```
PS C:\Windows\system32> Get-ContentLibraryItem | Select Name

Name
----
VMware-vCenter-Server-Appliance-7.0.3.01000-20395099_OVF10
$ova = "VMware-vCenter-Server-Appliance-7.0.3.01000-20395099_OVF10"
```
8. Deploy your vCenter Server using the vCenter Server json payload created earlier:
```
PS C:\Windows\system32> Install-vCSA -JSONPath $json -OVAPath $ova

Name                 PowerState Num CPUs MemoryGB
----                 ---------- -------- --------
vcsa                 PoweredOff 4        19.000
Updating OVF Properties ...
vcsa                 PoweredOff 4        19.000
vcsa                 PoweredOn  4        19.000
Will now attempt to connect to vcsa.fartknocker.org  to validate it has come online properly.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
vcsa.fartknocker.org is not currently available. Retrying in 60 seconds.
Successfully connected to vCenter Server

IsConnected   : True
Id            : /VIServer=vsphere.local\administrator@vcsa.fartknocker.org:443/
ServiceUri    : https://vcsa.fartknocker.org/sdk
SessionSecret : "0c72c798fc6db5c33976c586d4d2acfeda71bd78"
Name          : vcsa.fartknocker.org
Port          : 443
SessionId     : "0c72c798fc6db5c33976c586d4d2acfeda71bd78"
User          : VSPHERE.LOCAL\Administrator
Uid           : /VIServer=vsphere.local\administrator@vcsa.fartknocker.org:443/
Version       : 7.0.3
Build         : 20395099
ProductLine   : vpx
InstanceUuid  : 8cd09abf-b404-48ef-8637-e89e5bb12208
RefCount      : 1
ExtensionData : VMware.Vim.ServiceInstance



PS C:\Windows\system32>
```
9. Wait 5 additional minutes before attempting to log into the UI as the Web Service is usually still starting after the API service is available. From this point additional API based configurations such as creating roles, datacenters, folders, etc. can begin.

# Credits
Additional credit must be given to some very helpful blogs and tools that made creating this module much easier.
- William Lam: https://williamlam.com/2017/10/updating-ovf-properties-for-a-vm-using-vsphere-api-and-powercli.html
- Christophe Calvet: http://www.thecrazyconsultant.com/Get-OvfConfiguration_on_steroids
