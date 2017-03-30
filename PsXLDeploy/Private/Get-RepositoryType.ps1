#requires -Version 3.0
function Get-RepositoryType
{
    Param(
        [Parameter(ValueFromPipeline,Mandatory)]
        [xml]$ConfigurationItem
    )

    PROCESS {

    $Type = $ConfigurationItem | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
    Write-Output $Type

    }
}
