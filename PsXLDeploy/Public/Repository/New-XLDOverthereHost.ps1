function New-XLDOverthereHost {
    <#
            .SYNOPSIS
            Creates an udm.Container.

            .DESCRIPTION
            Creates an udm.Container which can be added to an environment to deploy to.

            .PARAMETER overthereHostid
            The ID of the new udm.Container.

            .PARAMETER Force
            If specified creates subfolders recursively

            .PARAMETER type
            The type of udm.overthereHost.

            .PARAMETER address
            The address of the host.

            .PARAMETER os
            Operating system the host runs.

            .PARAMETER port
            Port on which the telnet of winrm server runs.

            .PARAMETER username
            Username to connect with.

            .PARAMETER password
            Password used for authentication.

            .PARAMETER tags
            If set, only deployables with the same tag will be automatically mapped to this container.

            .PARAMETER connectionType
            Specifies what protocol is used to execute commands on the remote hosts.

            .PARAMETER cifsPort
            Port in which the CIFS server runs.

            .PARAMETER winrmEnableHttps
            Enables SSL communication to the WINRM server.

            .PARAMETER winrsAllowDelegate
            Specifies that the user's credentials can be used to access a remote share,
            for example found on different machine than the target endpoint (WINRM_NATIVE only)

            .PARAMETER privateKeyFile
            private key file to use for authentication.

            .PARAMETER passphrase
            optional password for the private key in the private key file.

            .PARAMETER sudoUsername
            Username to sudo to when accessing files or executing commands.

            .PARAMETER suUsername
            Username to su to when accessing files or executing commands.

            .PARAMETER suPassword
            Password of user to su to when accessing files or executing commands.

            .EXAMPLE
            New-XLDOverthereHost -overthereHostid Infrastructure/Unixhost -type overthere.SshHost -address 1.1.1.1 -os Unix -username piet -password piet -connectionType SUDO

            .EXAMPLE
            New-XLDOverthereHost -overthereHostid Infrastructure/Windowshost -type overthere.CifsHost -address 1.1.1.1 -os Windows -username piet -password piet -connectionType WINRM_NATIVE

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType([object])]
    param(
        [Parameter(Mandatory,
            ParameterSetName='ByName',
            ValueFromPipelineByPropertyName )]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName='ByName')]
        [string]$Folder,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName='ById')]
        [string]$RepositoryId,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName )]
        [ValidateSet('overthere.CifsHost','overthere.SshHost')]
        [string]$type,

        [Parameter(ValueFromPipelineByPropertyName )]
        [switch]$Force
    )
    DynamicParam {
        $overthereHost = @(
            @{
                Name      = 'address'
                Mandatory = $true
            }
            ,
            @{
                Name        = 'os'
                Mandatory   = $true
                ValidateSet = ('WINDOWS', 'UNIX', 'ZOS')
            }
            ,
            @{
                Name      = 'port'
                Type      = [int]
                Mandatory = $false
            }
            ,
            @{
                Name      = 'username'
                Mandatory = $true
            }
            ,
            @{
                Name      = 'tags'
                Type      = [string[]]
                Mandatory = $false
            }
            ,
            @{
                Name      = 'deploymentGroup'
                Type      = [string]
                Mandatory = $false
            }
            ,
            @{
                Name      = 'deploymentSubGroup'
                Type      = [string]
                Mandatory = $false
            }
            ,
            @{
                Name      = 'deploymentSubSubGroup'
                Type      = [string]
                Mandatory = $false
            }
        )

        $overthereCifsHost = @(
            @{
                Name      = 'password'
                Mandatory = $true
            }
            ,
            @{
                Name        = 'connectionType'
                Mandatory   = $true
                ValidateSet = ('TELNET', 'WINRM_NATIVE', 'WINRM_INTERNAL')
            }
            ,
            @{
                Name      = 'cifsPort'
                Type      = [int]
                Mandatory = $false
            }
            ,
            @{
                Name      = 'winrmEnableHttps'
                Type      = [string]
                Mandatory = $false
            }
            ,
            @{
                Name      = 'winrsAllowDelegate'
                Type      = [string]
                Mandatory = $false
            }
        )

        $overthereSSHHost = @(
            @{
                Name      = 'password'
                Mandatory = $false
            }
            ,
            @{
                Name        = 'connectionType'
                Mandatory   = $true
                ValidateSet = ('SFTP', 'SFTP_CYGWIN', 'SFTP_WINSSHD', 'SCP', 'SUDO', 'INTERACTIVE_SUDO')
            }
            ,
            @{
                Name      = 'privateKeyFile'
                Mandatory = $false
            }
            ,
            @{
                Name      = 'passphrase'
                Mandatory = $false
            }
            ,
            @{
                Name      = 'sudoUsername'
                Mandatory = $false
            }
            ,
            @{
                Name      = 'suUsername'
                Mandatory = $false
            }
            ,
            @{
                Name      = 'suPassword'
                Mandatory = $false
            }
        )

        $DynamicParameters = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

        $overthereHost |
            ForEach-Object -Process {
            New-Object -TypeName PSObject -Property $_
        } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters

        If('overthere.CifsHost' -eq $type) {
            $overthereCifsHost |
                ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
                New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }
        elseif ('overthere.SSHHost' -eq $type) {
            $overthereSSHHost |
                ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
                New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }
        $DynamicParameters
    }

    PROCESS {
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        $Commons = 'Debug',
        'ErrorAction',
        'ErrorVariable',
        'OutVariable',
        'OutBuffer',
        'Verbose',
        'WarningAction',
        'WarningVariable',
        'Confirm',
        'WhatIf',
        'UseTransaction',
        'InformationAction',
        'InformationVariable',
        'PipelineVariable'

        $NotNeededParams = 'Name',
        'Folder',
        'Force'

        $OverthereParams = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        ForEach ($key in $ParameterList.keys) {
            $var = Get-Variable -Name $key -ErrorAction SilentlyContinue
            if (-not ([String]::IsNullOrEmpty($var.Value)) -and ($key -notin ($Commons + $NotNeededParams))) {
                $OverthereParams.Add($key, $var.Value)
            }
        }

        If ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $RepositoryId = Join-RepositoryPathPart -Name $Name -Folder $Folder -Type Repository
            $OverthereParams.add('RepositoryId', $RepositoryId)
        }

        If (Test-XLDConfigurationItem -RepositoryId $RepositoryId) {
            Throw  ("OverthereHost '{0}' already exists." -f $RepositoryId)
        }

        $directoryPath = Get-DirectoryPath -repositoryId $RepositoryId

        If ($Force -and $directoryPath -and !(Test-XLDconfigurationItem -repositoryid $directoryPath)) {
            $null = New-XLDDirectory -RepositoryId $directoryPath -recurse
        }

        If ($PSCmdlet.ShouldProcess($RepositoryId)){
            $ConfigurationItem = New-ConfigurationItem @OverthereParams
            $resource = 'repository/ci/{0}' -f $RepositoryId
            $Response = Invoke-XLDRestMethod -Resource $resource -Method POST -Body $ConfigurationItem

            switch ($Type) {
            'overthere.CifsHost'
                {
                    $Hash = [ordered]@{
                        RepositoryId = $RepositoryId
                        os = $Response.$Type.OS
                        address = $Response.$Type.Address
                        username = $Response.$Type.username
                        password = $Response.$Type.password
                        connectionType = $Response.$Type.connectionType
                        winrmEnableHttps = [bool]$Response.$Type.winrmEnableHttps
                        winrsAllowDelegate = [bool]$Response.$Type.winrsAllowDelegate
                        port = [int]$Response.$Type.port
                        cifsPort = [int]$Response.$Type.cifsPort
                        tags = $Response.$Type.Tags.Value
                        deploymentGroup = [int]$Response.$Type.deploymentGroup
                        deploymentSubGroup = [int]$Response.$Type.deploymentSubGroup
                        deploymentSubSubGroup = [int]$Response.$Type.deploymentSubSubGroup
                    }
                }
            'overthere.SshHost'
                {
                    $Hash = [ordered]@{
                        RepositoryId = $RepositoryId
                        os = $Response.$Type.OS
                        address = $Response.$Type.Address
                        username = $Response.$Type.username
                        password = $Response.$Type.password
                        connectionType = $Response.$Type.connectionType
                        port = [int]$Response.$Type.port
                        tags = $Response.$Type.Tags.Value
                        deploymentGroup = [int]$Response.$Type.deploymentGroup
                        deploymentSubGroup = [int]$Response.$Type.deploymentSubGroup
                        deploymentSubSubGroup = [int]$Response.$Type.deploymentSubSubGroup
                        passphrase = $Response.$Type.passphrase
                        privateKeyFile = $Response.$Type.privateKeyFile
                        sudoUsername = $Response.$Type.sudoUsername
                        suUsername = $Response.$Type.suUsername
                        suPassword = $Response.$Type.suPassword
                    }
                }
            }

            $Result = New-Object -TypeName psobject -Property $Hash
            return $Result | Add-ObjectType -TypeName $type
        }
    }
}
