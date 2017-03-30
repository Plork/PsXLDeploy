function Test-XLDConfigurationItem {
    <#
            .SYNOPSIS
            Test the existance of an configurationItem.

            .PARAMETER repositoryid
            the ID of the configurationItem.

            .EXAMPLE
            Test-XLDconfigurationItem -repositoryid "Infrastructure/Windowshost"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory)]
        [string]$RepositoryId
    )
    BEGIN {
        Write-Verbose -Message ('repositoryid = {0}' -f $RepositoryId)
        $RepositoryId = Get-EncodedPathPart -PartialPath $RepositoryId
    }
    PROCESS {
        $resource = 'repository/exists/{0}' -f $RepositoryId
        $Response = Invoke-XLDRestMethod -Resource $resource

        Write-Verbose -Message ('Configuration item {0} exists: {1}' -f $repositoryid, $response.boolean)

        return [bool]::Parse($Response.boolean)
    }
}
