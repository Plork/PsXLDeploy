function Set-XLDConfig {
  <#
      .SYNOPSIS
      Set PsXLDeploy module configuration.

      .DESCRIPTION
      Set PsXLDeploy module configuration, and live $XLDConfig global variable.
      This data is used as the default for most commands.

      .PARAMETER Uri
      Specify a Uri to use

      .Example
      Set-XLDConfig -Uri http://192.168.99.100:4516'

      .FUNCTIONALITY
      PsXLDeploy
    #>

  param(
    [Parameter(Mandatory)]
    [ValidatePattern('^(https?:\/\/)([\w\.-]+)(:\d+)*\/*')]
    [string]$Uri,

    [string]$Path = "$env:USERPROFILE\.PsXLDeploy\PsXLDeploy.xml"
  )

  $script:XLDConfig.URi = $Uri

  $script:XLDConfig |
  Select-Object -Property Uri |
  Export-Clixml -Path $Path -force
}
