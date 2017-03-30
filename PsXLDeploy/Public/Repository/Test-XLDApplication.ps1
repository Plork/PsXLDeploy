function Test-XLDApplication
{
    <#
            .SYNOPSIS
            Test the existance of an application.

            .PARAMETER ApplicationId
            the ID of the udm.Application.

            .EXAMPLE
            Test-XLDApplication -applicationId "Applications/Finance/Simple Web Project/1.0.0.2"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    [OutputType([bool])]
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

    PROCESS
    {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Applications
        }

        return Test-XLDConfigurationItem -repositoryid $RepositoryId
    }
}
