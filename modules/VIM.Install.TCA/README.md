## Versions
The following Telco Cloud Automation versions were tested with this module:
- TCA 2.1.x
- TCA 2.2

## Modules
Below are a list of required modules to install before using this module.

| Module   |Description              |PowerCLI for Windows|PowerCLI Core|
|----------|-------------------------|--------------------|-------------|
| VMWare.PowerCLI     |vSphere Distributed Switch Cmdlets | √ | √ |

```
Install-Module -Name VMware.PowerCLI
```

NOTE: Internet access may be required to install modules from PSGallery.

## OVA
Currently the vTelco Cloud Automation OVA must be stored in the destination vCenter Server Content Library. This module is not yet capable of deploying  appliances to an unmanaged standalone ESXi host or using a local OVA.

# Procedure
The following procedure will assist with the usage of the Install-TCA module to deploy a Telco Cloud Automation appliance. The steps below assume you have already installed the latest VMware.PowerCLI module.

## Create a TCA Manager and/or TCA ControlPlane JSON Payload
The json configuration is based on the TCA appliance OVF properties. An example JSON can be found in \config\tca\appliances.

## Usage
Install-TCA -JSONPath $file -$OVAName "TCA 2.2"

## Install Telco Cloud Automation
1. Download the project folder structure. Use your favorit git platform or the GitHub Desktop.
2. On a Windows computer, click Start > Windows PowerShell > Right-Click Windows PowerShell > Click Run as Administrator.
3. At the command prompt change the working directory to the root of the project folder where the project was downloaded:
 ```
 cd C:\Users\<username>\Documents\GitHub\TCI
 ```
4. At the command prompt import the required modules:
```
Import-Module "C:\Users\<username>\Documents\GitHub\TCI\modules\VIM.Install.TCA\VIM.Install.TCA.psm1"
```
5. At the PowerShell command prompt connect to the destination vCenter Server:
``` 
Connect-VIServer -Server vcenter.fartknocker.org -Credential (Get-Credential)
```
6. Load the json config into a string variable:
```
$json = Get-Content "C:\Users\<username>\Documents\GitHub\TCI\config\tca\appliances\tcp_config.json" | Out-String
```
7. Set a powershell string variable to set the name of the TCA OVA in the Content Library you wish to deploy. If the name is unknown, run the command Get-ContentLibraryItem | Select Name to get a list of content library names.
```
PS C:\Windows\system32> Get-ContentLibraryItem | Where {$_.Name -like "*Vmware-Telco*"} | Select Name

Name
----
VMware-Telco-Cloud-Automation-2.2.0-21068621
$ova = "VMware-Telco-Cloud-Automation-2.2.0-21068621"
```
8. Deploy your TCA appliance using the TCA json payload created earlier:
```
PS C:\Windows\system32> Install-TCA -JSONPath D:\scripts\functions\Deploy-TCA\config\tcp-config.json -OVAName "VMware-Telco-Cloud-Automation-2.2.0
```

Once complete the VM should be powered on and ready for activation.