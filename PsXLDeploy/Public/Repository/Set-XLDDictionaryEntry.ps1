function Set-XLDDictionaryEntry
{
    <#
            .SYNOPSIS
            Add key-value pairs to a dictionary

            .DESCRIPTION
            Add key-value pairs to an existing dictionary. If the key already exists the value will be updated.

            .PARAMETER Name
            The Name of the dictionary.

            .PARAMETER Folder
            The Folder the dictionary resides in.

            .PARAMETER Entries
            a hashtable containing key-value pairs.

            .EXAMPLE
            Add-XLDDictionaryEntry -Name "Dict" -Folder "dictionaries" -dictionaryEntries @{ key = 'value' }

            .EXAMPLE
            Add-XLDDictionaryEntry -Name "Dict" -dictionaryEntries @{ key = 'value' }

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

        [Parameter(ValueFromPipelineByPropertyName )]
        [hashtable]$Entries
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId)){
            Throw  ('ConfigurationItem {0} does not exist' -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -Repositoryid $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        If (-not('udm.Dictionary','udm.EncryptedDictionary' -contains $Type)) {
            Throw  ("ConfigurationItem '{0}' not a dictionary" -f $RepositoryId)
        }

        $Changed = $false
        $ChangedorAddedKeys = @{}

        Write-Verbose -Message ("Checking entries of dictionary '{0}'." -f $RepositoryId)
        ForEach ($Entry in $Entries.GetEnumerator()) {
            $EntryElement = ($ConfigurationItem | Select-Xml -XPath ("//entries/*[@key='{0}']" -f $Entry.key)).Node
            If (-not ($EntryElement)) {
                If($PSCmdlet.ShouldProcess($RepositoryId,("Adding key '{0}' with value '{1}'" -f $Entry.Key, $Entry.Value))){
                    Write-Verbose ("Adding key '{0}' with value '{1}'" -f $Entry.Key, $Entry.Value)
                    $EntryElement = $ConfigurationItem.CreateElement('entry')
                    $EntryElement.SetAttribute('key', $Entry.key)
                    $null = $EntryElement.AppendChild($ConfigurationItem.CreateTextNode($Entry.value))

                    $EntriesNode = $ConfigurationItem.$type.SelectSingleNode('entries')
                    $null = $EntriesNode.AppendChild($EntryElement)
                    $ChangedorAddedKeys[$entry.key] = $entry.value
                    $Changed = $true
                }
            }
            Else {
                If ($EntryElement.'#text' -cne $Entry.value) {
                    If($PSCmdlet.ShouldProcess($RepositoryId,("Setting key '{0}' to value '{1}'" -f $Entry.key, $Entry.Value))){
                        write-verbose ("Setting key '{0}' to value '{1}'" -f $Entry.key, $Entry.Value)
                        $EntryElement.'#text' = $Entry.value
                        $ChangedorAddedKeys[$entry.key] = $entry.value
                        $Changed = $true
                    }
                }
                Else {
                    Write-Verbose -Message ("Entry '{0}' of dictionary '{1}' matches." -f $Entry.Key, $RepositoryId)
                }
            }
        }

        If ($Changed) {
            $Resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $Resource -Method PUT -Body $ConfigurationItem
        }
    }
}
