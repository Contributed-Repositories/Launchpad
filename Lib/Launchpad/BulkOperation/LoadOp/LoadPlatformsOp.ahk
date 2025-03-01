class LoadPlatformsOp extends BulkOperationBase {
    platformsConfigObj := ""
    progressTitle := "Loading Platforms"
    progressText := "Please wait while your configuration is processed."
    successMessage := "Loaded {n} platform(s) successfully."
    failedMessage := "{n} platform(s) could not be loaded due to errors."

    __New(app, platformsConfigObj := "", owner := "") {
        if (platformsConfigObj == "") {
            platformsConfigObj := app.Platforms.GetConfig()
        }

        InvalidParameterException.CheckTypes("LoadPlatformsOp", "platformsConfigObj", platformsConfigObj, "PlatformsConfig")
        this.platformsConfigObj := platformsConfigObj
        super.__New(app, owner)
    }

    RunAction() {
        this.platformsConfigObj.LoadConfig()

        platforms := Map()
        platforms["Bethesda"] := "BethesdaPlatform"
        platforms["Blizzard"] := "BlizzardPlatform"
        platforms["Epic"] := "EpicPlatform"
        platforms["Origin"] := "OriginPlatform"
        platforms["Riot"] := "RiotPlatform"
        platforms["Steam"] := "SteamPlatform"

        if (this.useProgress) {
            this.progress.SetRange(0, platforms.Count)
        }

        for key, platformClass in platforms {
            this.StartItem(key, key . ": Loading...")

            if (!this.platformsConfigObj.Platforms.Has(key)) {
                this.platformsConfigObj.Platforms[key] := Map()
            }

            platformConfig := this.platformsConfigObj.Platforms[key]
            platformConfig["PlatformClass"] := platformClass
            requiredKeys := "" ; @todo Figure out if we need these or if they can just be passed in the config
            this.results[key] := PlatformEntity.new(this.app, key, platformConfig, requiredKeys)
            this.FinishItem(key, true, key . ": Loaded successfully.")
        }
    }
}
