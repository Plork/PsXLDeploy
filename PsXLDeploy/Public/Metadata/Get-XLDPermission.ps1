function Get-XLDPermission
{
    <#
            .SYNOPSIS
            Lists all the Permissions.

            .DESCRIPTION
            Lists all the Permissions that can be granted or revoked.

            .EXAMPLE
            Get-XLDPermissions

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()
    BEGIN {
        $resource = 'metadata/permissions'
    }
    PROCESS
    {
        $Response = Invoke-XLDRestMethod -Resource $resource

        return $Response.collection.permission
    }
}
