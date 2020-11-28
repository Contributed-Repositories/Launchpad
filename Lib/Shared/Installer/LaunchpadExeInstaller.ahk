class LaunchpadExeInstaller extends InstallerBase {
    name := "Launchpad.exe Installer"
    movedApp := false
    version := "latest"
    isUpdater := false

    __New(appState, cache, tmpDir := "") {
        SplitPath(A_ScriptFullPath,,,,scriptNameNoExt)
        this.isUpdater := scriptNameNoExt == this.appName . " Updater"

        assets := []

        if (this.isUpdater) {
            asset := GitHubReleaseInstallerAsset.new("VolantisDev/Launchpad", this.appName . ".exe", false, "", appState, cache, "LaunchpadExe", this.appName, true, tmpDir, true)
            asset.version := this.version
            assets.Push(asset)
        }

        super.__New(appState, "LaunchpadExeInstaller", cache, assets, tmpDir)
    }

    Install(progress := "") {
        if (!this.isUpdater and A_IsCompiled) {
            installDir := this.DetermineInstallDir()

            if (installDir != this.scriptDir) {
                DirCreate(installDir)
                FileCopy(A_ScriptFullPath, installDir . "\Launchpad.exe", true)
                this.movedApp := true
                this.scriptDir := installDir

                for (index, asset in this.installerAssets) {
                    asset.scriptDir := installDir
                }
            }
        }

        result := super.Install(progress)

        if (this.movedApp) {
            ; @todo Notify user that the app is going to restart before continuing
            ; @todo schedule the new Launchpad.exe to start after a couple of seconds
            ExitApp 0
        }

        return result
    }

    DetermineInstallDir() {
        installDir := ""

        if (FileExist(this.scriptDir . "\Launchpad.ini")) {
            installDir := this.scriptDir
        }

        if (installDir == "") {
            installDir := this.PromptForInstallDir()
        }

        return installDir
    }

    PromptForInstallDir() {
        return DirSelect("*" . this.scriptDir, 3, "Select the folder to install Launchpad to.")
        ; @todo make this a nicer prompt
    }
}
