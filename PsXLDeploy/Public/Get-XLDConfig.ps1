function Get-XLDConfig {
  <#
        .SYNOPSIS
            Get PsXLDeploy module configuration.

        .DESCRIPTION
            Get PsXLDeploy module configuration

        .FUNCTIONALITY
            PsXLDeploy
    #>
  [cmdletbinding(DefaultParameterSetName = 'Source')]
  param(
    [parameter(ParameterSetName='Source')]
    [ValidateSet("XLDConfig","PsXLDeploy.xml")]
    $Source = "XLDConfig",

    [parameter(ParameterSetName='Path')]
    [parameter(ParameterSetName='Source')]
    [string]$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
  )

  if($PSCmdlet.ParameterSetName -eq 'Source' -and $Source -eq "XLDConfig" -and -not $PSBoundParameters.ContainsKey('Path')) {
    $Script:XLDConfig
  }
  elseif (Test-Path -Path $Path -ErrorAction SilentlyContinue) {
    Import-Clixml -Path $Path
  }
}
