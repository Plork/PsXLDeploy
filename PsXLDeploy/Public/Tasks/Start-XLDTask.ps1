function Start-XLDTask
{
    <#
            .SYNOPSIS
            Start a task  by ID..

            .PARAMETER taskId
            the ID of the task

            .EXAMPLE
            Start-XLDTask -taskId 4d2446d2-9574-4aa3-b0ba-011c3395d9b5

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
        $resource = ('tasks/v2/{0}/start' -f $taskId)

        return Invoke-XLDRestMethod -Resource $resource -Method Post
    }
}
