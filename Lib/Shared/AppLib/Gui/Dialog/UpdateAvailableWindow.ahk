﻿class UpdateAvailableWindow extends FormGuiBase {
    releaseInfo := ""

    __New(app, themeObj, windowKey, releaseInfo, owner := "", parent := "") {
        this.releaseInfo := releaseInfo
        super.__New(app, themeObj, windowKey, "Update Available", this.GetTextDefinition(), owner, parent, this.GetButtonsDefinition())
    }

    GetTextDefinition() {
        return "There is a new version of Launchpad available!" ; @todo Populate based on whether you're currently logged in
    }

    GetButtonsDefinition() {
        return "*&Update|&Cancel"
    }

    Controls() {
        global appVersion

        super.Controls()
        this.guiObj.AddText("w" . this.windowSettings["contentWidth"] . " y+" . (this.margin*2), "Current version: " . appVersion)
        this.SetFont("normal", "Bold")
        this.guiObj.AddText("w" . this.windowSettings["contentWidth"] . " y+" . (this.margin), "Latest version: " . this.releaseInfo["data"]["version"])
        this.SetFont()
        this.guiObj.AddLink("w" . this.windowSettings["contentWidth"] . " y+" . (this.margin), '<a href="' .  this.releaseInfo["data"]["release-page"] . '">View release notes</a>')
        this.guiObj.AddText("w" . this.windowSettings["contentWidth"] . " y+" . (this.margin*2), "Would you like to update Launchpad now?")
    }

    ProcessResult(result) {
        if (result == "Update") {
            this.ApplyUpdate()
        }

        return result
    }

    ApplyUpdate() {
        downloadUrl := this.releaseInfo["data"].Has("installer") ? this.releaseInfo["data"]["installer"] : ""
        
        if (!DirExist(this.app.tmpDir . "\Installers")) {
            DirCreate(this.app.tmpDir . "\Installers")
        }
        
        if (downloadUrl) {
            localFile := this.app.tmpDir . "\Installers\Launchpad-" . this.releaseInfo["data"]["version"] . ".exe"
            FileDelete(this.app.tmpDir . "\Installers\Launchpad-*")
            Download(downloadUrl, localFile)
            Run(localFile)
            ExitApp()
        }
    }
}
