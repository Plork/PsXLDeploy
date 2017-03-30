function Get-XLDDescriptor {
    <#
            .SYNOPSIS
            Lists all the Descriptors

            .DESCRIPTION
            Lists all the Descriptors of all the types known to the XL Deploy Type System. Hidden properties are not exposed.

            .PARAMETER Type
            the type to get the descriptor of.

            .EXAMPLE
            Get-XLDDescriptor

            .EXAMPLE
            Get-XLDDescriptor -Type iis.Website

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param(
        [string]$Type
    )
    BEGIN {
        $resource = 'metadata/type'
        If ($Type) {
            $resource = ('{0}/{1}' -f $resource, $Type)
        }
    }
    PROCESS {
        $Response = Invoke-XLDRestMethod -Resource $resource
        if ($Type) {
            $Return =  $Response.descriptor
        }
        else {
            $Return =  $Response.list.descriptor
        }
        return $Return
    }
}
