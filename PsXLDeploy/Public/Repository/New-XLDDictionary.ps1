function New-XLDDictionary {
    <#
            .SYNOPSIS
            creates a new udm.Dictionary.

            .PARAMETER Name
            The Name of the dictionary.

            .PARAMETER Folder
            The Folder the dictionary resides in.

            .PARAMETER Encrypted
            enable creation of an udm.EncryptedDictionary

            .PARAMETER Entries
            a hashtable containing key-value pairs.

            .PARAMETER restrictToContainers
            a list of strings containing Id's of udm.Containers.

            .PARAMETER restrictToApplications
            a list of strings containing Id's of udm.Applications.

            .PARAMETER Force
            If specified creates subfolders recursively

            .EXAMPLE
            New-XLDDictionary -dictionaryId "Environments/Dict"

            .EXAMPLE
            New-XLDDictionary -dictionaryId "Environments/EncryptedDict" -encrypted

            .EXAMPLE
            New-XLDDictionary -dictionaryId "Environments/Folder/Dict" -force

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,
            ParameterSetName='ByName')]
        [string]$Name,

        [Parameter(ParameterSetName='ByName')]
        [string]$Folder,

        [Parameter(Mandatory,
            ParameterSetName='ById')]
        [string]$RepositoryId,

        [switch]$Encrypted,

        [switch]$Force,

        [hashtable]$Entries,

        [string[]]$RestrictToContainers,

        [string[]]$RestrictToApplications
    )

    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
    }

    if (Test-XLDConfigurationItem -RepositoryId $RepositoryId) {
        throw  ("ConfigurationItem '{0}' already exists" -f $RepositoryId)
    }

    $DirectoryPath = Get-DirectoryPath -RepositoryId $RepositoryId

    if (-not (Test-XLDConfigurationItem -RepositoryId $DirectoryPath)) {
        if ($Force) {
            $null = New-XLDDirectory -RepositoryId $DirectoryPath -Recurse -whatif:$whatifPreference
        }
        else {
            Throw  ("Folder '{0}' does not exist." -f $DirectoryPath)
        }
    }

    if ($Encrypted) {
        $Type = 'udm.EncryptedDictionary'
    }
    else {
        $Type = 'udm.Dictionary'
    }

    $Params = @{
        RepositoryId = $RepositoryId
        Type = $Type
    }

    if ($PSBoundParameters.ContainsKey('Entries')){
        $Params.Entries = $Entries
    }

    if ($PSBoundParameters.ContainsKey('RestrictToContainers')){
        $Params.RestrictToContainers = $RestrictToContainers
    }

    if ($PSBoundParameters.ContainsKey('RestrictToApplications')){
        $Params.RestrictToApplications = $RestrictToApplications
    }

    if ($PSCmdlet.ShouldProcess($RepositoryId)){

        $ConfigurationItem = New-ConfigurationItem @Params

        $Resource = 'repository/ci/{0}' -f $RepositoryId
        $Response = Invoke-XLDRestMethod -Resource $Resource -Method POST -Body $configurationItem

        if ($response.$Type.entries.entry) {
            $entriesHash = @{}
            $response.$Type.entries.entry | ForEach-Object {
                $entriesHash[$_.key] = $_.'#text'
            }
        }

        $Hash = [ordered]@{
            RepositoryId = $RepositoryId
            Entries = $entriesHash
            RestrictToContainers   = $response.$Type.restrictToContainers.ci | Select-Object -ExpandProperty ref
            RestrictToApplications = $response.$Type.restrictToApplications.ci | Select-Object -ExpandProperty ref
        }

        $Result = New-Object -TypeName psobject -Property $Hash

        return $Result | Add-ObjectType -TypeName $Type
    }
}
