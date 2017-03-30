function Test-XLDManifestFile
{
    <#
        .SYNOPSIS
        Test for a valid manifest file.

        .DESCRIPTION
        Verifies If the given is valid path and If the file is a valid manifest file.

        .PARAMETER ManifestPath
        the path to the manifest file.

        .EXAMPLE
        Test-XLDManifestFile -ManifestPath ./deployit-manifest.xml

        .LINK
        https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [parameter(Mandatory)]
        [ValidateScript({
                    Test-Path -Path $_ -PathType Leaf
        })]
        [string]$ManifestPath
    )

    PROCESS
    {
        try
        {
            [xml]$manifest = Get-Content -Path $ManifestPath
        }
        catch
        {
            Throw ('{0} is not a valid xml document.' -f $ManifestPath)
        }

        $deploymentPackageElement = $manifest.'udm.DeploymentPackage'

        If (-not $deploymentPackageElement)
        {
            Throw ('{0} is not a valid manifest xml document.' -f $ManifestPath)
        }

        return $true
    }
}
