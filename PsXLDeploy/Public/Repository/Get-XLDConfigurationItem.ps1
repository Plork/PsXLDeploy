function Get-XLDConfigurationItem
{
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
    [OutputType([xml])]
    param(
        [Parameter(Mandatory,
                ValueFromPipeline )]
        [string]$RepositoryId
    )

    Process {

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId))
        {
            throw  ("ConfigurationItem '{0}' does not exist" -f $RepositoryId)
        }

        $Resource = 'repository/ci/{0}' -f $RepositoryId
        return Invoke-XLDRestMethod -Resource $resource -Method GET
    }
}
