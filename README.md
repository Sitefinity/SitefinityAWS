# SitefinityAWS
Components that facilitate setting up Sitefinity instances on Amazon AWS using CloudFormation templates and Powershell Desired State Configuration (DSC).

The basic setup consist of two main resources:
  1. Amazon EC2 Windows Server 2012 R2 instance configured from the latest public amazon basic image using Powershell desired state configuration.
  2. Amazon RDS MS Sql express instance.

## How to use:
Just download the "BasicSitefinityWebServer.template.json" or any other template of your choosing and specify it as the template for a new CloudFormation stack you are about to create in the AWS console.

Once the creation of the stack is complete the windows instance that will be the Sitefinity web server is booted and its URL is returned as an output parameter. The web server is not immediately available upon completion as it takes about 15-30 minutes for the desired state configuration to install the required windows features, configure the IIS, permissions, download the zip package containing the Sitefinity web site and its license file and create a startup file that indicates the location of the database server for the initialization.


## About the template

External dependencies:
  1. Windows image id (AMI of the latest basic Windows Server 2012 R2 image.)
  2. SitefinityWebApp.zip (The zip of the Siteifnity web site you wish to deploy. The zip should contain the web.config in its root folder)
  3. Siteifnity.lic (Your Sitefinity license file that you should upload to S3 and specify its location. Could be a trial license.)
  4. SitefinityWebNodeDSC.ps1 (latest version: SitefinityWebNodeDSC0.2.ps1)
  5. Unzip-Archive.ps1 (Used from the quick reference amazon bucket)
  6. Powershell DSC modules: xPSDesiredStateConfiguration, xWebAdministration, PowerShellAccessControl.
