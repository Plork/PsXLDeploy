function Test-TaskRunning
{
    param
    (
        [parameter(Mandatory)]
        [string]$taskState
    )

    Write-Verbose -Message ('Current task state is {0}' -f $taskState)

    $runningStates = 'QUEUED', 'EXECUTING', 'ABORTING', 'STOPPING', 'FAILING', 'PENDING'

    foreach($state in $runningStates)
    {
        If ($taskState -eq $state)
        {
            return $true
        }
    }
    return $false
}
