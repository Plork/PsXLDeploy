function Send-XLDPackage {
    <#
            .SYNOPSIS
            Uploads an application package.

            .DESCRIPTION
            Uploads an application package.

            .EXAMPLE
            Send-XLDPackage -PackagePath C:\Temp\PetClinic-ear-1.0.dar

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    param
    (
        [parameter(
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$PackagePath
    )

    if (-not (Test-Path $PackagePath)) {
        Throw "Package {0} missing or unable to read." -f $PackagePath
    }

    $FileName = Split-Path $PackagePath -leaf
    $FileName = Get-EncodedPathPart $FileName

    $Resource = "package/upload/$FileName"

    $Response = Invoke-MultipartFormDataUpload -InFile $PackagePath -Resource $Resource
    $Type = Get-RepositoryType -ConfigurationItem $Response

    return $Response.$Type
}
