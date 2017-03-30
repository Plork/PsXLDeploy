Write-Verbose -Message 'PsXLD module'

#Get public and private function definition files.
$Public  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

#Dot source the files
Foreach($import in @($Public + $Private)) {
  Try {
    . $import.fullname
  }
  Catch {
    Write-Error -Message ('Failed to import function {0}: {1}' -f $import.fullname, $_)
  }
}

$XLDConfig = [pscustomobject]@{
  Uri = $null
}

$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
if(-not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
  Try {
    if (-not(Test-Path -Path (Split-Path -Path $Path -Parent))) {
      mkdir -Path (Split-Path -Path $Path -Parent)
    }
    $XLDConfig | Select-Object -Property Uri |
    Export-Clixml -Path $Path -force
  }
  Catch {
    Write-Warning -Message ('Failed to set config file {0}: {1}' -f ($Path), $_)
  }
}

$XLDConfig = Get-XLDConfig -Source 'PsXLDeploy.XML' -Path $Path
$script:AuthenticationToken = $null

Export-ModuleMember -Function $Public.Basename
