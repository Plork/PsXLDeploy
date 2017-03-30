function Get-XLDInitialDeploymentObject
{
    <#
            .SYNOPSIS
            Prepares an initial deployment.

            .PARAMETER deploymentPackageId
            The ID of the new udm.Version that is the source of the deployment.

            .PARAMETER environmentId
            The ID of the udm.Environment that is the target of the deployment.

            .OUTPUTS
            [xml] with a new Deployment object to which you can add deployeds.

            .EXAMPLE
            Get-XLDDeploymentObject -deployementPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -environmentId "Environments/Env"

            .LINK
            Get-XLDDeployment
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]$deploymentPackageId,

        [parameter(Mandatory)]
        [string]$environmentId
    )
    BEGIN
    {
        Write-Verbose -Message ('environmentId = {0}' -f $environmentId)
        Write-Verbose -Message ('deploymentPackageId = {0}' -f $deploymentPackageId)

        $deploymentPackageId = [uri]::EscapeDataString($deploymentPackageId)
        $deployedApplication = [uri]::EscapeDataString($deployedApplication)
    }
    PROCESS
    {
        $uriparams = @{}
        $uriparams.version = $deploymentPackageId
        $uriparams.environment = $environmentId

        return Invoke-XLDRestMethod -Resource 'deployment/prepare/initial' -UriParams $uriparams
    }
}
