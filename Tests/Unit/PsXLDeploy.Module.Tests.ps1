
$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
$null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

Get-Module PsXLDeploy | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\PsXLDeploy" -Force

Describe ('Running Module {0} Tests' -f 'PsXLDeploy') {

    $ModuleRoot = "$PSScriptRoot\..\..\PsXLDeploy"
    $PublicFiles = Get-ChildItem "$ModuleRoot\Public" -Recurse -Filter *.ps1 | Sort-Object

    It 'Contains expected helper files and directories' {
        "$ModuleRoot\Private\" | Should Exist
        "$ModuleRoot\Public" | Should Exist
        "$ModuleRoot\..\LICENSE.md" | Should Exist
        "$ModuleRoot\..\README.md" | Should Exist
    }

    Context 'Verify .psd1 module file' {
        It 'Has a valid .psd1 module manifest' {
            $ModuleManifest = Test-ModuleManifest -Path "$ModuleRoot\PsXLDeploy.psd1" -ErrorAction Stop
        }

        $ModuleManifest = Test-ModuleManifest -Path "$ModuleRoot\PsXLDeploy.psd1" -ErrorAction Stop

        It 'Static .psd1 values have not changed' {
            $ModuleManifest.RootModule | Should BeExactly 'PsXLDeploy.psm1'
            $ModuleManifest.Name | Should BeExactly 'PsXLDeploy'
            #$ModuleManifest.Version -as [Version] | Should BeGreaterThan '1.0.0'
            $ModuleManifest.Guid | Should BeExactly '85aaff1a-c696-43ad-be1a-53d16477d01d'
        }

        $PsXLDeployCommands = (Get-Command -Module PsXLDeploy).Name

        It 'Exports expected functions' {
            $PublicFiles.BaseName | Should BeExactly $PsXLDeployCommands
        }

        It -name 'Should have a PsXLDeploy.xml' -test {
            $Config = Import-Clixml -Path $Path
            $Props= $Config.PSObject.Properties.Name
            $Props -contains 'Uri' | Should be $True
        }
    }

    Describe -Name 'Setting PsXLDeploy.xml config' -Fixture {

        $XLDURi = 'http://localhost:4516'
        $AlternativePath = "$env:Temp\PsXLDeploy.xml"

        It -name 'Should set PsXLDeploy.xml' -test {
            Set-XLDConfig -Uri $XLDUri
            $Config = Import-Clixml -Path $Path
            $Config.Uri | Should be $XLDUri
        }

        It -name 'Should set a user-specified file' -test {
            $Params = @{
                Uri= $XLDUri
                Path = $AlternativePath
            }

            Set-XLDConfig @Params

            $Config = Import-Clixml -Path $AlternativePath
            $Config.Uri | Should be $XLDUri
        }

        It -name "should accept only valid urls" -test {
            { Set-XLDConfig -Uri '' } | Should Throw
            { Set-XLDConfig -Uri 'wrongurl' } | Should Throw
            { Set-XLDConfig -Uri 'ftp://localhost' } | Should Throw

            Set-XLDConfig -Uri 'http://localhost' | Should BeNullOrEmpty
            Set-XLDConfig -Uri 'https://localhost'  | Should BeNullOrEmpty
            Set-XLDConfig -Uri 'http://localhost:8085'  | Should BeNullOrEmpty
            Set-XLDConfig -Uri 'https://localhost:8085' | Should BeNullOrEmpty
        }
    }

    Describe -Name 'Reading PsXLDeploy.Xml config' -Fixture {

        $XLDURi = 'http://localhost:4516'
        $AlternativePath = "$env:Temp\PsXLDeploy.xml"

        # We've tested set... use it here.
        Set-XLDConfig -Uri $XLDUri

        It -name 'Should read PsXLDeploy.xml' -test {
            $Config = Get-XLDConfig -Source PsXLDeploy.xml
            $Config.Uri | Should be $XLDUri
        }

        It -name 'Should read XLDConfig variable' -test {
            $Config = Get-XLDConfig -Source XLDConfig
            $Config.Uri | Should be $XLDUri
        }

        It -name 'Should read a user-specified file' -test {
            $Params = @{
                Uri= $XLDUri
                Path = $AlternativePath
            }

            Set-XLDConfig @Params

            $Config = Get-XLDConfig -Path $AlternativePath
            $Config.Uri | Should be $XLDUri
        }
    }
}

Describe "Invoke-XLDRestMethod" {
    # Mock data
    Mock  -CommandName Invoke-RestMethod { return $Uri } -ModuleName PsXLDeploy

    Context "-Resource" {
        $dummy = Invoke-XLDRestMethod -Resource 'dummy'
        it "Appends resource to url" { { [uri]$dummy } | Should not throw
            $dummy.AbsolutePath -replace '/deployit/' | Should Be 'dummy'
        }
    }

    Context "-UriParams" {
        $dummy = Invoke-XLDRestMethod -Resource 'dummy' -UriParams @{test='test'}
        it "test" {
            { [uri]$dummy } | Should not throw
            $dummy.Query.StartsWith('?test=test&') | Should be $True
        }
    }
}

Describe "Set-XLDAuthentication" {
    # Mock data
    $SecurePassword = ConvertTo-SecureString 'password' -AsPlainText -Force
    $credential = New-Object -TypeName pscredential ('admin',$SecurePassword)
    $ExpectedToken='YWRtaW46cGFzc3dvcmQ='

    Mock Invoke-RestMethod { return $Headers } -ModuleName PsXLDeploy

    Context "by Credential parameter" {

        Set-XLDAuthentication -Credential $credential

        it "AuthToken should present as a Header" {
            $dummy = Invoke-XLDRestMethod -Resource 'dummy'
            $dummy | Should Not BeNullOrEmpty
            $dummy.Authorization | Should Be "Basic $ExpectedToken"
        }
    }
}

Describe -Name 'Get-XLDServerInfo' {

    Mock Invoke-RestMethod { } -ModuleName PsXLDeploy

    It 'runs without errors' {
        { Get-XLDServerInfo } | Should Not Throw
    }
}

Describe -Name 'Get-XLDServerState' {

    Mock Invoke-RestMethod { } -ModuleName PsXLDeploy

    It 'runs without errors' {
        { Get-XLDServerState } | Should Not Throw
    }
}

Describe -Name 'Start-XLDMaintenance' {

    Mock Invoke-RestMethod { } -ModuleName PsXLDeploy

    It 'runs without errors' {
        { Start-XLDMaintenance } | Should Not Throw
    }

}

Describe -Name 'Stop-XLDMaintenance' {

    Mock Invoke-RestMethod { } -ModuleName PsXLDeploy

    It 'runs without errors' {
        { Stop-XLDMaintenance } | Should Not Throw
    }

}

Describe -Name 'Get-XLDDescriptors' {

    Mock -CommandName Invoke-RestMethod { } -ModuleName PsXLDeploy

    It 'runs without errors' {
        { Get-XLDDescriptor } | Should Not Throw
    }
}

Describe -Name 'Get-XLDOrchestrator' {

    Mock Invoke-RestMethod {} -ModuleName PsXLDeploy

    It 'runs without errors' {
        { Get-XLDOrchestrator } | Should Not Throw
    }
}

Describe -Name 'New-ConfigurationItem' {
    InModuleScope PsXLDeploy {

        Context -name 'xml iis.Server' {
            $XLDIISServer = New-ConfigurationItem -RepositoryId iisServer -type iis.Server -overthereHostid container
            It 'has atribute id' {
                { $XLDIISServer | Select-Xml -XPath ("//iis.Server[@id='iisServer']") } | Should Not Throw
            }

            It 'has element host with attribute' {
                { $XLDIISServer | Select-Xml -XPath ("//iis.Server[@id='iisServer']/host[@ref='container']") } | Should not Throw
            }

            Context -name '-tag' {
                $XLDIISServer = New-ConfigurationItem -RepositoryId iisServer -type iis.Server -overthereHostid container -tags tag
                It 'has element tags with childelement value with #text' {
                    ($XLDIISServer | Select-Xml -XPath ("//iis.Server[@id='iisServer']/tags/value[. ='tag']")).Node.InnerText | Should be 'tag'
                }
            }

            Context -name '-deploymentGroup' {
                $XLDIISServer = New-ConfigurationItem -RepositoryId iisServer -type iis.Server -overthereHostid container -deploymentGroup 1
                It 'has element deploymentGroup with with #text' {
                    ($XLDIISServer | Select-Xml -XPath ("//iis.Server[@id='iisServer']/deploymentGroup[. ='1']")).Node.InnerText | Should be '1'
                }
            }

            Context -name '-deploymentSubGroup' {
                $XLDIISServer = New-ConfigurationItem -RepositoryId iisServer -type iis.Server -overthereHostid container -deploymentSubGroup 1
                It 'has element deploymentSubGroup with with #text' {
                    ($XLDIISServer | Select-Xml -XPath ("//iis.Server[@id='iisServer']/deploymentSubGroup[. ='1']")).Node.InnerText | Should be '1'
                }
            }

            Context -name '-deploymentSubSubGroup' {
                $XLDIISServer = New-ConfigurationItem -RepositoryId iisServer -type iis.Server -overthereHostid container -deploymentSubSubGroup 1
                It 'has element deploymentSubSubGroup with with #text' {
                    ($XLDIISServer | Select-Xml -XPath ("//iis.Server[@id='iisServer']/deploymentSubSubGroup[. ='1']")).Node.InnerText | Should be '1'
                }
            }
        }
    }
}
