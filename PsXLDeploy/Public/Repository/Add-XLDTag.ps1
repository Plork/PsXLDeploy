function Add-XLDTag
{
    <#
            .SYNOPSIS
            Add tags to an repository item.

            .DESCRIPTION
            Add tags to an repository item by specifying a list of strings.

            .PARAMETER Name
            The Name of the repository item.

            .PARAMETER Folder
            The Folder the repository item resides in.

            .PARAMETER tags
            a list of strings containing tags.

            .EXAMPLE
            Add-XLDTag -Name WindowsHost -Tags "Tag1","Tag2"

            .EXAMPLE
            Add-XLDTag -Name WindowsHost -Folder HostFolder -Tags "Tag1","Tag2"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,
        ParameterSetName='ByName',
        ValueFromPipelineByPropertyName )]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName,
        ParameterSetName='ByName')]
        [string]$Folder,

        [Parameter(ValueFromPipelineByPropertyName,
        ParameterSetName='ById')]
        [string]$RepositoryId,

        [string[]]$Tags
    )

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Repository
        }

        if (-not(Test-ValidForTags -RepositoryId $RepositoryId))
        {
            throw  'Only Repository items and Applications support Tags!'
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId))
        {
            Throw  ("ConfigurationItem '{0}' does not exist" -f $RepositoryId)
        }

        $ConfigurationItem = (Get-XLDConfigurationItem -RepositoryId $RepositoryId)
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        If ($ConfigurationItem.$type.tags.value) {
            $TagsAdded = Compare-Object -ReferenceObject $Tags -DifferenceObject $ConfigurationItem.$type.tags.value | Where-Object { $_.SideIndicator -eq '<=' } |
            ForEach-Object  { Write-Output $_.InputObject }
        }
        else {
            $tagsAdded =  $Tags
        }
        If ($TagsAdded) {
            $ConfigurationItem = Add-Tag -ConfigurationItem $ConfigurationItem -Tags $TagsAdded -whatif:$WhatIfPreference
            $Changed = $true
        }
        If ($Changed)
        {
            $Resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $Resource -Method PUT -Body $ConfigurationItem
        }
    }
}
