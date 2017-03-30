function Import-XLDPackage {
    <#
            .SYNOPSIS
            Imports an application package.

            .DESCRIPTION
            Imports an application package that is present in the importablePackages directory on the XL Deploy Server.

            .EXAMPLE
            Import-XLDPackage -PackageId PetClinic-ear/1.0

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param(
        [string]$PackageId
    )
    BEGIN {
        $Resource = 'package/import/{0}' -f $PackageId
    }
    PROCESS {

        If (Test-XLDApplication -RepositoryId $PackageId) {
            Throw  ('Application {0} already exists' -f $PackageId)
        }

        $Response = Invoke-XLDRestMethod -Resource $Resource -Method POST
        $Type = Get-RepositoryType -ConfigurationItem $Response

        return $Response.$Type
    }
}
