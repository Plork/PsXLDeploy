function Remove-XLDEnvironmentMember
{
    <#
            .SYNOPSIS
            Remove containers or dictionaries from an environment.

            .DESCRIPTION
            Remove containers or dictionaries from an environment by specifying a list of strings with the RepositoryId's.

            .PARAMETER Name
            The Name of the environment.

            .PARAMETER Folder
            The Folder the environment resides in.

            .PARAMETER containers
            a list of strings containing Id's of udm.Containers.

            .PARAMETER dictionaries
            a list of strings containing Id's of udm.Dictionaries.

            .OUTPUTS
            [hashtable] with the environment and the updated CI's is returned.

            .EXAMPLE
            Remove-XLDEnvironmentMember -environmentId "Environments/Env" -containers "Infrastructure/Host1,Infrastructure/Host2"

            .EXAMPLE
            Remove-XLDEnvironmentMember -environmentId "Environments/Env" -dictionaries "Environments/dictionaries/Dict1,Environments/dictionaries/Dict2"

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

        [string[]]$Members,

        [string[]]$Dictionaries
    )

    PROCESS {
        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Environments
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId))
        {
            Throw  ("Environment '{0}' does not exist." -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -RepositoryId $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        If (-not('udm.Environment' -eq $Type)) {
            Throw  ("ConfigurationItem '{0}' not an Environment" -f $RepositoryId)
        }

        $Changed = $false

        Write-Verbose -Message ("Checking members of environment '{0}'." -f $RepositoryId)
        ForEach ($Member in $Members)
        {
            $MembersElement = ($configurationItem | Select-Xml -XPath ("//*/members/*[@ref='{0}']" -f $Member)).node
            if ($MembersElement)
            {
                if($PSCmdlet.ShouldProcess($RepositoryId,("Remove member '{0}'." -f $Member))){
                    $null = $MembersElement.ParentNode.RemoveChild($MembersElement)
                    $Changed = $true
                }
            }
            Else
            {
                Write-Verbose -Message ("'{0}' not a member of '{1}'." -f $Container, $RepositoryId)
            }
        }

        ForEach ($Dictionary in $Dictionaries)
        {
            $DictionariesElement = ($ConfigurationItem | Select-Xml -XPath ("//*/dictionaries/*[@ref='{0}']" -f $Dictionary)).node
            If ($DictionariesElement)
            {
                If($PSCmdlet.ShouldProcess($RepositoryId,("Remove dictionary '{0}'." -f $Dictionary))){
                    $null = $DictionariesElement.ParentNode.RemoveChild($DictionariesElement)
                    $Changed = $true
                }
        }
            Else
            {
                Write-Verbose -Message ("'{0}' already a dictionary of '{1}'." -f $Dictionary, $RepositoryId)
            }
        }

        If ($Changed) {
            $resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $resource -Method PUT -Body $ConfigurationItem
        }
    }
}
