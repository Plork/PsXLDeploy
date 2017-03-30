function Get-XLDOverthereHost {
    <#
            .SYNOPSIS
            Reads a configuration item from the repository.

            .DESCRIPTION
            Reads a configuration item from the repository by specifying the repositoryid of the ConfigurationItem.

            .PARAMETER repositoryid
            The ID of the new udm.ConfigurationItem.

            .OUTPUTS
            [XML] with the CI, or a 404 error code If not found.

            .EXAMPLE
            Get-XLDConfigurationItem -repositoryid "Environments/Dict"

            .EXAMPLE
            Get-XLDConfigurationItem -repositoryid "Environments/Env"

            .EXAMPLE
            Get-XLDConfigurationItem -repositoryid "Infrastructure/Host"

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,
            ParameterSetName='ByName')]
        [string]$Name,

        [Parameter(ParameterSetName='ByName')]
        [string]$Folder,

        [Parameter(Mandatory,
            ParameterSetName='ById')]
        [string]$RepositoryId
    )

    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Repository
    }

    $ConfigurationItem = Get-XLDConfigurationItem -repositoryid $RepositoryId
    $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

    if (-not($Type.StartsWith('overthere'))) {
        throw  "ConfigurationItem not an overthere host"
    }

    switch ($Type) {
        'overthere.CifsHost' {
            $Hash = [ordered]@{
                RepositoryId = $RepositoryId
                os = $ConfigurationItem.$Type.OS
                address = $ConfigurationItem.$Type.Address
                username = $ConfigurationItem.$Type.username
                password = $ConfigurationItem.$Type.password
                connectionType = $ConfigurationItem.$Type.connectionType
                winrmEnableHttps = [bool]$ConfigurationItem.$Type.winrmEnableHttps
                winrsAllowDelegate = [bool]$ConfigurationItem.$Type.winrsAllowDelegate
                port = [int]$ConfigurationItem.$Type.port
                cifsPort = [int]$ConfigurationItem.$Type.cifsPort
                tags = $ConfigurationItem.$Type.Tags.Value
                deploymentGroup = [int]$ConfigurationItem.$Type.deploymentGroup
                deploymentSubGroup = [int]$ConfigurationItem.$Type.deploymentSubGroup
                deploymentSubSubGroup = [int]$ConfigurationItem.$Type.deploymentSubSubGroup
            }
        }
        'overthere.SshHost' {
            $Hash = [ordered]@{
                RepositoryId = $RepositoryId
                os = $ConfigurationItem.$Type.OS
                address = $ConfigurationItem.$Type.Address
                username = $ConfigurationItem.$Type.username
                password = $ConfigurationItem.$Type.password
                connectionType = $ConfigurationItem.$Type.connectionType
                port = [int]$ConfigurationItem.$Type.port
                tags = $ConfigurationItem.$Type.Tags.Value
                deploymentGroup = [int]$ConfigurationItem.$Type.deploymentGroup
                deploymentSubGroup = [int]$ConfigurationItem.$Type.deploymentSubGroup
                deploymentSubSubGroup = [int]$ConfigurationItem.$Type.deploymentSubSubGroup
                passphrase = $ConfigurationItem.$Type.passphrase
                privateKeyFile = $ConfigurationItem.$Type.privateKeyFile
                sudoUsername = $ConfigurationItem.$Type.sudoUsername
                suUsername = $ConfigurationItem.$Type.suUsername
                suPassword = $ConfigurationItem.$Type.suPassword
            }
        }
    }

    $Result = New-Object -TypeName psobject -Property $Hash
    return $Result | Add-ObjectType -TypeName $Type

}
