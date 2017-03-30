$XLDURi = 'http://localhost:4516'
$XLDCredentials = New-Object PSCredential("admin", (ConvertTo-SecureString "password" -AsPlainText -Force))

$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
$null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

Get-Module PsXLDeploy | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\PsXLDeploy" -Force

# We've tested set... use it here.
Set-XLDConfig -Uri $XLDUri
Set-XLDAuthentication -Credential $XLDCredentials

Describe 'Server tests' {

    $XLDServerInfo = Get-XLDServerInfo

    It 'returns server info' {
        ($XLDServerInfo | Get-Member -MemberType NoteProperty).Name | Should be ('classpath', 'plugins', 'version')
        $XLDServerInfo.classpath | Should Not BeNullOrEmpty
        $XLDServerInfo.plugins | Should Not BeNullOrEmpty
        $XLDServerInfo.version | Should Not BeNullOrEmpty
        { [version]$XLDServerInfo.version } | Should Not Throw
    }
    It 'returns server state' {
        Get-XLDServerState | Should Match 'RUNNING|MAINTENANCE'
    }

    $Orchestrators = @(
        'parallel-by-composite-package',
        'parallel-by-container',
        'parallel-by-dependency',
        'parallel-by-deployed',
        'parallel-by-deployment-group',
        'parallel-by-deployment-sub-group',
        'parallel-by-deployment-sub-sub-group',
        'sequential-by-composite-package',
        'sequential-by-container',
        'sequential-by-dependency',
        'sequential-by-deployed',
        'sequential-by-deployment-group',
        'sequential-by-deployment-sub-group',
        'sequential-by-deployment-sub-sub-group'
    )

    It 'returns orchestrators' {
        Get-XLDOrchestrator | Should Be $Orchestrators
    }

    It 'returns permissions' {
        (Get-XLDPermission).count | Should be 19
    }

    It 'starts maintenance' {
        Start-XLDMaintenance | Should Match 'MAINTENANCE'
    }
    It 'stops maintenance' {
        Stop-XLDMaintenance | Should Match 'RUNNING'
    }

    It 'gets descriptors' {
        Get-XLDDescriptor | Should Not BeNullOrEmpty
    }

    It 'gets descriptors of specific type' {
        (Get-XLDDescriptor -Type overthere.CifsHost).Type | Should Be 'overthere.CifsHost'
        ((Get-XLDDescriptor -Type overthere.CifsHost).Type).Count | Should Be 1
    }
}

Describe 'Repository Tests' {

    $DictionaryParams = @{
        RepositoryId = 'Environments/Dictionary'
        Entries = @{
            key1 = 'value1'
        }
    }

    $overthereCifsHostParams = @{
        RepositoryId = 'Infrastructure/overthereHost'
        type = 'overthere.CifsHost'
        os = 'WINDOWS'
        address = '127.0.0.1'
        username = 'username'
        password = 'password'
        connectionType = 'WINRM_INTERNAL'
        port = 1
        tags = 'tag1'
        deploymentGroup = 1
        deploymentSubGroup = 1
        deploymentSubSubGroup = 1
        cifsPort = 1
        winrmEnableHttps = 'false'
        winrsAllowDelegate = 'false'
    }

    $EnvironmentParams = @{
        RepositoryId = 'Environments/Environment'
    }

    Context 'folder' {
        It 'creates a folder' {
            $null = New-XLDDirectory -RepositoryId Environments/Directory
            Test-XLDConfigurationItem -RepositoryId Environments/Directory | Should Be $True
        }
    }

    Context 'overthereHost' {
        It 'creates an overthereHost' {
            $null = New-XLDOverthereHost @overthereCifsHostParams
            Test-XLDOverthereHost -RepositoryId $overthereCifsHostParams.RepositoryId | Should Be $True
        }
        It 'sets an overthereHost' {
            Set-XLDOverthereHost -RepositoryId $overthereCifsHostParams.RepositoryId -address '127.0.0.2' -type overthere.CifsHost
            (Get-XLDOverthereHost -RepositoryId $overthereCifsHostParams.RepositoryId).address | Should Be '127.0.0.2'
        }
        It 'add a tag to overthereHost' {
            Add-XLDTag -RepositoryId $overthereCifsHostParams.RepositoryId -Tags 'tag2'
            (Get-XLDOverthereHost -RepositoryId $overthereCifsHostParams.RepositoryId).Tags -contains 'tag2' | Should Be $True
        }
        It 'remove a tag from overthereHost' {
            Remove-XLDTag -RepositoryId $overthereCifsHostParams.RepositoryId -Tags 'tag2'
            (Get-XLDOverthereHost -RepositoryId $overthereCifsHostParams.RepositoryId).Tags -contains 'tag2' | Should Be $False
        }
    }

    Context 'dictionary' {
        It 'creates a dictionary' {
            $null = New-XLDDictionary @DictionaryParams
            Test-XLDDictionary -RepositoryId $DictionaryParams.RepositoryId | Should Be $True
        }
        It 'adds dictionary entries' {
            $null = Set-XLDDictionaryEntry -RepositoryId $DictionaryParams.RepositoryId -Entries @{ key2 = 'value2'}
            (Get-XLDDictionary -RepositoryId $DictionaryParams.RepositoryId).Entries.ContainsKey('key2') | Should Be $True
        }
        It 'removes dictionary entries' {
            $null = Remove-XLDDictionaryEntry -RepositoryId $DictionaryParams.RepositoryId -Entries key2
            (Get-XLDDictionary -RepositoryId $DictionaryParams.RepositoryId).Entries.ContainsKey('key2') | Should Be $False
        }
        It 'add dictionary restriction' {
            $null = Add-XLDDictionaryRestrict -RepositoryId $DictionaryParams.RepositoryId -restrictToContainers $overthereCifsHostParams.RepositoryId
            (Get-XLDDictionary -RepositoryId $DictionaryParams.RepositoryId).restrictToContainers -contains $overthereCifsHostParams.RepositoryId | Should Be $True
        }
        It 'remove dictionary restriction' {
            $null = Remove-XLDDictionaryRestrict -RepositoryId $DictionaryParams.RepositoryId -Containers $overthereCifsHostParams.RepositoryId
            (Get-XLDDictionary -RepositoryId $DictionaryParams.RepositoryId).restrictToContainers -contains $overthereCifsHostParams.RepositoryId | Should Be $False
        }
    }

    Context 'environment' {
        It 'creates an environment' {
            $null = New-XLDEnvironment @EnvironmentParams
            Test-XLDEnvironment -RepositoryId $EnvironmentParams.RepositoryId | Should Be $True
        }
        It 'add member to an environment' {
            Add-XLDEnvironmentMember -RepositoryId $EnvironmentParams.RepositoryId -Members $overthereCifsHostParams.RepositoryId
            (Get-XLDEnvironment -RepositoryId $EnvironmentParams.RepositoryId).Members -contains $overthereCifsHostParams.RepositoryId | Should Be $True
        }
        It 'add dictionary to an environment' {
            Add-XLDEnvironmentMember -RepositoryId $EnvironmentParams.RepositoryId -Dictionaries $DictionaryParams.RepositoryId
            (Get-XLDEnvironment -RepositoryId $EnvironmentParams.RepositoryId).Dictionaries -contains $DictionaryParams.RepositoryId | Should Be $True
        }
        It 'remove member from an environment' {
            Remove-XLDEnvironmentMember -RepositoryId $EnvironmentParams.RepositoryId -Members $overthereCifsHostParams.RepositoryId
            (Get-XLDEnvironment -RepositoryId $EnvironmentParams.RepositoryId).Members -contains $overthereCifsHostParams.RepositoryId | Should Be $False
        }
        It 'remove dictionary from an environment' {
            Remove-XLDEnvironmentMember -RepositoryId $EnvironmentParams.RepositoryId -Dictionaries $DictionaryParams.RepositoryId
            (Get-XLDEnvironment -RepositoryId $EnvironmentParams.RepositoryId).Dictionaries -contains $DictionaryParams.RepositoryId | Should Be $False
        }
    }

    Context 'Package' {
        It 'list available packages' {

            $packages = @(
                'NerdDinner/2.0',
                'PetClinic-ear/1.0',
                'PetClinic-ear/2.0',
                'PetClinic-war/1.0',
                'PetClinic-war/2.0'
            )

            Get-XLDPackage | Should Be $packages
        }
        It 'imports a package' {
            Import-XLDPackage -PackageId 'NerdDinner/2.0'
            Test-XLDApplication -RepositoryId 'Applications/NerdDinner/2.0' | Should Be $True
        }
        It 'imports a package again' {
            $ImportScriptBlock = { Import-XLDPackage -PackageId 'NerdDinner/2.0' }
            $ImportScriptBlock | Should Throw
        }
        It 'uploads a package' {
            Send-XLDPackage -PackagePath (Join-Path $PSScriptRoot -ChildPath 'Artifacts\PetClinic-ear-1.0.dar')
            Test-XLDApplication -RepositoryId 'Applications/PetClinic-ear/1.0' | Should Be $True
        }
        It 'uploads a package again' {
            $SendScriptBlock = { Send-XLDPackage -PackagePath (Join-Path $PSScriptRoot -ChildPath 'Artifacts\PetClinic-ear-1.0.dar') }
            $SendScriptBlock | Should Throw
        }
    }

    Context 'Deployment' {

        BeforeAll {
            $ResultHash = @{
                result = ''
            }
        }

        It 'creates a deployment' {
            $DeploymentScriptBlock = { New-XLDDeployment -PackageId 'Applications/NerdDinner/2.0' -EnvironmentId $EnvironmentParams.RepositoryId }
            $DeploymentScriptBlock | Should Not Throw
        }
        It 'starts a task' {
            $ResultHash.TaskId = New-XLDDeployment -PackageId 'Applications/NerdDinner/2.0' -EnvironmentId $EnvironmentParams.RepositoryId
            $TaskScriptBlock = { Start-XLDTask -taskId $ResultHash.TaskId }
            $TaskScriptBlock | Should Not Throw
        }
        It 'retrieves a tasks state' {
            $taskState = Get-XLDTaskState -taskId $ResultHash.TaskId
            $taskState | Should Match 'EXECUTING'
        }
        It 'waits for a task to complete' {
            Wait-XLDTask -taskId $ResultHash.TaskId
            $taskState = Get-XLDTaskState -taskId $ResultHash.TaskId
            $taskState | Should Match 'EXECUTED'
        }
        It 'archives a tasks state' {
            Complete-XLDTask -taskId $ResultHash.TaskId
            Get-XLDTaskState -taskId $ResultHash.TaskId | Should be 'DONE'
        }

    }

    Context 'cleanup' {
        It 'remove dictionary' {
            Remove-XLDConfigurationItem -RepositoryId $DictionaryParams.RepositoryId -Confirm:$false
            Test-XLDDictionary -RepositoryId $DictionaryParams.RepositoryId | Should Be $False
        }
        It 'remove overthereHost' {
            Remove-XLDConfigurationItem -RepositoryId $overthereCifsHostParams.RepositoryId -Confirm:$false
            Test-XLDOverthereHost -RepositoryId $overthereCifsHostParams.RepositoryId | Should Be $False
        }
        It 'remove an environment' {
            Remove-XLDConfigurationItem -RepositoryId $EnvironmentParams.RepositoryId -Confirm:$false
            Test-XLDEnvironment -RepositoryId $EnvironmentParams.RepositoryId | Should Be $False
        }
        It 'remove a folder' {
            Remove-XLDConfigurationItem -RepositoryId Environments/Directory -Confirm:$false
            Test-XLDConfigurationItem -RepositoryId Environments/Directory | Should Be $False
        }

        It 'remove an applications version' {
            Remove-XLDConfigurationItem -RepositoryId Applications/NerdDinner/2.0 -Confirm:$false
            Test-XLDConfigurationItem -RepositoryId Applications/NerdDinner/2.0 | Should Be $False
            Remove-XLDConfigurationItem -RepositoryId Applications/PetClinic-ear/1.0 -Confirm:$false
            Test-XLDConfigurationItem -RepositoryId Applications/PetClinic-ear/1.0 | Should Be $False
        }
        It 'remove an application' {
            Remove-XLDConfigurationItem -RepositoryId Applications/NerdDinner -Confirm:$false
            Test-XLDConfigurationItem -RepositoryId Applications/NerdDinner | Should Be $False
            Remove-XLDConfigurationItem -RepositoryId Applications/PetClinic-ear -Confirm:$false
            Test-XLDConfigurationItem -RepositoryId Applications/PetClinic-ear | Should Be $False
        }
    }
}
