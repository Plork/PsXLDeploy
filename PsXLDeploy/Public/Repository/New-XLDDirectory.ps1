function New-XLDDirectory {
    <#
            .SYNOPSIS
            creates a new core.Directory.

            .PARAMETER DirectoryPath
            The path to the new core.Directory.

            .PARAMETER recurse
            If specified creates subfolders recursively

            .EXAMPLE
            New-XLDDirectory -RepositoryId "Environments/Folder"

            .EXAMPLE
            New-XLDDirectory -RepositoryId "Infrastructure/Folder/Folder" -recurse

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName )]
        [string]$RepositoryId,

        [Parameter(ValueFromPipelineByPropertyName )]
        [switch]$Recurse
    )
    PROCESS {
        If (Test-XLDconfigurationItem -repositoryid $RepositoryId) {
            throw  ("'{0}' already exists." -f $RepositoryId)
        }

        $FoldersArray = $RepositoryId.split('/')
        for ($FolderIndex = 1; $FolderIndex -le ($FoldersArray.count - 2); $FolderIndex++) {
            $NewDirectory = ($FoldersArray[0..$FolderIndex] -join '/')

            If (-not (Test-XLDConfigurationItem -repositoryid $NewDirectory)) {
                if ($PSCmdlet.ShouldProcess($NewDirectory)) {
                    If ($Recurse.IsPresent) {
                        $Response = New-Directory -Directory $NewDirectory
                    }
                    Else {
                        throw  ("Parent folder '{0}' does not exists." -f $NewDirectory)
                    }
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($RepositoryId)) {
            $Response = New-Directory -Directory $RepositoryId
        }

        $Result = New-Object -TypeName psobject -Property @{ RepositoryId = $Response.'core.Directory'.Id}
        return $Result | Add-ObjectType -TypeName 'core.Directory'
    }
}
