function Test-XLDEnvironment
{
    <#
            .SYNOPSIS
            Test the existance of an Environment.

            .PARAMETER environmentId
            the ID of the udm.Environment.

            .EXAMPLE
            Test-XLDEnvironment -environmentId "Environments/Env"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,
        ParameterSetName='ByName',
        ValueFromPipelineByPropertyName )]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName,
        ParameterSetName='ByName')]
        [string]$Folder,

        [Parameter(ValueFromPipelineByPropertyName,
        ParameterSetName='ById')]
        [string]$RepositoryId
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        return Test-XLDConfigurationItem -repositoryid $RepositoryId
    }
}
