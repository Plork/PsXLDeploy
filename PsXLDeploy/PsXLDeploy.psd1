#
# Module manifest for 'PsXLDeploy' module
# Created by: Marcel Bezemer <marcel@beestig.nl>
# Generated on: 10/04/2016
#

@{

RootModule = 'PsXLDeploy.psm1'

ModuleVersion = '0.0.9.1'

GUID = '85aaff1a-c696-43ad-be1a-53d16477d014'

Author = 'Marcel Bezemer'

Copyright = 'All rights reserved.'

Description = 'PowerShell helper module for XLD REST services.'

FunctionsToExport = "*"

FormatsToProcess = 'PsXLDeploy.format.ps1xml'

PrivateData = @{

    PSData = @{

        Tags = @(
            'XLD'
            'REST'
            'API'
        )

        LicenseUri = 'https://github.com/Plork/PsXLDeploy/src/master/LICENSE'

        ProjectUri = 'https://github.com/Plork/PsXLDeploy'


    } # End of PSData hashtable

} # End of PrivateData hashtable

HelpInfoURI = 'https://github.com/Plork/PsXLDeploy'

}
