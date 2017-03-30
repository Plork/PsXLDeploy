function Get-XLDOrchestrator
{
    <#
            .SYNOPSIS
            Lists all the Orchestrator names.

            .DESCRIPTION
            Lists all the Orchestrator names that can be used to orchestrate a Deployment done by the DeploymentService .

            .EXAMPLE
            Get-XLDOrchestrator

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()
    BEGIN {
        $resource = 'metadata/orchestrators'
    }
    PROCESS
    {
        $Response = Invoke-XLDRestMethod -Resource $resource

        return $Response.list.string
    }
}
