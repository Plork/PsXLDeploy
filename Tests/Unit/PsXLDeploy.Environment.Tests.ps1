
$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
$null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

Get-Module PsXLDeploy | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\PsXLDeploy" -Force

InModuleScope -ModuleName PsXLDeploy {

    $Hash = @(
        @{
            Type = 'by Id'
            Params = @{
                RepositoryId = 'Environments/Environment'
            }
        }
        @{
            Type = 'by name'
            Params = @{
                Name = 'Environment'
                Folder = 'Environments'
            }
        }
    )

    Describe -Name 'new environment' {

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments' }

        ForEach ($Context in $Hash) {

            Context $Context.Type {

                $InputParams = $Context.Params

                $EnvironmentParams = @{
                    Members = @('container1', 'container2')
                    Dictionaries = @('dictionary1', 'dictionary2')
                }

               $HashResults = @{
                    Members = @('container1', 'container2')
                    Dictionaries = @('dictionary1', 'dictionary2')
                }

                Context 'response xml returned as object' {
                    Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironmentXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
                    [xml]$udmEnvironmentXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.Full.xml)

                    $XLDEnvironment = New-XLDEnvironment @InputParams @EnvironmentParams

                    It 'creates environment' {
                        $XLDEnvironment.RepositoryId | Should Be 'Environments/Environment'
                        $XLDEnvironment.Type | Should Be 'udm.Environment'
                    }

                    It 'creates environment with attached members' {
                        $XLDEnvironment.Members | Should Be $HashResults.Members
                    }

                    It 'created environments members is of type array' {
                         Write-Output -NoEnumerate $XLDEnvironment.Members | Should BeOfType [array]
                    }

                    It 'creates environment with attached dictionaries' {
                        $XLDEnvironment.Dictionaries | Should Be $HashResults.Dictionaries
                    }

                    It 'created environments dictionaries is of type array' {
                         Write-Output -NoEnumerate $XLDEnvironment.Dictionaries | Should BeOfType [array]
                    }
                }

                Context 'created xml body' {
                    Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'POST' }
                    $XLDEnvironment = New-XLDEnvironment @InputParams @EnvironmentParams

                    It 'xml has attribute id' {
                        ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']")).Node | Should Not BeNullOrEmpty
                    }

                    It 'xml has element members with childelement ci with attribute' {
                        ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/members/ci")).Node.Ref | Should be $HashResults.Members
                    }

                    It 'xml has element dictionaries with childelement ci with attribute' {
                        ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/dictionaries/ci")).Node.Ref | Should be $HashResults.Dictionaries
                    }
                }

                Context 'exists returns false' {
                    It 'throws when environment already exists' {
                        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
                        $XLDEnvironmentScriptBlock = { New-XLDEnvironment @InputParams @EnvironmentParams }

                        $XLDEnvironmentScriptBlock | Should Throw
                    }
                }
            }
        }
    }

    Describe -Name 'get environment' {

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironment } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationItem } -ParameterFilter { $Method -eq 'POST' }

        ForEach ($Context in $Hash) {

            Context ('environment {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                $HashResults = @{
                    Members = @('container1', 'container2')
                    Dictionaries = @('dictionary1', 'dictionary2')
                }

                [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.Full.xml)
                $XLDEnvironment = Get-XLDEnvironment @InputParams

                It 'returns environment' {

                    $XLDEnvironment.RepositoryId | Should Be 'Environments/Environment'
                    $XLDEnvironment.Type | Should Be 'udm.Environment'
                    Write-Output -NoEnumerate $XLDEnvironment.Members | Should BeOfType [array]
                    $XLDEnvironment.Members | Should Be $HashResults.Members
                    Write-Output -NoEnumerate $XLDEnvironment.Dictionaries | Should BeOfType [array]
                    $XLDEnvironment.Dictionaries | Should Be $HashResults.Dictionaries
                }

                It 'throws when environment does not exists' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }

                    $XLDEnvironmentScriptBlock = { Get-XLDEnvironment @InputParams }
                    $XLDEnvironmentScriptBlock | Should Throw
                }
            }
        }

        Context 'udm.Dictionary' {

            It 'throws when not an environment' {
                [xml]$udmDictionary = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                Mock Invoke-XLDRestMethod -MockWith { return $udmDictionary } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }

                $XLDDirectoryScriptBlock = { Get-XLDEnvironment -RepositoryId Environments/Dictionary }
                $XLDDirectoryScriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'Add members to environment' {

        BeforeEach {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironment } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('environment {0}' -f $Context.Type) {


                $InputParams = $Context.Params

                It 'add member to environment' {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                    Add-XLDEnvironmentMember @InputParams -Members container

                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/members/ci[@ref='container']")).Node | Should not BeNullorEmpty
                }

                It "doesn't throw when adding already existing member" {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                    Add-XLDEnvironmentMember @InputParams -Members container

                    $XLDEnvironmentScriptBlock = { Add-XLDEnvironmentMember @InputParams -Members container }
                    $XLDEnvironmentScriptBlock | Should not Throw
                }

                It 'add dictionary to environment' {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)

                    Add-XLDEnvironmentMember @InputParams -Dictionaries dictionary
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/dictionaries/ci[@ref='dictionary']")).Node | Should not BeNullorEmpty
                }

                It "doesn't throw when adding already existing member" {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                    Add-XLDEnvironmentMember @InputParams -Dictionaries dictionary

                    $XLDEnvironmentScriptBlock = { Add-XLDEnvironmentMember @InputParams -Dictionaries dictionary }
                    $XLDEnvironmentScriptBlock | Should not Throw
                }

                It "throws when environment does not exist" {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }

                    $XLDEnvironmentScriptBlock = { Add-XLDEnvironmentMember @InputParams -Dictionaries dictionary }
                    $XLDEnvironmentScriptBlock | Should Throw
                }
            }
        }

        Context 'udm.Dictionary' {

            It 'throws when not an environment' {
                [xml]$udmDictionary = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                Mock Invoke-XLDRestMethod -MockWith { return $udmDictionary } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }


                $XLDDirectoryScriptBlock = { Add-XLDEnvironmentMember -RepositoryId 'Environments/Dictionary' -Members container }
                $XLDDirectoryScriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'remove members from environment' {

        BeforeEach {
            $mockhash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironment } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('environment {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                It 'removes member from environment' {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.Full.xml)

                    Remove-XLDEnvironmentMember @InputParams -Members container1
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/members/ci[@ref='container1']")).Node | Should BeNullorEmpty
                }

                It 'removing member from environment does not remove other members' {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.Full.xml)

                    Remove-XLDEnvironmentMember @InputParams -Members container1
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/members/ci[@ref='container1']")).Node | Should BeNullorEmpty
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/members/ci[@ref='container2']")).Node.Ref | Should Be 'container2'
                }

                It 'removes dictionary from environment' {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.Full.xml)

                    Remove-XLDEnvironmentMember @InputParams -Dictionaries dictionary1
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/dictionaries/ci[@ref='dictionary1']")).Node | Should BeNullorEmpty
                }

                It 'removing dictionary from environment does not remove other dictionaries' {
                    [xml]$udmEnvironment = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.Full.xml)

                    Remove-XLDEnvironmentMember @InputParams -Dictionaries dictionary1
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/dictionaries/ci[@ref='dictionary1']")).Node | Should BeNullOrEmpty
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Environment[@id='Environments/Environment']/dictionaries/ci[@ref='dictionary2']")).Node.Ref | Should Be 'dictionary2'

                }

                It "throws when environment does not exist" {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }

                    $XLDEnvironmentScriptBlock = { Remove-XLDEnvironmentMember @InputParams -Dictionaries dictionary }
                    $XLDEnvironmentScriptBlock | Should Throw
                }
            }
        }

        Context 'udm.Dictionary' {

            It 'throws when not an environment' {
                [xml]$udmDictionary = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                Mock Invoke-XLDRestMethod -MockWith { return $udmDictionary } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }

                $XLDDirectoryScriptBlock = { Remove-XLDEnvironmentMember -RepositoryId 'Environments/Dictionary' -Members container }
                $XLDDirectoryScriptBlock | Should Throw
            }
        }
    }
}
