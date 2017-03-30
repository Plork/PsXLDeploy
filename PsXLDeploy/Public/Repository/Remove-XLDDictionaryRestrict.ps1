function Remove-XLDDictionaryRestrict
{
    <#
            .SYNOPSIS
            Remove restricts from an dictionary

            .DESCRIPTION
            Remove restricted dictionaries or applications from an dictionary

            .PARAMETER dictionaryId
            The ID of the udm.Dictionary.

            .PARAMETER containers
            a list of strings containing Id's of udm.Containers.

            .PARAMETER applications
            a list of strings containing Id's of udm.Applications.

            .OUTPUTS
            [hashtable] with the dictionary and the updated CI's is returned.

            .EXAMPLE
            Remove-XLDDictionaryRestrict -dictionaryId "Environments/dictionaries/Dict" -containers "Infrastructure/Host1,Infrastructure/Host2"

            .EXAMPLE
            Remove-XLDDictionaryRestrict -dictionaryId "Environments/dictionaries/Dict" -applications "Applications/Finance/Simple Web Project"

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

        [Parameter(ValueFromPipelineByPropertyName )]
        [switch]$Encrypted,

        [Parameter(ValueFromPipelineByPropertyName )]
        [string[]]$Containers,

        [Parameter(ValueFromPipelineByPropertyName )]
        [string[]]$Applications
    )

    BEGIN {}
    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId))
        {
            throw  ("ConfigurationItem '{0}' does not exist." -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -RepositoryId $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        If (-not('udm.Dictionary','udm.EncryptedDictionary' -contains $Type)) {
            throw  ("ConfigurationItem '{0}' not a dictionary" -f $RepositoryId)
        }

        $Changed = $false

        Write-Verbose -Message ("Checking restricts of dictionary '{0}'." -f $RepositoryId)
        ForEach ($Container in $Containers)
        {
            $restrictToContainersElement = ($ConfigurationItem | Select-Xml -XPath ("//*/restrictToContainers/*[@ref='{0}']" -f $Container)).node
            If ($restrictToContainersElement)
            {
                If($PSCmdlet.ShouldProcess($RepositoryId,("Remove restrict '{0}'." -f $Container))){
                $null = $restrictToContainersElement.ParentNode.RemoveChild($restrictToContainersElement)
                    $Changed = $true
                }
            }
            Else
            {
                Write-Verbose -Message ("'{0}' not restricted to '{1}'." -f $Container, $RepositoryId)
            }
        }

        ForEach ($Application in $Applications)
        {
            $restrictToApplicationsElement = ($ConfigurationItem | Select-Xml -XPath ("//*/restrictToApplications/*[@ref='{0}']" -f $Application)).node
            If ($restrictToApplicationsElement)
            {
                If($PSCmdlet.ShouldProcess($RepositoryId,("Remove restrict '{0}'." -f $Application))){
                    $null = $restrictToApplicationsElement.ParentNode.RemoveChild($restrictToApplicationsElement)
                    $Changed = $true
                }
            }
            Else
            {
                Write-Verbose -Message ("'{0}' not restricted to '{1}'." -f $Application, $RepositoryId)
            }
        }

        If ($Changed)
        {
            $Resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $Resource -Method PUT -Body $ConfigurationItem
        }
    }
}
