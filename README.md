# SitefinityAWS
Components that facilitate setting up Sitefinity instances on Amazon AWS using CloudFormation templates and Powershell Desired State Configuration (DSC).

The basic setup consist of two main resources:
  1. Amazon EC2 Windows Server 2012 R2 instance configured from the latest public amazon basic image using powershell desired state configuration.
  2. Amazon RDS MS Sql express instance.


Once the creation of the stack via the supplied in this repository template is complete, the windows instance that will be the Sitefinity web server is booted and its URL is returned as output parameter. The instace is not immediately available upon completion as It takes about 15-30 minutes for the desired state configuration to install the required windows features, configure the IIS, permissions, download the zip package containing the Sitefinity web site and its license file and create a startup file that indicates the location of the database server for the initialization.
