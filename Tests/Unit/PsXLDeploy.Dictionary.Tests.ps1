
$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
$null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

Get-Module PsXLDeploy | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\PsXLDeploy" -Force

InModuleScope -ModuleName PsXLDeploy {

    Describe -Name 'new dictionary' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Dictionary'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Dictionary'
                    Folder = 'Environments'
                }
            }
        )

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments' }

        ForEach ($Context in $Hash) {

            Context $Context.Type {

                $InputParams = $Context.Params

                $DictionaryParams = @{
                    Entries = @{
                        key1 = 'value1'
                    }
                    restrictToContainers = 'container1'
                    restrictToApplications = 'application1'
                }

                Context 'response xml returned as object' {

                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.Full.xml)
                    Mock Invoke-XLDRestMethod -MockWith { return $udmDictionaryXML } -ParameterFilter { $Method -eq 'POST' }

                    $XLDDictionary = New-XLDDictionary @InputParams @DictionaryParams

                    It 'creates dictionary' {
                        $XLDDictionary.RepositoryId | Should Be 'Environments/Dictionary'
                        $XLDDictionary.Type | Should Be 'udm.Dictionary'
                    }
                    It 'creates dictionary with container restrictions' {
                        $XLDDictionary.restrictToContainers -contains 'container1' | Should be $true
                    }
                    It 'creates dictionary with application restrictions' {
                        $XLDDictionary.restrictToApplications -contains 'application1' | Should be $true
                    }
                    It 'creates dictionary with entries' {
                        $XLDDictionary.entries | Should BeOfType hashtable
                        $XLDDictionary.entries.ContainsKey('key1') | Should Be $true
                        $XLDDictionary.entries.ContainsValue('value1') | Should Be $true
                    }
                }

                # check if correct XML is created with input parameters that will be send to the API
                Context 'created xml body' {
                    Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'POST' }

                    $XLDDictionary = New-XLDDictionary @InputParams @DictionaryParams

                    It 'xml has attribute id' {
                        ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']")).Node | Should Not BeNullOrEmpty
                    }
                    It 'xml has element entries with childelement entry with #text' {
                        ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/entries/entry[@key='key1']")).Node.InnerText | Should Be 'value1'
                    }
                    It 'xml has element restrictToContainers with childelement ci with attribute' {
                        ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/restrictToContainers/ci[@ref='container1']")).Node | Should Not BeNullOrEmpty
                    }

                    It 'xml has element restrictToApplications with childelement ci with attribute' {
                        ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/restrictToApplications/ci[@ref='application1']")).Node | Should Not BeNullOrEmpty
                    }
                }

                Context 'exists returns false' {
                    It 'throws when dictionary already exist' {
                        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
                        $XLDDictionaryScriptBlock = { New-XLDDictionary @InputParams @DictionaryParams }

                        $XLDDictionaryScriptBlock | Should Throw
                    }
                }
            }
        }
    }

    Describe -Name 'new dictionary in subfolder' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Folder/Dictionary'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Dictionary'
                    Folder = 'Environments/Folder'
                }
            }
        )

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Folder/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Folder' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'POST' }

        ForEach ($Context in $Hash) {

            Context $Context.Type {

                $InputParams = $Context.Params

                $DictionaryParams = @{
                    Entries = @{
                        key = 'value'
                    }
                    restrictToContainers = 'container'
                    restrictToApplications = 'application'
                }

                $XLDDictionary = New-XLDDictionary @InputParams @DictionaryParams

                It 'throws when folder does not exists' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Folder' }
                    $XLDDictionaryScriptBlock = { New-XLDDictionary @InputParams @DictionaryParams }

                    $XLDDictionaryScriptBlock | Should Throw
                }

                It 'creates folder when force specified' {

                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Folder' }
                    $XLDDictionaryScriptBlock = { New-XLDDictionary @InputParams @DictionaryParams -Force }

                    $XLDDictionaryScriptBlock | Should Not Throw
                }
            }
        }
    }

    Describe -Name 'gets dictionary' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Dictionary'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Dictionary'
                    Folder = 'Environments'
                }
            }
        )

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { return $udmDictionaryXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'POST' }

        ForEach ($Context in $Hash) {

            Context ('environment {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                $HashResults = @{
                    EntryKeys = @('key1', 'key2')
                    EntryValues = @('value1', 'value2')
                    restrictToContainers = @('container1', 'container2')
                    restrictToApplications = @('application1', 'application2')
                }

                Context 'response xml returned as object' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.Full.xml)
                    $XLDDictionary = Get-XLDDictionary @InputParams

                    It 'returns dictionary' {
                        $XLDDictionary.RepositoryId | Should Be 'Environments/Dictionary'
                        $XLDDictionary.Type | Should Be 'udm.Dictionary'
                    }
                    It 'returns dictionary with container restrictions' {
                        $XLDDictionary.restrictToContainers -contains 'container1' | Should be $true
                    }
                    It 'returned restrictToContainers is array' {
                        Write-Output -NoEnumerate $XLDDictionary.restrictToContainers | Should BeofType [Array]
                    }
                    It 'returns dictionary with application restrictions' {
                        $XLDDictionary.restrictToApplications -contains 'application1' | Should be $true
                    }
                    It 'returned restrictToApplications is array' {
                        Write-Output -NoEnumerate $XLDDictionary.restrictToApplications | Should BeofType [Array]
                    }
                    It 'returns dictionary with entries' {
                        $XLDDictionary.Entries | Should BeOfType hashtable
                        $XLDDictionary.Entries.ContainsKey('key1') | Should Be $true
                        $XLDDictionary.Entries.ContainsValue('value1') | Should Be $true
                        $XLDDictionary.Entries.Keys.Count | Should Be 2
                    }
                    It 'returned entries is hashtable' {
                        $XLDDictionary.Entries | Should BeofType [Hashtable]
                    }
                }
            }

            Context 'exists returns false' {
                It 'throws when dictionary does not exist' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
                    $XLDDictionaryScriptBlock = { Get-XLDDictionary @InputParams }

                    $XLDDictionaryScriptBlock | Should Throw
                }
            }

            Context 'udm.Environment' {
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
                Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironmentXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }

                It 'throws when not a dictionary' {
                    [xml]$udmEnvironmentXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                    $XLDDictionaryScriptBlock = { Get-XLDDictionary @InputParams }

                    $XLDDictionaryScriptBlock | Should Throw
                }
            }
        }
    }

    Describe -Name 'adds restrictions to dictionary' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Dictionary'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Dictionary'
                    Folder = 'Environments'
                }
            }
        )


        BeforeEach {
            $MockHash = @{
                result = ''
            }
        }

        # adds modified XML body to mockhash to test
        Mock Invoke-XLDRestMethod -MockWith { return $udmDictionaryXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironmentXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context $Context.Type {


                $InputParams = $Context.Params

                It 'restricts container to dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                    Add-XLDDictionaryRestrict @InputParams -restrictToContainers container

                    ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/restrictToContainers/ci[@ref='container']")).Node | Should not BeNullorEmpty
                }

                It 'restricts application to dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                    Add-XLDDictionaryRestrict @InputParams -restrictToApplications application

                    ($MockHash.Result  | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/restrictToApplications/ci[@ref='application']")).Node | Should not BeNullorEmpty
                }

                It 'throws when dictionary does not exist' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
                    $XLDDictionaryScriptBlock = { Add-XLDDictionaryRestrict @InputParams -restrictToContainers container }

                    $XLDDictionaryScriptBlock | Should Throw
                }


            }
        }

        Context 'udm.Environment' {
            It 'throws when not a dictionary' {
                [xml]$udmEnvironmentXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                $XLDDictionaryScriptBlock = { Add-XLDDictionaryRestrict -RepositoryId Environments/Environment -restrictToContainers container }

                $XLDDictionaryScriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'adds dictionary entries' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Dictionary'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Dictionary'
                    Folder = 'Environments'
                }
            }
        )


        BeforeEach {
            $MockHash = @{
                result = ''
            }
        }

        # adds modified XML body to mockhash to test
        Mock Invoke-XLDRestMethod -MockWith { return $udmDictionaryXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironmentXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('environment {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                It 'adds entry to dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                    Set-XLDDictionaryEntry @InputParams -Entries @{key = 'value'}

                    ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/entries/entry[@key='key']")).Node | Should not BeNullorEmpty
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/entries/entry[@key='key']/text()")).Node.InnerText | Should Be 'value'
                }

                It 'replaces value in dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                    Set-XLDDictionaryEntry @InputParams -Entries @{key = 'value'}
                    Set-XLDDictionaryEntry @InputParams -Entries @{key = 'value2'}

                    ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/entries/entry[@key='key']")).Node | Should not BeNullorEmpty
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/entries/entry[@key='key']/text()")).Node.InnerText | Should Be 'value2'
                }

                It 'throws when dictionary does not exist' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
                    $XLDDictionaryScriptBlock = {  Set-XLDDictionaryEntry @InputParams -Entries @{key = 'value'} }

                    $XLDDictionaryScriptBlock | Should Throw
                }


            }
        }

        Context 'udm.Environment' {
            It 'throws when not a dictionary' {
                [xml]$udmEnvironmentXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                $XLDDictionaryScriptBlock = { Set-XLDDictionaryEntry -RepositoryId Environments/Environment -Entries @{key = 'value'} }

                $XLDDictionaryScriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'removes dictionary entries' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Dictionary'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Dictionary'
                    Folder = 'Environments'
                }
            }
        )


        BeforeEach {
            $MockHash = @{
                result = ''
            }
        }

        # adds modified XML body to mockhash to test
        Mock Invoke-XLDRestMethod -MockWith { return $udmDictionaryXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironmentXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('environment {0}' -f $Context.Type) {


                $InputParams = $Context.Params

                It 'removes entries from dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.Full.xml)

                    Remove-XLDDictionaryEntry @InputParams -Entries key1
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/entries/entry[@key='key1']")).Node | Should BeNullorEmpty
                }

                It 'does not fail when removing non existing entry from dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.Full.xml)

                    { Remove-XLDDictionaryEntry @InputParams -Entries key } | Should Not Throw
                }

                It 'throws when dictionary does not exist' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
                    $XLDDictionaryScriptBlock = { Remove-XLDDictionaryEntry @InputParams -Entries key }

                    $XLDDictionaryScriptBlock | Should Throw
                }


            }
        }

        Context 'udm.Environment' {
            It 'throws when not a dictionary' {
                [xml]$udmEnvironmentXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                $XLDDictionaryScriptBlock = { Remove-XLDDictionaryEntry -RepositoryId Environments/Environment -Entries key }

                $XLDDictionaryScriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'removes dictionary restrictions' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Dictionary'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Dictionary'
                    Folder = 'Environments'
                }
            }
        )


        BeforeEach {
            $MockHash = @{
                result = ''
            }
        }

        # adds modified XML body to mockhash to test
        Mock Invoke-XLDRestMethod -MockWith { return $udmDictionaryXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { return $udmEnvironmentXML } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Environment' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('environment {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                It 'removes restricted container from dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.Full.xml)

                    Remove-XLDDictionaryRestrict @InputParams -Containers container1
                    ($MockHash.Result | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/restrictToContainers/ci[@ref='container1']")).Node | Should BeNullorEmpty
                }

                It 'removes restricted application from dictionary' {
                    [xml]$udmDictionaryXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.Full.xml)

                    Remove-XLDDictionaryRestrict @InputParams -Applications application1
                    ($MockHash.Result  | Select-Xml -XPath ("//udm.Dictionary[@id='Environments/Dictionary']/restrictToApplications/ci[@ref='application1']")).Node | Should BeNullorEmpty
                }

                It 'throws when dictionary does not exist' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }
                    $XLDDictionaryScriptBlock = { Remove-XLDDictionaryRestrict @InputParams -Containers container }

                    $XLDDictionaryScriptBlock | Should Throw
                }
            }
        }

        Context 'udm.Environment' {
            It 'throws when not a dictionary' {
                [xml]$udmEnvironmentXML = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Environment.xml)
                $XLDDictionaryScriptBlock = { Remove-XLDDictionaryRestrict -RepositoryId Environments/Environment -Containers container }

                $XLDDictionaryScriptBlock | Should Throw
            }
        }
    }
}
