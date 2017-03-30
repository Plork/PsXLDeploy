function Rename-XLDConfigurationItem
{
    <#
            .SYNOPSIS
            Changes the name of a configuration item in the repository.

            .PARAMETER repositoryid
            the ID of the CI to rename

            .PARAMETER newname
            the new name

            .EXAMPLE
            Rename-XLDConfigurationItem -repositoryid "Environments/dictionaries/Dict" -newname "Environments/dictionaries/NewDict"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType([xml])]
    param(
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName )]
        [string]$RepositoryId
        ,
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName )]
        [string]$Newname
    )

    PROCESS {
        if (-not(Test-XLDRepositoryItem -repositoryid $repositoryid))
        {
            throw  ('{0} does not exist' -f $repositoryid)
        }

        $resource = 'repository/rename/{0}' -f $RepositoryId

        $uriparams = @{}
        $uriparams['newName'] = $Newname

        if($PSCmdlet.ShouldProcess($RepositoryId,("Rename to '{0}'." -f $NewName))){
            $response = Invoke-XLDRestMethod -Resource $resource -Method POST -UriParams $uriparams
            $type = ($response | Get-Member -MemberType Properties).name

            return $response.$type | Add-ObjectType -TypeName $type
        }
    }
}
