function Get-XLDDeployment
{
    <#
            .SYNOPSIS
            Prepares an update deployment.

            .DESCRIPTION
            Prepares an update deployment. Checks If the initial or update deployments are necessary, and prepares the
            given deployment.

            .PARAMETER deploymentPackageId
            The ID of the udm.Version that is the source of the deployment.

            .PARAMETER targetEnvironment
            The ID of the udm.Environment that is the target of the deployment.

            .OUTPUTS
            [xml] with a Deployment parameter object.

            .EXAMPLE
            Get-XLDDeployment -deploymentPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -EnvironmentId "Environments/Env"

            .LINK
            Get-XLDDeployed
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]$deploymentPackageId,

        [parameter(Mandatory)]
        [string]$EnvironmentId
    )
    BEGIN
    {
        Write-Verbose -Message ('deploymentPackageId = {0}' -f $deploymentPackageId)
        Write-Verbose -Message ('EnvironmentId = {0}' -f $EnvironmentId)
    }
    PROCESS {
        # Extract application name from deployment Package Id
        # as we expect a value like "Applications/Finance/Simple Web Project/1.0.0.2"
        $path = $deploymentPackageId.Split('/')
        $applicationName = $path[$path.Count - 2]
        $version = $path[$path.Count - 1]

        Write-Verbose -Message ('applicationName = {0}' -f $applicationName)
        Write-Verbose -Message ('version = {0}' -f $version)

        If (Test-XLDDeployment -EnvironmentId $EnvironmentId -ApplicationId $applicationName)
        {
            return Get-XLDDeploymentObject -deployementPackageId $deploymentPackageId -deployedApplication ('{0}/{1}' -f $EnvironmentId, $applicationName)
        }

        return Get-XLDInitialDeploymentObject -deploymentPackageId $deploymentPackageId -environmentId $EnvironmentId
    }
}
