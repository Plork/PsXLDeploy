
$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
$null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

Get-Module PsXLDeploy | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\PsXLDeploy" -Force

InModuleScope -ModuleName PsXLDeploy {

    Describe -Name 'adds tag' {

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

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { return $overthereHost } -ParameterFilter { $Resource -eq 'repository/ci/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationITem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('tags {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                It 'add tag' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.xml)
                    Add-XLDTag @InputParams -tags tag1

                    $tags = ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags")).Node.Value
                    'tag1' -in $tags | Should be $true
                }

                It 'does not throw when adding tag that exists' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.xml)
                    Add-XLDTag @InputParams -tags tag1

                    $XLDTagScriptBlock = { Add-XLDTag -RepositoryId Infrastructure/overthereHost -tags tag1 }
                    $XLDTagScriptBlock | Should not Throw
                }

                It 'adds multiple tags' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.xml)
                    Add-XLDTag @InputParams -tags tag1,tag2

                    $tags = ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags")).Node.Value
                    'tag1' -in $tags | Should be $true
                    'tag2' -in $tags | Should be $true
                }

                It 'adding additional tag does not remove existing tag' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.xml)
                    Add-XLDTag @InputParams -tags tag1
                    Add-XLDTag @InputParams -tags tag2

                    $tags = ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags")).Node.Value
                    'tag1' -in $tags | Should be $true
                    'tag2' -in $tags | Should be $true
                }

                It 'throws when host does not exist' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
                    $XLDTagSCriptBlock = { Add-XLDTag @InputParams -tags tag1 }

                    $XLDTagSCriptBlock | Should Throw
                }
            }
        }
        Context 'udm.Dictionary' {

            It 'throws when not valid for tags' {
                [xml]$udmDictionary = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                Mock Invoke-XLDRestMethod -MockWith { return $udmDictionary } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }

                $XLDTagSCriptBlock = { Add-XLDTag -RepositoryId Environments/Dictionary -tags tag1 }
                $XLDTagSCriptBlock | Should Throw
            }
        }
    }

    Describe -Name 'removes tag' {

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

        BeforeAll {
            $MockHash = @{
                result = ''
            }
        }

        Mock Invoke-XLDRestMethod -MockWith { return $overthereHost } -ParameterFilter { $Resource -eq 'repository/ci/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
        Mock Invoke-XLDRestMethod -MockWith { $MockHash.Result = $ConfigurationItem; return $ConfigurationItem } -ParameterFilter { $Method -eq 'PUT' }

        ForEach ($Context in $Hash) {

            Context ('tags {0}' -f $Context.Type) {

                $InputParams = $Context.Params

                It 'removes tag' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.Full.xml)
                    Remove-XLDTag @InputParams -tags tag1

                    $tags = ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags")).Node.Value
                    'tag1' -notin $tags | Should be $true
                }

                It 'does not throw when removing tag that does not exists' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.Full.xml)
                    $XLDTagScriptBlock = { Remove-XLDTag @InputParams -tags tag }
                    $XLDTagScriptBlock | Should not Throw
                }

                It 'removes multiple tags' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.Full.xml)
                    Remove-XLDTag @InputParams -tags tag1,tag2

                    $tags = ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags")).Node.Value
                    'tag1' -notin $tags | Should be $true
                    'tag2' -notin $tags | Should be $true
                }

                It 'removing tag only removes specified tag' {
                    [xml]$overthereHost = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath overthere.SshHost.Full.xml)
                    Remove-XLDTag @InputParams -tags tag1

                    $tags = ($MockHash.Result | Select-Xml -XPath ("//overthere.SshHost[@id='Infrastructure/overthereHost']/tags")).Node.Value
                    'tag1' -notin $tags | Should be $true
                    'tag2' -notin $tags | Should be $false
                }

                It 'throws when host does not exist' {
                    Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "false" } } -ParameterFilter { $Resource -eq 'repository/exists/Infrastructure/overthereHost' }
                    $XLDTagSCriptBlock = { Remove-XLDTag @InputParams -tags tag1 }

                    $XLDTagSCriptBlock | Should Throw
                }
            }
        }

        Context 'udm.Dictionary' {

            It 'throws when not valid for tags' {
                [xml]$udmDictionary = Get-Content (Join-Path "$PsScriptRoot\Artifacts" -ChildPath udm.Dictionary.xml)
                Mock Invoke-XLDRestMethod -MockWith { return $udmDictionary } -ParameterFilter { $Resource -eq 'repository/ci/Environments/Dictionary' }
                Mock Invoke-XLDRestMethod -MockWith { New-Object -typename psobject -property @{ boolean = "true" } } -ParameterFilter { $Resource -eq 'repository/exists/Environments/Dictionary' }

                $XLDTagSCriptBlock = { Remove-XLDTag -RepositoryId Environments/Dictionary -tags tag1 }
                $XLDTagSCriptBlock | Should Throw
            }
        }
    }
}
