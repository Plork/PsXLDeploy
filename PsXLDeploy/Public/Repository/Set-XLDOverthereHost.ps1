function Set-XLDOverthereHost {
    <#
            .SYNOPSIS
            Updates an udm.Container.

            .DESCRIPTION
            Updates the properties of an udm.Container.

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
            Set-XLDOverthereHost -overthereHostid Infrastructure/Unixhost -type overthere.SshHost -address 1.1.1.2

            .EXAMPLE
            Set-XLDOverthereHost -overthereHostid Infrastructure/Windowshost -type overthere.CifsHost -address 1.1.1.2

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding(SupportsShouldProcess)]
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
        [ValidateSet('overthere.CifsHost','overthere.SSHHost')]
        [string]$type
    )
    DynamicParam {
        $overthereHost = @(
            @{
                Name      = 'address'
                Mandatory = $false
            }
            ,
            @{
                Name        = 'os'
                Mandatory   = $false
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
                Mandatory = $false
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
                Mandatory = $false
            }
            ,
            @{
                Name        = 'connectionType'
                Mandatory   = $false
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
                ValidateSet = 'true','false'
            }
            ,
            @{
                Name      = 'winrsAllowDelegate'
                Type      = [string]
                Mandatory = $false
                ValidateSet = 'true','false'
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
                Mandatory   = $false
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
        'Type',
        'RepositoryId'

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
        }

        If (-not(Test-XLDConfigurationItem -RepositoryId $RepositoryId)) {
            Throw  ("ConfigurationItem '{0}' does not exist." -f $RepositoryId)
        }

        $ConfigurationItem = Get-XLDConfigurationItem -repositoryid $RepositoryId
        $Type = Get-RepositoryType -ConfigurationItem $ConfigurationItem

        $Changed = $false
        ForEach($OverthereParameter in $OverthereParams.GetEnumerator()) {
            If (-not ($OverthereParameter.key -eq 'tags')) {
                If ($ConfigurationItem.$type.($OverthereParameter.key) -cne $OverthereParameter.value) {
                    If ($PSCmdlet.ShouldProcess($RepositoryId, "Setting $($OverthereParameter.key) to $($OverthereParameter.value)")){
                        $ConfigurationItem.$type.($OverthereParameter.key) = ($OverthereParameter.value).toString()
                        $Changed = $true
                    }
                }
            }
            ElseIf ($OverthereParameter.key -eq 'tags') {
                If ($ConfigurationItem.$type.tags.value) {
                    $TagsRemoved = Compare-Object -ReferenceObject $OverthereParameter.value -DifferenceObject $ConfigurationItem.$type.tags.value | Where-Object { $_.SideIndicator -eq '=>' } |
                        ForEach-Object  { Write-Output $_.InputObject }
                    If ($TagsRemoved) {
                        $ConfigurationItem = Remove-Tag -ConfigurationItem $ConfigurationItem -Tags $TagsRemoved -whatif:$WhatIfPreference
                        $Changed = $true
                    }
                }

                If ($ConfigurationItem.$type.tags.value) {
                    $TagsAdded = Compare-Object -ReferenceObject $OverthereParameter.value -DifferenceObject $ConfigurationItem.$type.tags.value | Where-Object { $_.SideIndicator -eq '<=' } |
                    ForEach-Object  { Write-Output $_.InputObject }
                }
                else {
                    $TagsAdded =  $OverthereParameter.Value
                }
                If ($TagsAdded) {
                    $ConfigurationItem = Add-Tag -ConfigurationItem $ConfigurationItem -Tags $TagsAdded -whatif:$WhatIfPreference
                    $Changed = $true
                }
            }
        }

        If ($Changed) {
            $Resource = 'repository/ci/{0}' -f $RepositoryId
            $null = Invoke-XLDRestMethod -Resource $Resource -Method PUT -Body $ConfigurationItem
        }
    }
}
