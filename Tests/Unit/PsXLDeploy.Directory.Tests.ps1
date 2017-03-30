
$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
$null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

Get-Module PsXLDeploy | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\PsXLDeploy" -Force

InModuleScope -ModuleName PsXLDeploy {

    Describe -Name 'new directory' {

        BeforeEach {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'POST' }

        It 'creates directory' {

            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Directory' }
            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments' }

            $XLDDirectory = New-XLDDirectory -RepositoryId 'Environments/Directory'
            $XLDDirectory.RepositoryId | Should Be 'Environments/Directory'
            $XLDDirectory.Type | Should Be 'core.Directory'
        }

        It 'throws when directory already exists' {

            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Directory' }

            $XLDDirectoryScriptBlock = { New-XLDDirectory -RepositoryId 'Environments/Directory' }
            $XLDDirectoryScriptBlock | Should Throw
        }

        It 'xml has atribute id' {

            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Directory' }
            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments' }

            $null = New-XLDDirectory -RepositoryId 'Environments/Directory'
            ($MockHash.Result | Select-Xml -XPath ("//core.Directory[@id='Environments/Directory']")).Node | Should Not BeNullOrEmpty
        }

        It 'throws when parent directory does not exist' {

            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Parent/Parent/Directory' }
            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Parent/Parent' }
            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Parent' }

            $XLDDirectoryScriptBlock = { New-XLDDirectory -RepositoryId 'Environments/Parent/Parent/Directory' }
            $XLDDirectoryScriptBlock | Should Throw
        }

        It 'creates parent directory with recurse' {

            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Parent/Parent/Directory' }
            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Parent/Parent' }
            Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Parent' }

            $XLDDirectory = New-XLDDirectory -RepositoryId 'Environments/Parent/Parent/Directory' -recurse
            $XLDDirectory.RepositoryId | Should Be 'Environments/Parent/Parent/Directory'
            $XLDDirectory.Type | Should Be 'core.Directory'
        }
    }

    Describe -Name 'gets directory' {

        $Hash = @(
            @{
                Type = 'by Id'
                Params = @{
                    RepositoryId = 'Environments/Directory'
                }
            }
            @{
                Type = 'by name'
                Params = @{
                    Name = 'Directory'
                    Folder = 'Environments'
                }
            }
        )

        BeforeEach {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { return $coreDirectory } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Directory' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Directory' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'POST' }

        ForEach ($Context in $Hash) {

            Context ('directory {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                It 'returns directory' {

                    [xml]$coreDirectory = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath core.Directory.xml)

                    $XLDDirectory = Get-XLDDirectory @InputParams
                    $XLDDirectory.RepositoryId | Should Be 'Environments/Directory'
                    $XLDDirectory.Type | Should Be 'core.Directory'
                }
            }
        }

        Context 'udm.Dictionary' {

            It 'throws when not a directory' {
                [xml]$udmDictionary = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                Mock Invoke-XLDRestMethod -MockWith { return $udmDictionary } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }

                $XLDDirectoryScriptBlock = { Get-XLDDirectory -RepositoryId 'Environments/Dictionary' }
                $XLDDirectoryScriptBlock | Should Throw
            }
        }
    }
}
