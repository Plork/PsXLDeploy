function Add-Tag {
    <#
            .SYNOPSIS
            Add tags to an configuration item.

            .DESCRIPTION
            Add tags to an configuration item xml.

            .PARAMETER ConfigurationItem
            The XML body of the configuration item.

            .PARAMETER Tags
            The XML body of the configuration item.

            .OUTPUTS
            [xml] with the configuration item with the updated tags is returned.

            .EXAMPLE
            Add-Tag -ConfigurationItem $ConfigurationItem -Tags Tag1,Tag2

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType([xml])]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [xml]$ConfigurationItem,

        [string[]]$Tags
    )

    PROCESS {
        $RepositoryID = ($ConfigurationItem | Select-XML -XPath ("//*/@id")).Id
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        ForEach ($Tag in $Tags) {
            $TagsElement = $ConfigurationItem | Select-Xml -XPath ("//tags/value[. ='{0}']" -f $Tag)
            if (-not $TagsElement) {
                if ($PSCmdlet.ShouldProcess($RepositoryId, ("Add tag '{0}'." -f $Tag))) {
                    $TagsElement = $ConfigurationItem.CreateElement('value')
                    $TagsElement.Innertext = $Tag
                    $Tagsnode = $ConfigurationItem.$Type.SelectSingleNode('tags')
                    $null = $Tagsnode.AppendChild($TagsElement)
                }
            }
            Else {
                Write-Verbose -Message ("{0} already a tag of {1}" -f $Tag, $RepositoryId)
            }
        }
    }
    End {
        return $ConfigurationItem
    }
}
