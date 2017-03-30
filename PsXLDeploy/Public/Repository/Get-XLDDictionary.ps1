function Get-XLDDictionary {
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
            Get-XLDConfigurationItem -repositoryid "Environments/Dict"

            .EXAMPLE
            Get-XLDConfigurationItem -repositoryid "Environments/Env"

            .EXAMPLE
            Get-XLDConfigurationItem -repositoryid "Infrastructure/Host"

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

    if ($Type -notin ('udm.Dictionary','udm.EncryptedDictionary')) {
        throw  "ConfigurationItem not a dictionary"
    }

    if ($ConfigurationItem.$Type.entries.entry) {
        $EntriesHash = @{}
        $ConfigurationItem.$Type.entries.entry | ForEach-Object {
            $EntriesHash[$_.key] = $_.'#text'
        }
    }

    $Hash = [ordered]@{
        RepositoryId = $RepositoryId
        Entries = $EntriesHash
        restrictToContainers   = $ConfigurationItem.$Type.restrictToContainers.ci | Select-Object -ExpandProperty ref
        restrictToApplications = $ConfigurationItem.$Type.restrictToApplications.ci | Select-Object -ExpandProperty ref
    }

    $Result = New-Object -TypeName psobject -Property $Hash

    return $Result | Add-ObjectType -TypeName $Type

}
