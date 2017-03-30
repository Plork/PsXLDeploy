function Add-XLDDictionaryRestrict
{
    <#
            .SYNOPSIS
            Restrict applications or Containers to dictionary

            .DESCRIPTION
            Restrict applications or/and Containers to a dictionary by specifying a list of strings with the RepositoryId's.

            .PARAMETER Name
            The Name of the dictionary.

            .PARAMETER Folder
            The Folder the dictionary resides in.

            .PARAMETER restrictToContainers
            a list of strings containing Id's of udm.Containers.

            .PARAMETER restrictToApplications
            a list of strings containing Id's of udm.Applications.

            .EXAMPLE
            Add-XLDDictionaryRestrict -Name "Dict" -Folder "dictionaries" -Containers "Infrastructure/Host1","Infrastructure/Host2"

            .EXAMPLE
            Add-XLDDictionaryRestrict --Name "Dict" -applications "Applications/Finance/Simple Web Project"

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
        [switch]$Encrypted,

        [Parameter(ValueFromPipelineByPropertyName )]
        [string[]]$restrictToContainers,

        [Parameter(ValueFromPipelineByPropertyName )]
        [string[]]$restrictToApplications
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId))
        {
            throw  ("ConfigurationItem '{0}' does not exist" -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -RepositoryId $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        If (-not('udm.Dictionary','udm.EncryptedDictionary' -contains $Type)) {
            throw  ("ConfigurationItem '{0}' not a dictionary" -f $RepositoryId)
        }

        $Changed = $false

        Write-Verbose -Message ("Checking restricts of dictionary '{0}'." -f $RepositoryId)
        ForEach ($restrictedContainer in $restrictToContainers)
        {
            $RestrictToContainersElement = $ConfigurationItem | Select-Xml -XPath ("//restrictToContainers/*[@ref='{0}']" -f $restrictedContainer)
            if (-not ($RestrictToContainersElement))
            {
                if($PSCmdlet.ShouldProcess($RepositoryId,("Add restrict '{0}'." -f $restrictedContainer))){
                    $RestrictToContainersElement = $configurationItem.CreateElement('ci')
                    $RestrictToContainersElement.SetAttribute('ref', $restrictedContainer)
                    $RestrictToContainersNode = $ConfigurationItem.$Type.SelectSingleNode('restrictToContainers')
                    $null = $RestrictToContainersNode.AppendChild($RestrictToContainersElement)
                    $Changed = $true
                }
            }
            Else
            {
                Write-Verbose -Message ("'{0}' already restricted to '{1}'." -f $restrictedContainer, $RepositoryId)
            }
        }

        ForEach ($restrictedApplication in $restrictToApplications)
        {
            $RestrictToApplicationsElement = $ConfigurationItem | Select-Xml -XPath ("//restrictToApplications/*[@ref='{0}']" -f $restrictedApplication)
            if (-not ($RestrictToApplicationsElement))
            {
                if($PSCmdlet.ShouldProcess($RepositoryId,("Add restrict '{0}'." -f $restrictedApplication))){
                    $RestrictToApplicationsElement = $configurationItem.CreateElement('ci')
                    $RestrictToApplicationsElement.SetAttribute('ref', $restrictedApplication)
                    $RestrictToApplicationsNode = $ConfigurationItem.$Type.SelectSingleNode('restrictToApplications')
                    $null = $RestrictToApplicationsNode.AppendChild($RestrictToApplicationsElement)
                    $Changed = $true
                }
            }
            Else
            {
                Write-Verbose -Message ("'{0}' already restricted to '{1}'." -f $restrictedApplication, $RepositoryId)
            }
        }

        If ($Changed) {
            $Resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $Resource -Method PUT -Body $ConfigurationItem
        }
    }
}
