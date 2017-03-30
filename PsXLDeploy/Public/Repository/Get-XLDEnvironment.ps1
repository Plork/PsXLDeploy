function Get-XLDEnvironment {
    <#
            .SYNOPSIS
            Reads a configuration item from the repository.

            .DESCRIPTION
            Reads a configuration item from the repository by specifying the repositoryid of the ConfigurationItem.

            .PARAMETER repositoryid
            The ID of the new udm.ConfigurationItem.

            .OUTPUTS
            [XML] with the CI, or a 404 error code If not found.

            .EXAMPLE
            Get-XLDEnvironment -repositoryid "Environments/Dict"

            .EXAMPLE
            Get-XLDEnvironment -repositoryid "Environments/Env"

            .EXAMPLE
            Get-XLDEnvironment -repositoryid "Infrastructure/Host"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,
            ParameterSetName='ByName')]
        [string]$Name,

        [Parameter(ParameterSetName='ByName')]
        [string]$Folder,

        [Parameter(Mandatory,
            ParameterSetName='ById')]
        [string]$RepositoryId
    )

    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
    }

    $ConfigurationItem = Get-XLDConfigurationItem -repositoryid $RepositoryId
    $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

    if ($Type -ne 'udm.Environment') {
        throw  "ConfigurationItem not an environment"
    }

    $Hash = [ordered]@{
        RepositoryId  = $RepositoryId
        Members  = $ConfigurationItem.$Type.members.ci | Select-Object -ExpandProperty ref
        Dictionaries = $ConfigurationItem.$Type.dictionaries.ci | Select-Object -ExpandProperty ref
    }

    $Result = New-Object -TypeName psobject -Property $Hash

    return $Result | Add-ObjectType -TypeName $Type

}
