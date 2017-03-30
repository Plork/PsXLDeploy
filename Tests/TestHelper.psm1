function Initialize-TestEnvironment{

    $XLDURi = 'http://localhost:4516'
    $XLDCredentials = New-Object PSCredential("admin", (ConvertTo-SecureString "password" -AsPlainText -Force))

    Set-XLDConfig -Uri $XLDUri
    Set-XLDAuthentication -Credential $XLDCredentials
}
