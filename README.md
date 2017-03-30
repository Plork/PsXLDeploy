PsXLDeploy PowerShell module
==========================

PsXLDeploy is a PowerShell module that provides a wrapper for [XLDeploy][xldeploy]
 to allow easy and fast authenticated access to
[XLDeploy REST API][xldeployapi] in a scriptable and automatable manner.

## Usage
```powershell
Import-Module PsXLDeploy
```

## Examples
Try and execute the sample scripts in the [Examples folder][examples] against your local PsXLDeploy
server to see all the Cmdlets in action or call `help` on any of the PsXLDeploy cmdlets.

### Server and Authentication
```powershell
# Set the target PsXLDeploy Server
Set-XLDConfig -Url 'http://localhost:8080'

# Set login credentials for further cmdlets
Set-XLDAuthentication -Credential (Get-Credential)
```

## Documentation
Cmdlets and functions for PsXLDeploy have their own help PowerShell help, which
you can read with `help <cmdlet-name>`.

## Versioning
PsXLDeploy aims to adhere to [Semantic Versioning 2.0.0][semver].

## Development

* Source hosted at [Github][repo]

Pull requests are very welcome!
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the [repo][repo]
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Make sure `Invoke-Pester` tests are passing with all your changes
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## Authors
Created and maintained by [Marcel Bezemer] (<marcel@beestig.nl>).

## License
Apache License, Version 2.0 (see [LICENSE][LICENSE])

## TODO
- [ ] Sort casing throughout module
- [ ] Make build general for use with appveryor
- [ ] Make moduke available on psGallery

[repo]: https://github.com/Plork
[examples]: Examples/
[xldeploy]: https://xebialabs.com/products/xl-deploy
[xldeployapi]:http://localhost:4516/deployit
[license]: LICENSE
[semver]: http://semver.org/
[psget]: http://psget.net/
[pester]: https://github.com/pester/Pester