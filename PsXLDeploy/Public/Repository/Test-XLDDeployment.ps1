function Test-XLDDeployment {
    <#
            .SYNOPSIS
            Test the existance of a Deployment.

            .PARAMETER EnvironmentId
            the ID of the udm.Environment.

            .PARAMETER ApplicationId
            the ID of the udm.Application.

            .EXAMPLE
            Test-XLDDeployment -environmentId "Environments/Env" -ApplicationId "Applications/Finance/Simple Web Project/1.0.0.2"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [parameter(Mandatory)]
        [string]$EnvironmentId,

        [parameter(Mandatory)]
        [string]$ApplicationId
    )
    BEGIN {
        Write-Verbose -Message ('Environment = {0}' -f $EnvironmentId)
        Write-Verbose -Message ('Application = {0}' -f $ApplicationId)

        If (-not ($EnvironmentId.StartsWith('Environments', 'InvariantCultureIgnoreCase'))) {
            $EnvironmentId = 'Environments/{0}' -f $EnvironmentId
        }

        If (-not ($ApplicationId.StartsWith('Applications/', 'InvariantCultureIgnoreCase'))) {
            $ApplicationId = 'Applications/{0}' -f $ApplicationId
        }

        $RepositoryId = Get-EncodedPathPart -PartialPath ('{0}/{1}' -f $EnvironmentId, $ApplicationId)
    }
    PROCESS {
        $resource = ('repository/exists/{0}' -f $RepositoryId)
        $Response = Invoke-XLDRestMethod -Resource $resource

        Write-Verbose -Message ('Deployment {0} exists: {1}' -f $repositoryid, $response.boolean)

        return [bool]::Parse($Response.boolean)
    }
}
