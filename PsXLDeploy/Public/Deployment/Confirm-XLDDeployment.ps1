function Confirm-XLDDeployment
{
    <#
            .SYNOPSIS
            Validates the generated deployment.

            .DESCRIPTION
            Validates the generated deployment. Checks whether all the deployeds that are in the
            deployment are valid.

            .PARAMETER Deployment
            The deployment to validate.

            .OUTPUTS
            [xml] with the validated configuration items, including any validation messages.

            .EXAMPLE
            $deployment = Get-XLDDeployment -deploymentPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -EnvironmentId "Environments/Env"
            $deployment = Get-XLDDeployed -deployment $deployment
            Confirm-XLDDeployment -deployment $deployment

            .EXAMPLE
            Get-XLDDeployment -deploymentPackageId "Applications/Finance/Simple Web Project/1.0.0.2" -EnvironmentId "Environments/Env" | Get-XLDDeployed | Confirm-XLDDeployment

            .LINK
            New-XLDDeployment
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
        return Invoke-XLDRestMethod -Resource 'deployment/validate' -Method Post -Body $deployment
    }
}
