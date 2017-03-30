
$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
$null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

Get-Module PsXLDeploy | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\PsXLDeploy" -Force

InModuleScope -ModuleName PsXLDeploy {

    $Hash = @(
        @{
            Type = 'by Id'
            Params = @{
                RepositoryId = 'Infrastructure/overthereHost'
            }
        }
        @{
            Type = 'by name'
            Params = @{
                Name = 'overthereHost'
                Folder = 'Infrastructure'
            }
        }
    )

    $overthereCifsHost = @{
        type = 'overthere.CifsHost'
        os = 'WINDOWS'
        address = '127.0.0.1'
        username = 'username'
        password = 'password'
        connectionType = 'WINRM_NATIVE'
        port = 1
        tags = 'tag1'
        deploymentGroup = 1
        deploymentSubGroup = 1
        deploymentSubSubGroup = 1
        cifsPort = 1
        winrmEnableHttps = 'true'
        winrsAllowDelegate = 'true'
    }

    $overthereSshHost = @{
        type = 'overthere.SshHost'
        os = 'UNIX'
        address = '127.0.0.1'
        username = 'username'
        password = 'password'
        connectionType = 'SUDO'
        port = 1
        tags = 'tag1'
        deploymentGroup = 1
        deploymentSubGroup = 1
        deploymentSubSubGroup = 1
        passphrase = 'passphrase'
        privateKeyFile = 'privateKeyFile'
        sudoUsername = 'sudoUsername'
        suUsername = 'suUsername'
        suPassword = 'suPassword'
    }

    Describe -Name 'creates overthereHost' {

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationItem } -ParameterFilter { $Method -eq 'POST' }

        ForEach ($Context in $Hash) {

            Context ('overthere.cifsHost {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                # Mock XML object as response from the API and check if the returned object has expected values
                Context 'response xml returned as object' {
                    Mock Invoke-XLDRestMethod -MockWith { return $overthereHostxml } -ParameterFilter { $Method -eq 'POST' }

                    [xml]$overthereHostxml = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.CifsHost.Full.xml)
                    $XLDoverthereHost = New-XLDOverthereHost @inputParams @overthereCifsHost

                    It 'returns RepositoryId' {
                        $XLDoverthereHost.RepositoryId | Should Be 'Infrastructure/overthereHost'
                    }
                    It 'returns Type' {
                        $XLDoverthereHost.Type | Should Be $overthereCifsHost.type
                    }
                    It 'returns OS' {
                        $XLDoverthereHost.OS | Should Be $overthereCifsHost.OS
                    }
                    It 'returns address' {
                        $XLDoverthereHost.address | Should Be $overthereCifsHost.address
                    }
                    It 'returns username' {
                        $XLDoverthereHost.username | Should Be $overthereCifsHost.username
                    }
                    It 'returns password' {
                        $XLDoverthereHost.password | Should Be $overthereCifsHost.password
                    }
                    It 'returns connectionType' {
                        $XLDoverthereHost.connectionType | Should Be $overthereCifsHost.connectionType
                    }
                    It 'returns port' {
                        $XLDoverthereHost.port | Should Be $overthereCifsHost.port
                    }
                    It 'returns tags' {
                        $XLDoverthereHost.tags -contains $overthereCifsHost.tags | Should Be $true
                    }
                    It 'returns deploymentGroup' {
                        $XLDoverthereHost.deploymentGroup | Should Be $overthereCifsHost.deploymentGroup
                    }
                    It 'returns deploymentSubGroup' {
                        $XLDoverthereHost.deploymentSubGroup | Should Be $overthereCifsHost.deploymentSubGroup
                    }
                    It 'returns deploymentSubSubGroup' {
                        $XLDoverthereHost.deploymentSubSubGroup | Should Be $overthereCifsHost.deploymentSubSubGroup
                    }
                    It 'returns cifsPort' {
                        $XLDoverthereHost.cifsPort | Should Be $overthereCifsHost.cifsPort
                    }
                    It 'returns winrmEnableHttps' {
                        $XLDoverthereHost.winrmEnableHttps | Should Be $overthereCifsHost.winrmEnableHttps
                    }
                    It 'returns winrsAllowDelegate' {
                        $XLDoverthereHost.winrsAllowDelegate | Should Be $overthereCifsHost.winrsAllowDelegate
                    }
                }

                # check if correct XML is created with input parameters that will be send to the API
                Context 'created xml body' {

                    $XLDoverthereHost = New-XLDOverthereHost @inputParams @overthereCifsHost

                    It 'xml has atribute id' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']")).Node | Should Not BeNullOrEmpty
                    }
                    It 'xml has element os with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/os")).Node.'#text' | Should be $overthereCifsHost.OS
                    }
                    It 'xml has element address with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/address")).Node.'#text' | Should be $overthereCifsHost.address
                    }
                    It 'xml has element connectionType with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/connectionType")).Node.'#text' | Should be $overthereCifsHost.connectionType
                    }
                    It 'xml has element port with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/port")).Node.'#text' | Should be $overthereCifsHost.port
                    }
                    It 'xml has element username with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/username")).Node.'#text' | Should be $overthereCifsHost.username
                    }
                    It 'xml has element password with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/password")).Node.'#text' | Should be $overthereCifsHost.password
                    }
                    It 'xml has element tags with childelement value with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/tags/value")).Node.'#text' | Should be $overthereCifsHost.tags
                    }
                    It 'xml has element deploymentGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/deploymentGroup")).Node.'#text' | Should be $overthereCifsHost.deploymentGroup
                    }
                    It 'xml has element deploymentSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/deploymentSubGroup")).Node.'#text' | Should be $overthereCifsHost.deploymentSubGroup
                    }
                    It 'xml has element deploymentSubSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/deploymentSubSubGroup")).Node.'#text' | Should be $overthereCifsHost.deploymentSubSubGroup
                    }
                    It 'xml has element winrmEnableHttps with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/winrmEnableHttps")).Node.'#text' | Should be $overthereCifsHost.winrmEnableHttps
                    }
                    It 'xml has element winrsAllowDelegate with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/winrsAllowDelegate")).Node.'#text' | Should be $overthereCifsHost.winrsAllowDelegate
                    }
                    It 'xml has element cifsPort with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/cifsPort")).Node.'#text' | Should be $overthereCifsHost.cifsPort
                    }
                }

                Context 'exists returns true' {
                    It 'throws when overthere.cifsHost already exists' {


                        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }

                        $XLDoverthereHostScriptBlock = { New-XLDOverthereHost @inputParams @overthereCifsHost }
                        $XLDoverthereHostScriptBlock | Should Throw
                    }
                }
            }
        }

        ForEach ($Context in $Hash) {

            Context ('overthere.SshHost {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                Context 'response xml returned as object' {
                    Mock Invoke-XLDRestMethod -MockWith { return $overthereHostxml } -ParameterFilter { $Method -eq 'POST' }

                    [xml]$overthereHostxml = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.Full.xml)
                    $XLDoverthereHost = New-XLDOverthereHost @inputParams @overthereSshHost

                    It 'returns RepositoryId' {
                        $XLDoverthereHost.RepositoryId | Should Be 'Infrastructure/overthereHost'
                    }
                    It 'returns Type' {
                        $XLDoverthereHost.Type | Should Be $overthereSshHost.Type
                    }
                    It 'returns OS' {
                        $XLDoverthereHost.OS | Should Be $overthereSshHost.OS
                    }
                    It 'returns address' {
                        $XLDoverthereHost.address | Should Be $overthereSshHost.address
                    }
                    It 'returns username' {
                        $XLDoverthereHost.username | Should Be $overthereSshHost.username
                    }
                    It 'returns password' {
                        $XLDoverthereHost.password | Should Be $overthereSshHost.password
                    }
                    It 'returns connectionType' {
                        $XLDoverthereHost.connectionType | Should Be $overthereSshHost.connectionType
                    }
                    It 'returns port' {
                        $XLDoverthereHost.port | Should Be $overthereSshHost.port
                    }
                    It 'returns tags' {
                        $XLDoverthereHost.tags -contains $overthereSshHost.tags | Should Be $true
                    }
                    It 'returns deploymentGroup' {
                        $XLDoverthereHost.deploymentGroup | Should Be $overthereSshHost.deploymentGroup
                    }
                    It 'returns deploymentSubGroup' {
                        $XLDoverthereHost.deploymentSubGroup | Should Be $overthereSshHost.deploymentSubGroup
                    }
                    It 'returns deploymentSubSubGroup' {
                        $XLDoverthereHost.deploymentSubSubGroup | Should Be $overthereSshHost.deploymentSubSubGroup
                    }
                    It 'returns passphrase' {
                        $XLDoverthereHost.passphrase | Should Be $overthereSshHost.passphrase
                    }
                    It 'returns privateKeyFile' {
                        $XLDoverthereHost.privateKeyFile | Should Be $overthereSshHost.privateKeyFile
                    }
                    It 'returns sudoUsername' {
                        $XLDoverthereHost.sudoUsername | Should Be $overthereSshHost.sudoUsername
                    }
                    It 'returns suUsername' {
                        $XLDoverthereHost.suUsername | Should Be $overthereSshHost.suUsername
                    }
                    It 'returns suPassword' {
                        $XLDoverthereHost.suPassword | Should Be $overthereSshHost.suPassword
                    }
                }

                Context 'created xml body' {

                    $XLDoverthereHost = New-XLDOverthereHost @inputParams @overthereSshHost

                    It 'xml has atribute id' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']")).Node | Should Not BeNullOrEmpty
                    }
                    It 'xml has element os with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/os")).Node.'#text' | Should be $overthereSshHost.OS
                    }
                    It 'xml has element address with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/address")).Node.'#text' | Should be $overthereSshHost.address
                    }
                    It 'xml has element connectionType with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/connectionType")).Node.'#text' | Should be $overthereSshHost.connectionType
                    }
                    It 'xml has element port with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/port")).Node.'#text' | Should be $overthereSshHost.port
                    }
                    It 'xml has element username with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/username")).Node.'#text' | Should be $overthereSshHost.username
                    }
                    It 'xml has element password with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/password")).Node.'#text' | Should be $overthereSshHost.password
                    }
                    It 'xml has element tags with childelement value with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags/value")).Node.'#text' | Should be $overthereSshHost.tags
                    }
                    It 'xml has element deploymentGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/deploymentGroup")).Node.'#text' | Should be $overthereSshHost.deploymentGroup
                    }
                    It 'xml has element deploymentSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/deploymentSubGroup")).Node.'#text' | Should be $overthereSshHost.deploymentSubGroup
                    }
                    It 'xml has element deploymentSubSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/deploymentSubSubGroup")).Node.'#text' | Should be $overthereSshHost.deploymentSubSubGroup
                    }
                    It 'xml has element passphrase with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/passphrase")).Node.'#text' | Should be $overthereSshHost.passphrase
                    }
                    It 'xml has element privateKeyFile with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/privateKeyFile")).Node.'#text' | Should be $overthereSshHost.privateKeyFile
                    }
                    It 'xml has element sudoUsername with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/sudoUsername")).Node.'#text' | Should be $overthereSshHost.sudoUsername
                    }
                    It 'xml has element suUsername with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/suUsername")).Node.'#text' | Should be $overthereSshHost.suUsername
                    }
                    It 'xml has element suPassword with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/suPassword")).Node.'#text' | Should be $overthereSshHost.suPassword
                    }
                }
            }
        }
    }

    Describe -Name 'gets overthereHost' {

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'POST' }
        Mock Invoke-XLDRestMethod -MockWith { return $overthereHostXML } -ParameterFilter { $Resource -eq 'repository/ci/Infrastructure/overthereHost' }

        ForEach ($Context in $Hash) {

            Context ('overthere {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                Context 'returned overthere.SshHost' {
                    [xml]$overthereHostXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.Full.xml)
                    $XLDoverthereHost = Get-XLDOverthereHost @inputParams

                    It 'returns RepositoryId' {
                        $XLDoverthereHost.RepositoryId | Should Be 'Infrastructure/overthereHost'
                    }
                    It 'returns Type' {
                        $XLDoverthereHost.Type | Should Be $overthereSshHost.Type
                    }
                    It 'returns OS' {
                        $XLDoverthereHost.OS | Should Be $overthereSshHost.OS
                    }
                    It 'returns address' {
                        $XLDoverthereHost.address | Should Be $overthereSshHost.address
                    }
                    It 'returns username' {
                        $XLDoverthereHost.username | Should Be $overthereSshHost.username
                    }
                    It 'returns password' {
                        $XLDoverthereHost.password | Should Be $overthereSshHost.password
                    }
                    It 'returns connectionType' {
                        $XLDoverthereHost.connectionType | Should Be $overthereSshHost.connectionType
                    }
                    It 'returns port' {
                        $XLDoverthereHost.port | Should Be $overthereSshHost.port
                    }
                    It 'returns tags' {
                        $XLDoverthereHost.tags -contains $overthereSshHost.tags | Should Be $true
                    }
                    It 'returns deploymentGroup' {
                        $XLDoverthereHost.deploymentGroup | Should Be $overthereSshHost.deploymentGroup
                    }
                    It 'returns deploymentSubGroup' {
                        $XLDoverthereHost.deploymentSubGroup | Should Be $overthereSshHost.deploymentSubGroup
                    }
                    It 'returns deploymentSubSubGroup' {
                        $XLDoverthereHost.deploymentSubSubGroup | Should Be $overthereSshHost.deploymentSubSubGroup
                    }
                    It 'returns passphrase' {
                        $XLDoverthereHost.passphrase | Should Be $overthereSshHost.passphrase
                    }
                    It 'returns privateKeyFile' {
                        $XLDoverthereHost.privateKeyFile | Should Be $overthereSshHost.privateKeyFile
                    }
                    It 'returns sudoUsername' {
                        $XLDoverthereHost.sudoUsername | Should Be $overthereSshHost.sudoUsername
                    }
                    It 'returns suUsername' {
                        $XLDoverthereHost.suUsername | Should Be $overthereSshHost.suUsername
                    }
                    It 'returns suPassword' {
                        $XLDoverthereHost.suPassword | Should Be $overthereSshHost.suPassword
                    }
                }

                Context 'returned overthere.cifsHost' {
                    [xml]$overthereHostXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.CifsHost.Full.xml)
                    $XLDoverthereHost = Get-XLDOverthereHost @inputParams

                    It 'returns RepositoryId' {
                        $XLDoverthereHost.RepositoryId | Should Be 'Infrastructure/overthereHost'
                    }
                    It 'returns Type' {
                        $XLDoverthereHost.Type | Should Be $overthereCifsHost.type
                    }
                    It 'returns OS' {
                        $XLDoverthereHost.OS | Should Be $overthereCifsHost.OS
                    }
                    It 'returns address' {
                        $XLDoverthereHost.address | Should Be $overthereCifsHost.address
                    }
                    It 'returns username' {
                        $XLDoverthereHost.username | Should Be $overthereCifsHost.username
                    }
                    It 'returns password' {
                        $XLDoverthereHost.password | Should Be $overthereCifsHost.password
                    }
                    It 'returns connectionType' {
                        $XLDoverthereHost.connectionType | Should Be $overthereCifsHost.connectionType
                    }
                    It 'returns port' {
                        $XLDoverthereHost.port | Should Be $overthereCifsHost.port
                    }
                    It 'returns tags' {
                        $XLDoverthereHost.tags -contains $overthereCifsHost.tags | Should Be $true
                    }
                    It 'returns deploymentGroup' {
                        $XLDoverthereHost.deploymentGroup | Should Be $overthereCifsHost.deploymentGroup
                    }
                    It 'returns deploymentSubGroup' {
                        $XLDoverthereHost.deploymentSubGroup | Should Be $overthereCifsHost.deploymentSubGroup
                    }
                    It 'returns deploymentSubSubGroup' {
                        $XLDoverthereHost.deploymentSubSubGroup | Should Be $overthereCifsHost.deploymentSubSubGroup
                    }
                    It 'returns cifsPort' {
                        $XLDoverthereHost.cifsPort | Should Be $overthereCifsHost.cifsPort
                    }
                    It 'returns winrmEnableHttps' {
                        $XLDoverthereHost.winrmEnableHttps | Should Be $overthereCifsHost.winrmEnableHttps
                    }
                    It 'returns winrsAllowDelegate' {
                        $XLDoverthereHost.winrsAllowDelegate | Should Be $overthereCifsHost.winrsAllowDelegate
                    }
                }

                Context 'exists returns false' {
                    It 'throws when overthere.Host does not exist' {

                        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }

                        $XLDoverthereHostScriptBlock = { Get-XLDOverthereHost @inputParams }
                        $XLDoverthereHostScriptBlock | Should Throw
                    }
                }
            }
        }

        Context 'udm.Dictionary' {

            It 'throws when not an overthereHost' {
                [xml]$udmDictionary = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                Mock Invoke-XLDRestMethod -MockWith { return $udmDictionary } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }

                $XLDDirectoryScriptBlock = { Get-XLDOverthereHost -RepositoryId 'Environments/Dictionary' }
                $XLDDirectoryScriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'sets overthereHost' {

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        $overthereCifsHostSet = @{
            type = 'overthere.CifsHost'
            os = 'WINDOWS'
            address = '127.0.0.2'
            username = 'usernam2'
            password = 'passwor2'
            connectionType = 'WINRM_INTERNAL'
            port = 2
            tags = 'tag2','tag3'
            deploymentGroup = 2
            deploymentSubGroup = 2
            deploymentSubSubGroup = 2
            cifsPort = 2
            winrmEnableHttps = 'false'
            winrsAllowDelegate = 'false'
        }

        $overthereSshHostSet = @{
            type = 'overthere.SshHost'
            os = 'UNIX'
            address = '127.0.0.2'
            username = 'usernam2'
            password = 'passwor2'
            connectionType = 'INTERACTIVE_SUDO'
            port = 2
            tags = 'tag2','tag3'
            deploymentGroup = 2
            deploymentSubGroup = 2
            deploymentSubSubGroup = 2
            passphrase = 'passphrase2'
            privateKeyFile = 'privateKeyFile2'
            sudoUsername = 'sudoUsername2'
            suUsername = 'suUsername2'
            suPassword = 'suPassword2'
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure' }
        Mock Invoke-XLDRestMethod -MockWith { return $overthereHostxml } -ParameterFilter { $Resource -eq 'repository/ci/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('overthere.cifsHost {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                # check if correct XML is created with input parameters that will be send to the API
                Context 'created xml body' {

                    [xml]$overthereHostxml = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.CifsHost.Full.xml)
                    Set-XLDOverthereHost @inputParams @overthereCifsHostSet

                    It 'xml has atribute id' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']")).Node | Should Not BeNullOrEmpty
                    }
                    It 'xml has element os with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/os")).Node.'#text' | Should be $overthereCifsHostSet.OS
                    }
                    It 'xml has element address with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/address")).Node.'#text' | Should be $overthereCifsHostSet.address
                    }
                    It 'xml has element connectionType with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/connectionType")).Node.'#text' | Should be $overthereCifsHostSet.connectionType
                    }
                    It 'xml has element port with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/port")).Node.'#text' | Should be $overthereCifsHostSet.port
                    }
                    It 'xml has element username with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/username")).Node.'#text' | Should be $overthereCifsHostSet.username
                    }
                    It 'xml has element password with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/password")).Node.'#text' | Should be $overthereCifsHostSet.password
                    }
                    It 'xml has element tags with childelement value with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/tags/value")).Node.'#text' | Should be $overthereCifsHostSet.tags
                    }
                    It 'xml has element deploymentGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/deploymentGroup")).Node.'#text' | Should be $overthereCifsHostSet.deploymentGroup
                    }
                    It 'xml has element deploymentSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/deploymentSubGroup")).Node.'#text' | Should be $overthereCifsHostSet.deploymentSubGroup
                    }
                    It 'xml has element deploymentSubSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/deploymentSubSubGroup")).Node.'#text' | Should be $overthereCifsHostSet.deploymentSubSubGroup
                    }
                    It 'xml has element winrmEnableHttps with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/winrmEnableHttps")).Node.'#text' | Should be $overthereCifsHostSet.winrmEnableHttps
                    }
                    It 'xml has element winrsAllowDelegate with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/winrsAllowDelegate")).Node.'#text' | Should be $overthereCifsHostSet.winrsAllowDelegate
                    }
                    It 'xml has element cifsPort with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.CifsHost[@id='Infrastructure/overthereHost']/cifsPort")).Node.'#text' | Should be $overthereCifsHostSet.cifsPort
                    }
                }

                Context 'exists returns false' {
                    It 'throws when overthere.cifsHost already exists' {

                        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }

                        $XLDoverthereHostScriptBlock = { Set-XLDOverthereHost @inputParams @overthereCifsHost }
                        $XLDoverthereHostScriptBlock | Should Throw
                    }
                }
            }
        }

        ForEach ($Context in $Hash) {

            Context ('overthere.SshHost {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                Context 'created xml body' {

                    [xml]$overthereHostxml = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.Full.xml)
                    Set-XLDOverthereHost @inputParams @overthereSshHostSet

                    It 'xml has atribute id' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']")).Node | Should Not BeNullOrEmpty
                    }
                    It 'xml has element os with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/os")).Node.'#text' | Should be $overthereSshHostSet.OS
                    }
                    It 'xml has element address with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/address")).Node.'#text' | Should be $overthereSshHostSet.address
                    }
                    It 'xml has element connectionType with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/connectionType")).Node.'#text' | Should be $overthereSshHostSet.connectionType
                    }
                    It 'xml has element port with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/port")).Node.'#text' | Should be $overthereSshHostSet.port
                    }
                    It 'xml has element username with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/username")).Node.'#text' | Should be $overthereSshHostSet.username
                    }
                    It 'xml has element password with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/password")).Node.'#text' | Should be $overthereSshHostSet.password
                    }
                    It 'xml has element tags with childelement value with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags/value")).Node.'#text' | Should be $overthereSshHostSet.tags
                    }
                    It 'xml has element deploymentGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/deploymentGroup")).Node.'#text' | Should be $overthereSshHostSet.deploymentGroup
                    }
                    It 'xml has element deploymentSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/deploymentSubGroup")).Node.'#text' | Should be $overthereSshHostSet.deploymentSubGroup
                    }
                    It 'xml has element deploymentSubSubGroup with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/deploymentSubSubGroup")).Node.'#text' | Should be $overthereSshHostSet.deploymentSubSubGroup
                    }
                    It 'xml has element passphrase with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/passphrase")).Node.'#text' | Should be $overthereSshHostSet.passphrase
                    }
                    It 'xml has element privateKeyFile with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/privateKeyFile")).Node.'#text' | Should be $overthereSshHostSet.privateKeyFile
                    }
                    It 'xml has element sudoUsername with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/sudoUsername")).Node.'#text' | Should be $overthereSshHostSet.sudoUsername
                    }
                    It 'xml has element suUsername with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/suUsername")).Node.'#text' | Should be $overthereSshHostSet.suUsername
                    }
                    It 'xml has element suPassword with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/suPassword")).Node.'#text' | Should be $overthereSshHostSet.suPassword
                    }
                }
            }
        }
    }

    Describe -Name 'creates overthereContainer' {

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        $overthereContainer = @{
            type = 'iis.Server'
            name = 'overthereHost-IIS'
            overthereHostId = 'Infrastructure/overthereHost'
            tags = 'tag1', 'tag2'
            deploymentGroup = 1
            deploymentSubGroup = 1
            deploymentSubSubGroup = 1
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost/overthereHost-IIS' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationItem } -ParameterFilter { $Method -eq 'POST' }

        # Mock XML object as response from the API and check if the returned object has expected values
        Context 'response xml returned as object' {

            Mock Invoke-XLDRestMethod -MockWith { return $overthereContainerxml } -ParameterFilter { $Method -eq 'POST' -and $Resource -eq 'repository/ci/Infrastructure/overthereHost/overthereHost-IIS' }
            [xml]$overthereContainerxml = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath iis.Server.Full.xml)
            $XLDoverthereContainer = New-XLDOverthereContainer @overthereContainer
            It 'returns RepositoryId' {
                $XLDoverthereContainer.RepositoryId | Should Be 'Infrastructure/overthereHost/overthereHost-IIS'
            }
            It 'returns Type' {
                $XLDoverthereContainer.Type | Should Be $overthereContainer.type
            }
            It 'returns OS' {
                $XLDoverthereContainer.OverthereHostId | Should Be $overthereContainer.OverthereHostId
            }
            It 'returns tags' {
                $XLDoverthereContainer.tags | Should Be $overthereContainer.tags
            }
            It 'returns deploymentGroup' {
                $XLDoverthereContainer.deploymentGroup | Should Be $overthereContainer.deploymentGroup
            }
            It 'returns deploymentSubGroup' {
                $XLDoverthereContainer.deploymentSubGroup | Should Be $overthereContainer.deploymentSubGroup
            }
            It 'returns deploymentSubGroup' {
                $XLDoverthereContainer.deploymentSubSubGroup | Should Be $overthereContainer.deploymentSubSubGroup
            }
        }

        # check if correct XML is created with input parameters that will be send to the API
        Context 'created xml body' {

            $XLDoverthereContainer = New-XLDOverthereContainer @overthereContainer

            It 'xml has atribute id' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']")).Node | Should Not BeNullOrEmpty
            }
            It 'xml has element host with ref' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/host")).Node.ref | Should be $overthereContainer.OverthereHostId
            }
            It 'xml has element tags with childelement value with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/tags/value")).Node.'#text' | Should be $overthereContainer.tags
            }
            It 'xml has element deploymentGroup with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/deploymentGroup")).Node.'#text' | Should be $overthereContainer.deploymentGroup
            }
            It 'xml has element deploymentSubGroup with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/deploymentSubGroup")).Node.'#text' | Should be $overthereContainer.deploymentSubGroup
            }
            It 'xml has element deploymentSubSubGroup with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/deploymentSubSubGroup")).Node.'#text' | Should be $overthereContainer.deploymentSubSubGroup
            }
        }

        Context 'exists returns true' {
            It 'throws when container already exists' {
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost/overthereHost-IIS' }
                $XLDoverthereHostScriptBlock = { New-XLDOverthereContainer @overthereContainer }
                $XLDoverthereHostScriptBlock | Should Throw
            }
        }

        Context 'exists returns false' {
            It 'throws when host does not exist' {
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
                $XLDoverthereHostScriptBlock = { New-XLDOverthereContainer @overthereContainer }
                $XLDoverthereHostScriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'sets overthereContainer' {

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        $overthereContainerSet = @{
            RepositoryId = 'Infrastructure/overthereHost/overthereHost-IIS'
            type = 'iis.Server'
            tags = 'tag2', 'tag3'
            deploymentGroup = 2
            deploymentSubGroup = 2
            deploymentSubSubGroup = 2
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost/overthereHost-IIS' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { return $overthereContainerxml } -ParameterFilter { $Resource -eq 'repository/ci/Infrastructure/overthereHost/overthereHost-IIS' -and $Method -eq 'GET'}
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        # check if correct XML is created with input parameters that will be send to the API
        Context 'created xml body' {

            [xml]$overthereContainerxml = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath iis.Server.Full.xml)
            Set-XLDOverthereContainer @overthereContainerSet

            It 'xml has atribute id' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']")).Node | Should Not BeNullOrEmpty
            }
            It 'xml has element tags with childelement value with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/tags/value")).Node.'#text' | Should be $overthereContainerSet.tags
            }
            It 'xml has element deploymentGroup with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/deploymentGroup")).Node.'#text' | Should be $overthereContainerSet.deploymentGroup
            }
            It 'xml has element deploymentSubGroup with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/deploymentSubGroup")).Node.'#text' | Should be $overthereContainerSet.deploymentSubGroup
            }
            It 'xml has element deploymentSubSubGroup with #text' {
                ($MockHash.Result | Select-Xml -XPath ("//iis.Server[@id='Infrastructure/overthereHost/overthereHost-IIS']/deploymentSubSubGroup")).Node.'#text' | Should be $overthereContainerSet.deploymentSubSubGroup
            }
        }

        Context 'exists returns false' {
            It 'throws when container does not exist' {
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost/overthereHost-IIS' }
                $XLDoverthereHostScriptBlock = {  Set-XLDOverthereContainer @overthereContainerSet }
                $XLDoverthereHostScriptBlock | Should Throw
            }
            It 'throws when host does not exist' {
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
                $XLDoverthereHostScriptBlock = {  Set-XLDOverthereContainer @overthereContainerSet }
                $XLDoverthereHostScriptBlock | Should Throw
            }
        }
    }

}
