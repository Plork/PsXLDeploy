function Test-XLDDictionary {
    <#
            .SYNOPSIS
            Test the existance of an Dictionary.

            .PARAMETER dictionaryId
            the ID of the udm.Dictionary.

            .EXAMPLE
            Test-XLDDictionary -dictionaryId "Environments/Dict"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName )]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName')]
        [string]$Folder,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'ById')]
        [string]$RepositoryId
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        return Test-XLDConfigurationItem -repositoryid $RepositoryId
    }
}
