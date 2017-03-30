#requires -Version 3.0
function Add-ObjectType
{
    param(
        [Parameter(ValueFromPipeline,Mandatory)]
        [PsObject[]]$InputObject,

        [Parameter(Mandatory)]
        [string]$TypeName
    )
    process {
        $InputObject | Add-Member -MemberType NoteProperty -Name Type -Value $TypeName
        foreach ($object in $InputObject)
        {
            $object.psobject.TypeNames.Insert(0, $TypeName)
            Write-Output $object
        }
    }
}
