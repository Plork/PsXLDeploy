function Add-XLDEnvironmentMember
{
    <#
            .SYNOPSIS
            Add containers or dictionaries to an environment.

            .DESCRIPTION
            Add containers or dictionaries to an environment by specifying a list of strings with the repositoryId's.

            .PARAMETER Name
            The Name of the environment.

            .PARAMETER Folder
            The Folder the environment resides in.

            .PARAMETER members
            a list of strings containing Id's of udm.Containers.

            .PARAMETER dictionaries
            a list of strings containing Id's of udm.Dictionaries.

            .EXAMPLE
            Add-XLDEnvironmentMember -Name "Env" -containers "Infrastructure/Host1","Infrastructure/Host2"

            .EXAMPLE
            Add-XLDEnvironmentMember -Name "Env" -Folder "EnvFolder" -dictionaries "Environments/dictionaries/Dict1","Environments/dictionaries/Dict2"

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

        [array]$Members,

        [array]$Dictionaries
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId))
        {
            throw  ("ConfigurationItem '{0}' does not exist" -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -repositoryid $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        If (-not('udm.Environment' -eq $Type)) {
            throw  ("ConfigurationItem '{0}' not an Environment" -f $RepositoryId)
        }

        $Changed = $false

        Write-Verbose -Message ("Checking members of Environment '{0}'." -f $RepositoryId)
        ForEach ($Member in $Members)
        {
            $MembersElement = $ConfigurationItem | Select-Xml -XPath ("//members/*[@ref='{0}']" -f $Member)
            if (-not ($MembersElement))
            {
                if($PSCmdlet.ShouldProcess($RepositoryId,("Add member '{0}'." -f $Member))){
                    $MembersElement = $configurationItem.CreateElement('ci')
                    $MembersElement.SetAttribute('ref', $Member)
                    $MembersNode = $configurationItem.$Type.SelectSingleNode('members')
                    $null = $MembersNode.AppendChild($MembersElement)
                    $Changed = $true
                }
            }
            Else
            {
                Write-Verbose -Message ("'{0}' already a member of '{1}'." -f $Member, $RepositoryId)
            }
        }

        ForEach ($Dictionary in $Dictionaries)
        {
            $DictionariesElement = ($ConfigurationItem | Select-Xml -XPath ("//dictionaries/*[@ref='{0}']" -f $Dictionary)).node
            if (-not ($DictionariesElement))
            {
                if($PSCmdlet.ShouldProcess($RepositoryId,("Add dictionary '{0}'." -f $Dictionary))){
                    $DictionariesElement = $configurationItem.CreateElement('ci')
                    $DictionariesElement.SetAttribute('ref', $dictionary)
                    $DictionariesNode = $configurationItem.$Type.SelectSingleNode('dictionaries')
                    $null = $DictionariesNode.AppendChild($DictionariesElement)
                    $Changed = $true
                }
            }
            Else
            {
                Write-Verbose -Message ("{0} already a dictionary of {1}" -f $Dictionary, $RepositoryId)
            }
        }
        If ($Changed) {
            $Resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $Resource -Method PUT -Body $ConfigurationItem
        }
    }
}
