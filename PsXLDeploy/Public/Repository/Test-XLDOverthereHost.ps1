function Test-XLDOverthereHost
{
    <#
            .SYNOPSIS
            Test the existance of an overthereHost.

            .PARAMETER overthereHostId
            the ID of the udm.Container.

            .EXAMPLE
            Test-XLDOverthereHost -overthereHostId "Infrastructure/Windowshost"

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
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Repository
        }

        return Test-XLDConfigurationItem -repositoryid $RepositoryId
    }
}
