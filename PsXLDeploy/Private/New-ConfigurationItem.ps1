function New-ConfigurationItem
{
    <#
            .SYNOPSIS
            Creates a configuration item object.

            .DESCRIPTION
            Reads a configuration item from the repository by specifying the repositoryid of the ConfigurationItem.

            .PARAMETER repositoryid
            The ID of the new udm.ConfigurationItem.

            .PARAMETER type
            The type of udm.ConfigurationItem.

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

            .OUTPUTS
            [XML] of a ConfigurationItem object.

            .EXAMPLE
            New-ConfigurationItem -repositoryid Infrastructure/Unixhost -type overthere.SshHost -address 1.1.1.1 -os Unix -username piet -password piet -connectionType SUDO

            .EXAMPLE
            New-ConfigurationItem -repositoryid Infrastructure/Windowshost -type overthere.CifsHost -address 1.1.1.1 -os Windows -username piet -password piet -connectionType WINRM_NATIVE

            .EXAMPLE
            New-ConfigurationItem -repositoryid Environment/Env -type udm.Environment

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding()]
    [OutputType([xml])]
    param (
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName)]
        [string]$RepositoryId
        ,
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName)]
        [string]$type
    )
    DynamicParam {
        $Hosts= @(
            @{
                Name      = 'tags'
                Type      = [string[]]
                Mandatory = $false
            },
            @{
                Name      = 'deploymentGroup'
                Type      = [int]
                Mandatory = $false
            },
            @{
                Name      = 'deploymentSubGroup'
                Type      = [int]
                Mandatory = $false
            },
            @{
                Name      = 'deploymentSubSubGroup'
                Type      = [int]
                Mandatory = $false
            }
        )
        $overthereHost = @(
            @{
                Name      = 'address'
                Mandatory = $true
            },
            @{
                Name        = 'os'
                Mandatory   = $true
                ValidateSet = ('WINDOWS', 'UNIX', 'ZOS')
            },
            @{
                Name      = 'port'
                Type      = [int]
                Mandatory = $false
            },
            @{
                Name      = 'username'
                Mandatory = $true
            }
        )

        $overthereCifsHost = @(
            @{
                Name      = 'password'
                Mandatory = $true
            },
            @{
                Name        = 'connectionType'
                Mandatory   = $true
                ValidateSet = ('TELNET', 'WINRM_NATIVE', 'WINRM_INTERNAL')
            },
            @{
                Name      = 'cifsPort'
                Type      = [int]
                Mandatory = $false
            },
            @{
                Name      = 'winrmEnableHttps'
                Type      = [string]
                Mandatory = $false
            },
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
            },
            @{
                Name        = 'connectionType'
                Mandatory   = $true
                ValidateSet = ('SFTP', 'SFTP_CYGWIN', 'SFTP_WINSSHD', 'SCP', 'SUDO', 'INTERACTIVE_SUDO')
            },
            @{
                Name      = 'privateKeyFile'
                Mandatory = $false
            },
            @{
                Name      = 'passphrase'
                Mandatory = $false
            },
            @{
                Name      = 'sudoUsername'
                Mandatory = $false
            },
            @{
                Name      = 'suUsername'
                Mandatory = $false
            },
            @{
                Name      = 'suPassword'
                Mandatory = $false
            }
        )

        $overthereContainer = @(
            @{
                Name      = 'overthereHostid'
                Mandatory = $true
            }
        )

        $dictionary = @(
            @{
                Name      = 'Entries'
                Type      = [hashtable]
                Mandatory = $false
            },
            @{
                Name      = 'restrictToContainers'
                Type      = [string[]]
                Mandatory = $false
            },
            @{
                Name      = 'restrictToApplications'
                Type      = [string[]]
                Mandatory = $false
            }
        )
        $environment = @(
            @{
                Name      = 'members'
                Type      = [string[]]
                Mandatory = $false
            },
            @{
                Name      = 'dictionaries'
                Type      = [string[]]
                Mandatory = $false
            }
        )

        $DynamicParameters = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

        If(('overthere.CifsHost', 'overthere.SshHost', 'iis.Server','chef.Solo') -contains $type)
        {
            $Hosts |
            ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }

        If(('overthere.CifsHost', 'overthere.SshHost') -contains $type)
        {
            $overthereHost |
            ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }

        If('overthere.CifsHost' -eq $type)
        {
            $overthereCifsHost |
            ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }
        elseif ('overthere.SshHost' -eq $type)
        {
            $overthereSSHHost |
            ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }
        elseif ('iis.Server','chef.Solo' -contains $type)
        {
            $overthereContainer |
            ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }
        elseif ('udm.Dictionary','udm.EncryptedDictionary' -contains $type)
        {
            $dictionary |
            ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }
        elseif ('udm.Environment' -eq $type)
        {
            $environment |
            ForEach-Object -Process {
                New-Object -TypeName PSObject -Property $_
            } |
            New-DynamicParameter -ValueFromPipelineByPropertyName -Dictionary $DynamicParameters
        }

        $DynamicParameters
    }

    PROCESS {
        $xmlhash =
        @{
            root       = $type
            attributes = @{
                id = $RepositoryId
            }
            elements   = @()
        }

        $null = $PSBoundParameters.Remove('Type')
        $null = $PSBoundParameters.Remove('repositoryid')

        foreach($psbp in $PSBoundParameters.GetEnumerator())
        {
            if ('members','restrictToContainers','restrictToApplications','dictionaries' -contains $psbp.key)
            {
                $elementhash = @{
                    element  = $psbp.key
                    children = @(
                            ForEach ($ci in $psbp.value){
                            @{
                                child      = 'ci'
                                attributes = @{
                                    ref = $ci
                                }
                            }
                        }
                    )
                }
                $xmlhash.elements += $elementhash
            }
            elseif ($psbp.key -eq 'entries')
            {
                    $elementhash = @{
                        element  = 'entries'
                        children = @(
                            foreach ($entry in ($psbp.value).getenumerator())
                            {
                                @{
                                    child      = 'entry'
                                    attributes = @{
                                        key = $entry.key
                                    }
                                    text = $entry.value
                                }
                            }
                        )
                    }
                    $xmlhash.elements += $elementhash
            }
            elseif ($psbp.key -eq 'tags')
            {
                $elementhash = @{
                    element  = 'tags'
                    children = @(
                        ForEach ($tag in $psbp.value)
                        {
                            @{
                                child = 'value'
                                text  = $tag
                            }
                        }
                    )
                }
                $xmlhash.elements += $elementhash
            }
            elseif ($psbp.key -eq 'overthereHostid')
            {
                $elementhash = @{
                    element  = 'host'
                    attributes = @{
                        ref = $psbp.value
                    }
                }
                $xmlhash.elements += $elementhash
            }
            Else
            {
                # don't ouput automatic variables
                If (-not ('verbose', 'whatif', 'debug' -contains $psbp.key))
                {
                    Write-Verbose -Message ('Key={0} Value={1}' -f $psbp.Key, $psbp.Value)
                    $elementhash = @{
                        element = $psbp.key
                        text    = $psbp.value
                    }

                    $xmlhash.elements += $elementhash
                }
            }
        }

        [xml]$ConfigurationItem = New-XMLDocument -scriptblock {
            $xmlhash
        }

        return $ConfigurationItem
    }
}

