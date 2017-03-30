param
(
  $NugetApiKey = $args[0]
)

$ENV:NugetApiKey = $NugetApiKey

function Resolve-Module {
  [Cmdletbinding()]
  param
  (
    [Parameter(Mandatory)]
    [string[]]$Name,

    [string]$PSRepository = 'PSGallery'
  )

  Process {
    foreach ($ModuleName in $Name) {
      $Module = Get-Module -Name $ModuleName -ListAvailable
      Write-Verbose -Message "Resolving Module $($ModuleName)"

      If ($Module) {
        $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
        $GalleryVersion = Find-Module -Name $ModuleName -Repository $PSRepository -Force | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum

        If ($Version -lt $GalleryVersion) {

          If ((Get-PSRepository -Name $PSRepository).InstallationPolicy -ne 'Trusted') {
            Set-PSRepository -Name $PSRepository -InstallationPolicy Trusted
          }

          Write-Verbose -Message "$($ModuleName) Installed Version [$($Version.tostring())] is outdated. Installing Gallery Version [$($GalleryVersion.tostring())]"

          Install-Module -Name $ModuleName -Force -RequiredVersion -Repository $PSRepository
          Import-Module -Name $ModuleName -Force -RequiredVersion $GalleryVersion
        }
        Else {
          Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
          Import-Module -Name $ModuleName -Force -RequiredVersion $Version
        }
      }
      Else {
        Write-Verbose -Message "$($ModuleName) Missing, installing Module"
        Install-Module -Name $ModuleName -Force -Repository $PSRepository
        Import-Module -Name $ModuleName -Force -RequiredVersion $Version
      }
    }
  }
}

$env:PSModulePath = $env:PSModulePath + ";$env:ProgramFiles\WindowsPowershell\Modules"

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap -Force | Out-Null
$path = (Get-PackageProvider -Name Nuget -ListAvailable).ProviderPath
Import-PackageProvider $path

$validRepo = Get-PSRepository -Name $ENV:PSRepository -Verbose:$false -ErrorAction SilentlyContinue
If (-not $validRepo) {
  # Somehow this gives an error when successful
  Register-PSRepository -Name $ENV:PSRepository -SourceLocation $ENV:PSRepositoryUrl -PublishLocation "$ENV:PSRepositoryUrl/Packages" -ErrorAction SilentlyContinue
}

Resolve-Module Psake, PSDeploy, Pester, PSScriptAnalyzer, BuildHelpers -ErrorAction SilentlyContinue

Set-BuildEnvironment

Invoke-psake .\psake.ps1 -taskList $env:Task
exit ( [int]( -not $psake.build_success ) )
