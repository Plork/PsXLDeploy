function New-XLDDeployment
{
    <#
            .SYNOPSIS
            Creates the deployment

            .DESCRIPTION
            Creates the deployment and returns a reference to a Task ID that can be executed by the TaskService.

            .PARAMETER deploymentPackageId
            The ID of the new udm.Version that is the source of the deployment.

            .PARAMETER environmentId
            The ID of the udm.Environment that is the target of the deployment.

            .EXAMPLE
            New-XLDDeployment -deploymentPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -EnvironmentId "Environments/Env"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]$PackageId,

        [parameter(Mandatory)]
        [string]$EnvironmentId
    )
    BEGIN
    {
        Write-Verbose -Message ('deploymentPackageId = {0}' -f $PackageId)
        Write-Verbose -Message ('EnvironmentId = {0}' -f $EnvironmentId)
    }
    PROCESS
    {

        If (-not(Test-XLDConfigurationItem -RepositoryId $EnvironmentId))
        {
            throw  ("Environment '{0}' does not exist" -f $EnvironmentId)
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $PackageId))
        {
            throw  ("Application '{0}' does not exist" -f $PackageId)
        }

        $deployment = Get-XLDDeployment -deploymentPackageId $PackageId -EnvironmentId $EnvironmentId
        $deployment = Get-XLDDeployed -deployment $deployment
        $deployment = Confirm-XLDDeployment -deployment $deployment

        return New-XLdDeploymentTask -deployment $deployment
    }
}
