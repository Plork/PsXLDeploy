function Remove-XLDTag {
    <#
            .SYNOPSIS
            Add tags to an overthereHost.

            .DESCRIPTION
            Add tags to an overthereHost by specifying a list of strings.

            .PARAMETER overthereHostid
            The ID of the udm.Container.

            .PARAMETER tags
            a list of strings containing tags.

            .OUTPUTS
            [hashtable] with the overthereHost and the updated tags is returned.

            .EXAMPLE
            Add-XLDEnvironmentMember -environmentId "Environments/Env" -containers "Infrastructure/Host1,Infrastructure/Host2"

            .EXAMPLE
            Add-XLDEnvironmentMember -environmentId "Environments/Env" -dictionaries "Environments/dictionaries/Dict1,Environments/dictionaries/Dict2"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='Medium')]
    [OutputType([object])]
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

        if (-not(Test-ValidForTags -RepositoryId $RepositoryId)) {
            throw  'Only Repository items and Applications support Tags!'
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId)) {
            Throw  ("ConfigurationItem '{0}' does not exist." -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -repositoryid $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        $TagsRemoved = @()
        If ($ConfigurationItem.$type.tags.Value) {
            ForEach ($Tag in $Tags) {
                If ($Tag -in $ConfigurationItem.$type.tags.Value) {
                    $TagsRemoved += $Tag
                }
            }
            If ($TagsRemoved) {
                $ConfigurationItem = Remove-Tag -ConfigurationItem $ConfigurationItem -Tags $TagsRemoved -whatif:$WhatIfPreference
                $Changed = $true
            }
        }
        If ($Changed) {
            $Resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $Resource -Method PUT -Body $ConfigurationItem
        }
    }
}
