function Remove-XLDConfigurationItem
{
    <#
            .SYNOPSIS
            Deletes a configuration item.

            .PARAMETER repositoryid
            The ID of the udm.configurationItem.

            .EXAMPLE
            Remove-XDLConfigurationItem -repositoryid "Environments/Dict"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
    param(
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName )]
        [string]$RepositoryId
    )

    PROCESS {
        if (-not(Test-XLDConfigurationItem -repositoryid $repositoryid))
        {
            Write-Warning -Message ("'{0}' does not exist." -f $RepositoryId)
            return
        }

        $resource = 'repository/ci/{0}' -f $RepositoryId

        If ($PSCmdlet.ShouldProcess($RepositoryId)){
            $null = Invoke-XLDRestMethod -Resource $resource -Method Delete
        }
    }
}
