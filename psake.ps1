Properties -properties {

    # Find the build folder based on build system
    $ProjectRoot = $ENV:BHProjectPath
    If(-not $ProjectRoot)
    {
        $ProjectRoot = $PSScriptRoot
    }

    $PSVersion = $PSVersionTable.PSVersion.Major
    $lines = '----------------------------------------------------------------------'   

    $Verbose = @{}
    If($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}

FormatTaskName -format {
    param($taskName)
    $lines
    "`r`n- Executing Task: $taskName -" 
}

Task -name default -depends Deploy

Task Init {
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task -name Analyze -Depends Init -action {
    "`n`tSTATUS: Analyzing with PowerShell Scriptanalyzer"

    $saResults = Invoke-ScriptAnalyzer -Path (Join-Path $ProjectRoot (Get-ProjectName)) `
    -Severity @('Error') `
    -ExcludeRule @('PSMissingModuleManifestField', 'PSUseShouldProcessForStateChangingFunctions', 'PSAvoidGlobalVars', 'PSUseToExportFieldsInManifest') `
    -Recurse -Verbose:$false
    If ($saResults) 
    {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}

Task -name Test -Depends Analyze -action {
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    $testResults = Invoke-Pester -Path $ProjectRoot -PassThru
    If ($testResults.FailedCount -gt 0) 
    {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

Task -name Build -Depends Test -action {   
    "`n`tSTATUS: update the psd1 with FunctionsToExport"
    Set-ModuleFunctions

    $Existing = $null
    $Existing = Find-Module -Name $ENV:BHProjectName -Repository $ENV:PSRepository -ErrorAction SilentlyContinue

    If ($Existing){
        $Version = Get-NextPSGalleryVersion -Name $ENV:BHProjectName -Repository $ENV:PSRepository
    }
    Else {
        $Version = [version]'1.0.0'
    }

    "`n`tSTATUS: setting version to $version"
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $Version
}

Task -name Deploy -depends Build -action {
    $lines

    # Gate deployment
    If(
        $ENV:BHBranchName -eq "master"
    )
    {
        $Params = @{
            Path = $ProjectRoot
            Force = $true
        }

        Invoke-PSDeploy @Verbose @Params
    }
    Else
    {
        "Skipping deployment: To deploy, ensure that...`n" +
        "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n"
    }
}
