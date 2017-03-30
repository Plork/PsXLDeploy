function Get-XLDTaskState
{
    <#
            .SYNOPSIS
            Returns a tasks state by ID..

            .PARAMETER taskId
            the ID of the task

            .EXAMPLE
            Get-XLDTaskState -taskId 4d2446d2-9574-4aa3-b0ba-011c3395d9b5

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]$taskId
    )
    BEGIN
    {
        Write-Verbose -Message ('taskId = {0}' -f $taskId)
    }
    PROCESS
    {
        $resource = ('tasks/v2/{0}' -f $taskId)
        $Response = Invoke-XLDRestMethod -Resource $resource

        return $Response.task.state
    }
}
