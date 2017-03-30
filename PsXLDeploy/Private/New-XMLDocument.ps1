Function New-XMLDocument
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [scriptblock] $scriptblock
    )
    BEGIN {
        $xmlhash = & $scriptblock
        $xmlDoc = New-Object -TypeName System.Xml.XmlDocument
        $xmlRoot = $xmlDoc.CreateElement($xmlhash.root)
        $null = $xmlDoc.AppendChild($xmlRoot)

        If ($xmlhash.Attributes)
        {
            foreach ($rootAttribute in $xmlhash.Attributes.GetEnumerator())
            {
                $null = $xmlRoot.SetAttribute($rootAttribute.name, $rootAttribute.value)
            }
        }
    }
    PROCESS {
        foreach ($element in $xmlhash.elements)
        {
            $xmlelement = $xmlDoc.CreateElement($element.element)

            If ($element.Attributes)
            {
                foreach ($Attribute in $element.Attributes.GetEnumerator())
                {
                    $null = $xmlelement.SetAttribute($Attribute.name, $Attribute.value)
                }
            }

            If ($element['text'] -ne $null -or $element['text'] -ne '')
            {
                $null = $xmlelement.AppendChild($xmlDoc.CreateTextNode($element['text']))
            }

            foreach ($child in $element.Children)
            {
                $xmlChild = $xmlelement.AppendChild($xmlDoc.CreateElement($child['child']))

                If ($child.Attributes)
                {
                    foreach ($ChildAttribute in $child.Attributes.GetEnumerator())
                    {
                        $null = $xmlChild.SetAttribute($ChildAttribute.name, $ChildAttribute.value)
                    }
                }

                If ($child['text'] -ne $null -or $child['text'] -ne '')
                {
                    $null = $xmlChild.AppendChild($xmlDoc.CreateTextNode($child['text']))
                }
            }
            $null = $xmlRoot.AppendChild($xmlelement)
        }
        Write-Output -InputObject $xmlDoc
    }
}
