function Set-XLDOverthereContainer {
    <#
            .SYNOPSIS
            Updates an udm.Container.

            .DESCRIPTION
            Updates the properties of an udm.Container.

            .PARAMETER RepositoryId
            The ID of the new udm.Container.

            .PARAMETER Force
            If specified creates subfolders recursively

            .PARAMETER type
            The type of overthereContainer.

            .PARAMETER tags
            If set, only deployables with the same tag will be automatically mapped to this container.

            .EXAMPLE
            Set-XLDOverthereHost -overthereHostid Infrastructure/Unixhost -type overthere.SshHost -address 1.1.1.2

            .EXAMPLE
            Set-XLDOverthereHost -overthereHostid Infrastructure/Windowshost -type overthere.CifsHost -address 1.1.1.2

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName )]
        [string]$RepositoryId,

        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName )]
        [string[]]$tags,

        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName )]
        [string]$deploymentGroup,

        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName )]
        [string]$deploymentSubGroup,

        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName )]
        [string]$deploymentSubSubGroup,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [ValidateSet('iis.Server','chef.Solo')]
        [string]$type
    )

    PROCESS {

        $Commons = 'Debug',
        'ErrorAction',
        'ErrorVariable',
        'OutVariable',
        'OutBuffer',
        'Verbose',
        'WarningAction',
        'WarningVariable',
        'Confirm',
        'WhatIf',
        'UseTransaction',
        'InformationAction',
        'InformationVariable',
        'PipelineVariable'

        $NotNeededParams = 'RepositoryId',
        'Type'

        $OverthereContainerParams = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        ForEach ($key in $ParameterList.keys) {
            $var = Get-Variable -Name $key -ErrorAction SilentlyContinue
            if (-not ([String]::IsNullOrEmpty($var.Value)) -and ($key -notin ($Commons + $NotNeededParams))) {
                $OverthereContainerParams.Add($key, $var.Value)
            }
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId)) {
            Throw  ("Container '{0}' does not exists" -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -repositoryid $RepositoryId

        $Changed = $false
        ForEach($OverthereContainerParameter in $OverthereContainerParams.GetEnumerator()) {
            If (-not ($OverthereContainerParameter.key -eq 'tags')) {
                If ($ConfigurationItem.$type.($OverthereContainerParameter.key) -cne $OverthereContainerParameter.value) {
                    If ($PSCmdlet.ShouldProcess($RepositoryId, "Setting $($OverthereContainerParameter.key) to $($OverthereContainerParameter.value)")){
                        $ConfigurationItem.$type.($OverthereContainerParameter.key) = ($OverthereContainerParameter.value).toString()
                        $Changed = $true
                    }
                }
            }
            ElseIf ($OverthereContainerParameter.key -eq 'tags') {

                If ($ConfigurationItem.$type.tags.value) {
                    $TagsRemoved = Compare-Object -ReferenceObject $OverthereContainerParameter.value -DifferenceObject $ConfigurationItem.$type.tags.value | Where-Object { $_.SideIndicator -eq '=>' } |
                        ForEach-Object  { Write-Output $_.InputObject }
                    If ($TagsRemoved) {
                        $ConfigurationItem = Remove-Tag -ConfigurationItem $ConfigurationItem -Tags $TagsRemoved -whatif:$WhatIfPreference
                        $Changed = $true
                    }
                }

                If ($ConfigurationItem.$type.tags.value) {
                    $TagsAdded = Compare-Object -ReferenceObject $OverthereContainerParameter.value -DifferenceObject $ConfigurationItem.$type.tags.value | Where-Object { $_.SideIndicator -eq '<=' } |
                    ForEach-Object  { Write-Output $_.InputObject }
                }
                else {
                    $tagsAdded =  $OverthereContainerParameter.value
                }
                If ($TagsAdded) {
                    $ConfigurationItem = Add-Tag -ConfigurationItem $ConfigurationItem -Tags $TagsAdded -whatif:$WhatIfPreference
                    $Changed = $true
                }
            }
        }

        If ($changed) {
            $resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $resource -Method PUT -Body $ConfigurationItem
        }
    }
}
