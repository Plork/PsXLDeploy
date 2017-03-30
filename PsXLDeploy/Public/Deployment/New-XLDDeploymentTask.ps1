function New-XLDDeploymentTask
{
    <#
            .SYNOPSIS
            Creates the deployment task

            .DESCRIPTION
            Creates the deployment task and returns a reference to a Task ID that can be executed by the TaskService.

            .PARAMETER deployment
            The fully prepared Deployment parameter object.

            .EXAMPLE
            New-XLdDeploymentTask -deployment $deployment

            .LINK
            New-XLDDeployment
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [xml]$deployment
    )

    PROCESS
    {
        return Invoke-XLDRestMethod -Resource 'deployment' -Method Post -Body $deployment
    }
}
