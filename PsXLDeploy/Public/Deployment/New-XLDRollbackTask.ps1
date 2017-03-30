function New-XLDRollbackTask
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]$taskId
    )
    BEGIN
    {
        Write-Verbose -Message ('taskId = {0}' -f $taskId)
        $taskId = Get-EncodedPathPart -PartialPath $taskId
    }
    PROCESS
    {
        $resource = ('deployment/rollback/{0}' -f $taskId)

        return Invoke-XLDRestMethod -Resource $resource -Method Post
    }
}
