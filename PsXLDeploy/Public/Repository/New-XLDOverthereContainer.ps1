function New-XLDOverthereContainer {
    <#
            .SYNOPSIS
            creates a new overthereContainer.

            .PARAMETER Name
            The Name of the new overthereContainer.

            .PARAMETER overthereHostId
            If specified creates subfolders recursively

            .PARAMETER tags
            If set, only deployables with the same tag will be automatically mapped to this container.

            .EXAMPLE
            New-XLDDirectory -RepositoryId "Environments/Folder"

            .EXAMPLE
            New-XLDDirectory -RepositoryId "Infrastructure/Folder/Folder" -recurse

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName )]
        [string]$Name,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName )]
        [string]$overthereHostId,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName )]
        [string[]]$tags,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName )]
        [string]$deploymentGroup,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName )]
        [string]$deploymentSubGroup,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName )]
        [string]$deploymentSubSubGroup,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [ValidateSet('iis.Server', 'chef.Solo')]
        [string]$type
    )

    PROCESS {
        $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $overthereHostId -Type Repository
        If (-not $whatifpreference) {
            If (-not(Test-XLDConfigurationItem -RepositoryId $overthereHostId)) {
                Throw  ("Host '{0}' does not exist" -f $overthereHostId)
            }

            If (Test-XLDConfigurationItem -RepositoryId $RepositoryId) {
                Throw  ("Container '{0}' already exists" -f $RepositoryId)
            }
        }

        $RepositoryId = Get-EncodedPathPart -PartialPath $RepositoryId

        $Params = @{
            RepositoryId = $RepositoryId
        }

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

        $NotNeededParams = 'Name'

        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        ForEach ($key in $ParameterList.keys) {
            $var = Get-Variable -Name $key -ErrorAction SilentlyContinue
            if (-not ([String]::IsNullOrEmpty($var.Value)) -and ($key -notin ($Commons + $NotNeededParams))) {
                $params.Add($key, $var.Value)
            }
        }

        $ConfigurationItem = New-ConfigurationItem  @params
        If ($PSCmdlet.ShouldProcess($RepositoryId)) {
            $resource = 'repository/ci/{0}' -f $RepositoryId
            $Response = Invoke-XLDRestMethod -Resource $resource -Method POST -Body $ConfigurationItem

            $Hash = [ordered]@{
                RepositoryId = $RepositoryId
                Type = $Type
                OverthereHostId = $Response.$Type.Host.Ref
                Tags = $Response.$Type.Tags.Value
                DeploymentGroup = [int]$Response.$Type.deploymentGroup
                DeploymentSubGroup = [int]$Response.$Type.deploymentSubGroup
                DeploymentSubSubGroup = [int]$Response.$Type.deploymentSubSubGroup
            }

            $Result = New-Object -TypeName psobject -Property $Hash
            return $Result
        }
    }
}
