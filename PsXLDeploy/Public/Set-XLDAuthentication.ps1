function Set-XLDAuthentication {
  <#
            .SYNOPSIS
            Sets the Authentication credential ad mode for the target XLD Server.

            .DESCRIPTION
            All further cmdlets from PsXLD will be executed with the Authentication
            details passed by this command.

            .PARAMETER Credential
            PSCredential to be used to login to the target XLD server

            .PARAMETER AuthenticationToken
            Authentication Token to be directly set for further authentication

            .PARAMETER AuthenticationMode
            Type of the Authentication process - currently Basic only

            .EXAMPLE
            Set-XLDAuthentication -Credential (Get-Credential)

            .EXAMPLE
            Set-XLDAuthentication -AuthenticationToken 'VXNlck5hbWU6UGFzc3dvcmQ='
    #>
  [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', 'Credential')]
  param(
    [Parameter(Mandatory,ParameterSetName = 'ByCredential')]
    [System.Management.Automation.Credential()][pscredential]
    [System.Management.Automation.CredentialAttribute()]
    $Credential,

    [Parameter(Mandatory,ParameterSetName = 'ByAuthenticationToken')]
    [ValidateNotNullOrEmpty()]
    [Alias('Token')]
    [string]$AuthenticationToken
  )

  # Directly set token
  If ($AuthenticationToken) {
    $script:AuthenticationToken = $AuthenticationToken
    return
  }

  # Get UserName and Password from Credential
  $UserName = $Credential.UserName
  $Password = $null
  If ($Credential.GetNetworkCredential()) {
    $Password = $Credential.GetNetworkCredential().password
  }
  Else {
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.password))
  }

  # Construct the AuthToken by UserName and Password
  $script:AuthenticationToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $UserName, $Password)))
}
