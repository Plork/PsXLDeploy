function Remove-Tag {
    <#
            .SYNOPSIS
            Add tags to an repository item.

            .DESCRIPTION
            Add tags to an repository item by specifying a list of strings.

            .PARAMETER Name
            The Name of the repository item.

            .PARAMETER Folder
            The Folder the repository item resides in.

            .PARAMETER tags
            a list of strings containing tags.

            .OUTPUTS
            [hashtable] with the repository item and the updated tags is returned.

            .EXAMPLE
            Add-XLDTag -Name WindowsHost -Tags "Tag1","Tag2"

            .EXAMPLE
            Add-XLDTag -Name WindowsHost -Folder HostFolder -Tags "Tag1","Tag2"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType([object])]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [xml]$ConfigurationItem,

        [string[]]$Tags
    )

    PROCESS {
        $RepositoryID = ($ConfigurationItem | Select-XML -XPath ("//*/@id")).Id
        ForEach ($Tag in $Tags) {
            $TagsElement = ($ConfigurationItem | Select-Xml -XPath ("//tags/value[. ='{0}']" -f $Tag)).node
            if ($TagsElement) {
                If ($PSCmdlet.ShouldProcess($RepositoryId, ("Remove tag '{0}'." -f $Tag))) {
                    $null = $TagsElement.ParentNode.RemoveChild($TagsElement)
                }
            }
            Else {
                Write-Verbose -Message ("'{0}' not a tag of '{1}'." -f $Tag, $RepositoryId)
            }
        }
    }
    End {
        return $ConfigurationItem
    }
}
