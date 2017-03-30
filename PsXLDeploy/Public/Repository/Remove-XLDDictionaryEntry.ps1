function Remove-XLDDictionaryEntry
{
    <#
            .SYNOPSIS
            Remove key-value pairs from a dictionary

            .DESCRIPTION
            Remove key-value pairs from a dictionary

            .PARAMETER dictionaryId
            The ID of the new udm.Dictionary where the key-value pairs that will be added.

            .PARAMETER dictionaryKeys
            a list of dictionary keys to remove.

            .OUTPUTS
            [hashtable] with the resulting key-value pairs of the dictionary

            .EXAMPLE
            Remove-XLDDictionaryEntry -dictionaryId "Environments/dictionaries/Dict" -dictionaryKeys "Key1,Key2"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='Medium')]
    [OutputType([hashtable])]
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
        [string[]]$Entries
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId))
        {
            throw  ("ConfigurationItem '{0}' does not exist." -f $RepositoryId)
        }

        $configurationItem = Get-XLDConfigurationItem -repositoryid $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        If (-not('udm.Dictionary','udm.EncryptedDictionary' -contains $Type)) {
            throw  ("ConfigurationItem '{0}' not a dictionary" -f $RepositoryId)
        }

        $changed = $false

        Write-Verbose -Message ("Checking entries of dictionary '{0}'." -f $RepositoryId)
        ForEach ($Entry in $Entries)
        {
            $EntriesElement = ($configurationItem | Select-Xml -XPath ("//entries/*[@key='{0}']" -f $Entry)).Node
            if ($EntriesElement)
            {
                if($PSCmdlet.ShouldProcess($RepositoryId,("Remove key '{0}'." -f $Entry))){
                    $null = $EntriesElement.ParentNode.RemoveChild($EntriesElement)
                    $changed = $true
                }
            }
        }

        If ($changed) {
            $resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $resource -Method PUT -Body $ConfigurationItem
        }
    }
}
