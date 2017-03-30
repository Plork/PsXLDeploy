function Join-RepositoryPathPart
{
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory)]
        [string]$Name,

        [string]$Folder,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName)]
        [ValidateSet('Repository','Environments','Applications')]
        [string]$type
    )

    PROCESS {
        switch ($type){
            Repository {
                $BasePath = 'Infrastructure' }
            Environments {
                $BasePath = 'Environments' }
            Applications {
                $BasePath = 'Applications' }
        }

        If (-not($Folder)) {
            $RepositoryId = '{0}/{1}' -f $BasePath, $Name
        }
        Else {
            If (-not ($Folder.StartsWith($BasePath, 'InvariantCultureIgnoreCase')))
            {
                $RepositoryId = '{0}/{1}/{2}' -f $BasePath, $Folder, $Name
            }
            Else {
                $RepositoryId = '{0}/{1}' -f $Folder, $Name
            }
        }

        return (Get-EncodedPathPart -PartialPath $RepositoryId)
    }
}

