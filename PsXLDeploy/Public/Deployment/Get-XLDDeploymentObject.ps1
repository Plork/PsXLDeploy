function Get-XLDDeploymentObject
{
    <#
            .SYNOPSIS
            Prepares an update deployment.

            .PARAMETER deploymentPackageId
            The ID of the new udm.Version that is the source of the deployment.

            .PARAMETER deployedApplication
            The ID of the udm.DeployedApplication that is to be updated.

            .OUTPUTS
            [xml] with a new Deployment object which contains the updated deployeds.

            .EXAMPLE
            Get-XLDDeploymentObject -deployementPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -deployedApplication "Environments/Env/Applications/Finance/Simple Web Project"

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
        [string]$deployedApplication
    )
    BEGIN
    {
        Write-Verbose -Message ('deployedApplication = {0}' -f $deployedApplication)
        Write-Verbose -Message ('deploymentPackageId = {0}' -f $deploymentPackageId)

        $deploymentPackageId = [uri]::EscapeDataString($deploymentPackageId)
        $deployedApplication = [uri]::EscapeDataString($deployedApplication)
    }
    PROCESS
    {
        $uriparams = @{}
        $uriparams.version = $deploymentPackageId
        $uriparams.deployedApplication = $deployedApplication

        return Invoke-XLDRestMethod -Resource 'deployment/prepare/update' -UriParams $uriparams
    }
}
