function Get-XLDDeployed
{
    <#
            .SYNOPSIS
            Prepares all the deployeds for the given deployment.

            .DESCRIPTION
            Prepares all the deployeds for the given deployment. This will keep any previous deployeds present in the deployment object that are already present, unless they cannot be deployed with regards to their tags. It will add all the deployeds that are still missing.
            Also filters out the deployeds that do not have any source attached anymore (deployables that were previously present).

            .PARAMETER Deployment
            The prepared Deployment parameter object

            .OUTPUTS
            [xml] with an updated Deployment parameter object.

            .EXAMPLE
            $deployment = Get-XLDDeployment -deploymentPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -EnvironmentId "Environments/Env"
            Get-XLDDeployed -deployment $deployment

            .EXAMPLE
            Get-XLDDeployment -deploymentPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -EnvironmentId "Environments/Env" | Get-XLDDeployed

            .LINK
            Confirm-XLDDeployment
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [Parameter(Mandatory,
        ValueFromPipeline)]
        [xml]$deployment
    )
    BEGIN
    {
        Write-Verbose -Message ('deployment = {0}' -f $deployment.OuterXml)
    }
    PROCESS
    {
        return Invoke-XLDRestMethod -Resource 'deployment/prepare/deployeds' -Method Post -Body $deployment
    }
}
