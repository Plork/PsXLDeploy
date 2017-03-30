function New-XLDEnvironment
{
    <#
            .SYNOPSIS
            creates a new udm.Environment.

            .PARAMETER Name
            The Name of the environment.

            .PARAMETER Folder
            The Folder the environment resides in.

            .PARAMETER Force
            If specified creates subfolders recursively

            .EXAMPLE
            New-XLDEnvironment -environmentId "Env"

            .EXAMPLE
            New-XLDEnvironment -environmentId "Environments/Env"

            .EXAMPLE
            New-XLDEnvironment -environmentId "Environments/Folder/Env" -force

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
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

        [string[]]$Members,

        [string[]]$Dictionaries,

        [Parameter(ValueFromPipelineByPropertyName )]
        [switch]$Force
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        If (Test-XLDConfigurationItem -RepositoryId $RepositoryId)
        {
            Throw  ("Environment '{0}' already exists." -f $RepositoryId)

        }

        $DirectoryPath = Get-DirectoryPath -RepositoryId $RepositoryId

        If (-not(Test-XLDConfigurationItem -RepositoryId $DirectoryPath))
        {
            If ($Force) {
                $null = New-XLDDirectory -RepositoryId $DirectoryPath -recurse
            }
            Else {
                Throw  ("Folder '{0}' does not exist." -f $DirectoryPath)
            }
        }

        $params = @{
            RepositoryId = $RepositoryId
            Type = 'udm.Environment'
        }

        If ($PSBoundParameters.ContainsKey('Members')){
            $params.Members = $Members
        }

        If ($PSBoundParameters.ContainsKey('Dictionaries')){
            $params.Dictionaries = $Dictionaries
        }

        If ($PSCmdlet.ShouldProcess($RepositoryId)){
            $ConfigurationItem = New-ConfigurationItem @params

            $resource = 'repository/ci/{0}' -f $RepositoryId
            $Response = Invoke-XLDRestMethod -Resource $resource -Method POST -Body $ConfigurationItem

            $Hash = [ordered]@{
                RepositoryId = $RepositoryId
                Members = $Response.'udm.Environment'.members.ci.Ref
                Dictionaries = $Response.'udm.Environment'.dictionaries.ci.Ref
                Triggers = $Response.'udm.Environment'.triggers
            }

            $Result = New-Object -TypeName psobject -Property $Hash

            return $Result | Add-ObjectType -TypeName 'udm.Environment'
        }
    }
}
