function Wait-XLDTask
{
    <#
            .SYNOPSIS
            Wait for a task to complete.

            .PARAMETER taskId
            the ID of the task

            .EXAMPLE
            Wait-XLDTask -taskId 4d2446d2-9574-4aa3-b0ba-011c3395d9b5

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
        $taskState = Get-XLDTaskState -taskId $taskId
        while (Test-TaskRunning -taskState $taskState )
        {
            Start-Sleep -Seconds 5
            $taskState = Get-XLDTaskState -taskId $taskId
        }

        return $taskState
    }
}
