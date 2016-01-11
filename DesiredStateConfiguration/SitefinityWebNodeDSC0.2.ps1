Configuration SfWinSrv2012FeaturesIIS {
    param
    (
        # Target nodes to apply the configuration
        [string[]]$NodeName = 'localhost',

        # Name of the Sitefinity website to create'
        [String]$SfWebSiteName='SitefinityWebApp',

        # The path to the directory that will be the Sitefinity web site root folder.
        [String]$SfWebAppRoot='C:\Sitefinity\WebApp',

        # The list of windows features that must be enabled
        [string[]]$WindowsFeatures = @(
                    "Web-Server",
                    "Web-WebServer",
                    "Web-Common-Http",
                    "Web-Http-Errors",
                    "Web-Static-Content",
                    "Web-Health",
                    "Web-Http-Logging",
                    "Web-Request-Monitor",
                    "Web-Performance",
                    "Web-Stat-Compression",
                    "Web-Dyn-Compression",
                    "Web-Security",
                    "Web-Filtering",
                    "Web-App-Dev",
                    "Web-Net-Ext45",
                    "Web-Asp-Net45",
                    "Web-ISAPI-Ext",
                    "Web-ISAPI-Filter",
                    "Web-Mgmt-Tools",
                    "Web-Mgmt-Console",
                    "Web-Scripting-Tools",
                    "Web-Mgmt-Service",
                    "NET-Framework-45-Features",
                    "NET-Framework-45-Core",
                    "NET-Framework-45-ASPNET",
                    "NET-WCF-Services45",
                    "NET-WCF-HTTP-Activation45",
                    "WAS",
                    "WAS-Process-Model",
                    "WAS-Config-APIs",
                    "Desktop-Experience"
                    )
    )

    Import-DscResource -Module xWebAdministration
    Import-DscResource -ModuleName PowerShellAccessControl

    LocalConfigurationManager
    {
		#Specifying that a reboot will be initiated if the any of the applied configurations requires it.
		#In this configuration the most likely reboot requiring functionalities is the "Desktop-Experience" win feature.
        RebootNodeIfNeeded = $true
    }

    foreach($feature in $WindowsFeatures) {
        WindowsFeature $feature {
            Ensure = "Present"
            Name = $feature
        }
    }

    Archive "SitefinityWebApp.zip"
    {
        Ensure = "Present"
        Path = "c:\cfn\packages\SitefinityWebApp.zip"
        Destination = $SfWebAppRoot
        Validate = $true
        Checksum = "SHA-256"         
    }

    cAccessControlEntry NSReadSiteRootFolder
    {
        Ensure = "Present"
        Path = $SfWebAppRoot
        AceType = "Allow"
        ObjectType = "Directory"
        AccessMask = ([System.Security.AccessControl.FileSystemRights]::ReadAndExecute)
        Principal = "NetworkService"
        DependsOn = "[Archive]SitefinityWebApp.zip"
    }
    
    cAccessControlEntry NSModifyRootFolder
    {
        Ensure = "Present"
        Path = [string]::Concat($SfWebAppRoot,"\App_Data")
        AceType = "Allow"
        ObjectType = "Directory"
        AccessMask = ([System.Security.AccessControl.FileSystemRights]::Modify)
        Principal = "NetworkService"
        DependsOn = "[Archive]SitefinityWebApp.zip"
    }

    xWebsite DefaultWebSite
    {
        Name="Default Web Site"
        PhysicalPath = "C:\inetpub\wwwroot"
        Ensure = "Absent"
        DependsOn = "[WindowsFeature]Web-Server"
    }

    Script CreateAppPool
    {
        #HACK: can't figure out a way to externally pass the app pool name for now so it is hardcoded.
        SetScript = {
            $appPoolName = "SitefinityWebApp"
            New-WebAppPool -Name $appPoolName
            $appPool = Get-Item "IIS:\AppPools\$appPoolName"
            $appPool.processModel.identityType = "NetworkService"
            $appPool.processModel.idleTimeout = [TimeSpan]::FromMinutes(0)
            $appPool.processModel.idleTimeoutAction = "Suspend"
            $appPool.recycling.periodicRestart.time = [TimeSpan]::FromMinutes(0)
            $appPool.managedPipelineMode = "Integrated"
            $appPool.managedRuntimeVersion = "v4.0"
            $appPool | Set-Item
        }
        GetScript = { <# This must return a hash table #> }
        DependsOn = "[WindowsFeature]Web-Server" 
        #HACK: hardcoded app pool name
        TestScript = 
        {
            Test-Path IIS:\AppPools\SitefinityWebApp
        }
    }

    xWebsite SfWebSite
    {
        Name = $SfWebSiteName
        ApplicationPool = $SfWebSiteName
        Ensure = "Present"
        State = "Started"
        PhysicalPath = $SfWebAppRoot
        BindingInfo = @(
                        @(MSFT_xWebBindingInformation
                        {
                            Protocol = "HTTP"
                            Port = 80
                        })
                        )
        DependsOn = @("[Script]CreateAppPool","[xWebsite]DefaultWebSite", "[Archive]SitefinityWebApp.zip")
    }
}

#Generates *.mof files.
SfWinSrv2012FeaturesIIS

#Applies Local Configuration manager state from the *.meta.mof file
Set-DscLocalConfigurationManager -Path ./SfWinSrv2012FeaturesIIS

#Applies the configurations state form the *.mof
Start-DscConfiguration -Path ./SfWinSrv2012FeaturesIIS -Wait -Verbose

