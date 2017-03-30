function Invoke-XLDRestMethod {
    <#
            .SYNOPSIS
            Generic helper cmdlet to invoke Rest methods agains a target XLD server.

            .DESCRIPTION
            This cmdlet extends the original Invoke-RestMethod cmdlet with XLD REST
            API specific parameters, so it does user authorization and provides easier
            resource access.

            .PARAMETER Resource
            XLD REST API Resource that needs to be accessed

            .PARAMETER Method
            REST method to be used for the call. (Default is GET)

            .PARAMETER AuthenticationMode
            Authentication Mode to access XLD Server

            .PARAMETER AuthenticationToken
            Authentication Token to access XLD Server

            .PARAMETER UriParams
            Parameters that needs to be appended to the GET url.

            .PARAMETER Headers
            HTTP Headers that needs to be added for the REST call.

            .PARAMETER Body
            HTTP Body payload

            .EXAMPLE
            Invoke-XLDRestMethod -Resource "repository"

            .EXAMPLE
            Invoke-XLDRestMethod -Resource "repository/ci/Test" -Method Delete

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Resource,

        [ValidateSet('Get','Put','Post','Delete')]
        [string]$Method = 'Get',

        [uri]$Server = $XLDConfig.Uri,

        [uri]$Uri = ('{0}deployit/{1}' -f $Server, $Resource),

        [string]$AuthenticationToken = $script:AuthenticationToken,

        [string]$ContentType = 'application/xml',

        [hashtable]$UriParams = @{},

        [hashtable]$Headers = @{},

        [xml]$Body
    )

    Add-Type -AssemblyName System.Net.Http
    $UriParams.os_authType = 'basic'
    $Headers.Authorization = ('{0} {1}' -f 'Basic', $AuthenticationToken)

    If ($UriParams -and $UriParams.Keys) {
        $Params = ''
        foreach($key in $UriParams.Keys) {
            $Params += ('{0}={1}&' -f $key, $UriParams.$key)
        }
        If ($Params) {
            $Uri = ('{0}?{1}' -f ($Uri), $Params)
        }
    }
    $Response = $null

    $invokeParams = @{
        uri    = $Uri
        method = $Method
    }

    If($Body) {
        $invokeParams.body = $Body
    }

    try {
        $Response = Invoke-RestMethod @invokeParams -DisableKeepAlive -Headers:$Headers -ContentType:$ContentType
    }
    catch {
        $Result = $_.Exception.Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader -ArgumentList ($Result)
        $Reader.BaseStream.Position = 0
        $Reader.DiscardBufferedData()
        $ResponseBody = $Reader.ReadToEnd()

        $errorMessage = 'Status code {0}. Server reported the following message: {1}.' -f  $_.Exception.Response.StatusCode, $ResponseBody

        throw [Net.Http.HttpRequestException] $errorMessage
    }

    Write-Verbose -Message ('Response: {0}' -f $Response)
    If ($Response -is [xml]) {
        Write-Debug -Message ($Response.OuterXml -replace '><', ">`n<")
    }
    $Response
}
