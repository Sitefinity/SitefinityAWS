# SitefinityAWS
Components that facilitate deploying new Sitefinity instances on Amazon AWS using CloudFormation templates and Powershell Desired State Configuration (DSC).

The basic setup consist of two main resources:
  1. Amazon EC2 Windows Server 2012 R2 instance configured as a web server from the latest public amazon basic image using Powershell desired state configuration.
  2. Amazon RDS MS SQL express instance that is provisioned and configured to be accessible from the web server instance.

![Sitefinity simple setup Amazon AWS CloudFormation](http://d10fqi5lwwlsdr.cloudfront.net/sitefinityImages/default-source/default-album/basic-sitefinity-webapp-aws-crop-resize.png?sfvrsn=0)

## How to use:

  1. Choose which version of Sitefinity to use. By default the template specifies Sitefinity 10.0 empty project upload at [this location](https://s3.eu-central-1.amazonaws.com/telerik-sitefinity/amazon-cloud-formation/sitefinity-web-app/10.0.6400.0/SitefinityWebApp.zip). If you wish to use a newer version create an empty project and upload it to your S3 storage as a .zip file that contains the site in its root folder. Earlier versions than 8.2 will not initialize automatically.
  2. Upload your Sitefinity license file to S3 as a private file. You can acquire such a file by purchasing Sitefinity or downloading a trial Sitefinity from [Sitefinity.com](http://sitefinity.com). To be able to use this file you have to generate a signed link to it. To do this you can use an online S3 signed link generator, Bucket Explorer or the Amazon SDK.
  2. Download the "BasicSitefinityWebServer.template.json" and specify it as the template for a new CloudFormation stack you are about to create in the AWS console. Then fill in the properties that are required by the template.
  4. Once the creation of the stack is complete the windows instance that will be the Sitefinity web server is booted and its URL is returned as an output parameter in the AWS console. The web server is not immediately available upon completion as it takes about 20-30 minutes for the desired state configuration to install the required windows features, configure the IIS, permissions, download the zip package containing the Sitefinity web site and its license file and create a startup file that indicates the location of the database server for the initialization. This process requires a restart of the instance so at a given point it will be inaccessible. After the initialization is complete when you navigate to the returned URL you will be able to log in with the credentials you specified in step 2.

## About the template

### External dependencies:
  1. Windows image id (AMI of the latest basic Windows Server 2012 R2 image.)
  2. SitefinityWebApp.zip (The zip of the Sitefinity web site you wish to deploy. The zip should contain the web.config in its root folder)
  3. Sitefinity.lic (Your Sitefinity license file that you should upload to S3 and specify its location. Could be a trial license.)
  4. SitefinityWebNodeDSC.ps1 (latest version: SitefinityWebNodeDSC0.2.ps1)
  5. Unzip-Archive.ps1 (Used from the quick reference amazon bucket)
  6. Powershell DSC modules: xPSDesiredStateConfiguration, xWebAdministration, PowerShellAccessControl.
  

