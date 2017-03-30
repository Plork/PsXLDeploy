Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHProjectName
        To $ENV:PSRepository
        WithOptions @{
            ApiKey = $ENV:NugetApiKey
        }
    }
}