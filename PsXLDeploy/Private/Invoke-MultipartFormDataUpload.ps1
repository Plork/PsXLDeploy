function Invoke-MultipartFormDataUpload {
    param(
        [Parameter(Mandatory)]
        [string]$Resource,

        [uri]$Server = $XLDConfig.Uri,

        [uri]$Uri = ('{0}deployit/{1}' -f $Server, $Resource),

        [string]$AuthenticationToken = $script:AuthenticationToken,

        [string]$InFile
    )

    Add-Type -AssemblyName System.Net.Http

    $HttpClientHandler = New-Object System.Net.Http.HttpClientHandler

    $AuthenticationHeaderValue = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Basic", $script:AuthenticationToken)

    $HttpClient = New-Object System.Net.Http.Httpclient $HttpClientHandler
    $HttpClient.DefaultRequestHeaders.Authorization = $AuthenticationHeaderValue

    $packageFileStream = New-Object System.IO.FileStream @($InFile, [System.IO.FileMode]::Open)

    $contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
    $contentDispositionHeaderValue.Name = "fileData"
    $contentDispositionHeaderValue.FileName = (Split-Path $InFile -leaf)

    $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
    $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
    $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue "application/octet-stream"

    $content = New-Object System.Net.Http.MultipartFormDataContent
    $content.Add($streamContent)

    try {
        $Response = $HttpClient.PostAsync($Uri, $content).Result

        if (!$response.IsSuccessStatusCode) {
            $responseBody = $Response.Content.ReadAsStringAsync().Result
            $errorMessage = "Status code {0}. Server reported the following message: {1}." -f $Response.StatusCode, $responseBody

            throw [System.Net.Http.HttpRequestException] $errorMessage
        }

        return $Response.Content.ReadAsStringAsync().Result
    }
    catch [Exception] {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        if ($null -ne $HttpClient) {
            $HttpClient.Dispose()
        }

        if ($null -ne $response) {
            $response.Dispose()
        }
    }
}
