class ManagedLauncherEditor extends ManagedEntityEditorBase {
    closeMethods := ["Prompt", "Wait", "Auto", "AutoPolite", "AutoKill"]

    __New(app, themeObj, windowKey, entityObj, mode := "config", owner := "", parent := "") {
        super.__New(app, themeObj, windowKey, entityObj, "Managed Launcher Editor", mode, owner, parent)
    }

    CustomTabControls() {
        this.AddCheckBoxBlock("CloseBeforeRun", "Close launcher before run", true, "If selected, the launcher will be closed before attempting to run the game. This can be useful to ensure the process starts under Launchpad's process instead of the existing launcher's process.", true)
        this.AddCheckBoxBlock("CloseAfterRun", "Close launcher after run", true, "If selected, the launcher will be closed after the game closes. This can be useful to ensure Steam or other applications know you are done playing the game.", true)
        this.AddSelect("Launcher Close Method", "CloseMethod", this.entityObj.CloseMethod, this.closeMethods, true, "", "", "Prompt: Show a prompt that allows the user to either trigger a recheck or cancel waiting for the launcher to close`nWait: Waits up to WaitTimeout seconds for the launcher to close on its own.`nAuto: Make one polite close attempt, wait a bit, then kill the process if it is still running.`nAutoPolite: Attempt to close the launcher politely, but do not forcefully kill it if it's still running.`nAutoKill: Automatically close the launcher by force without a polite attempt.", true)
        this.AddNumberBlock("WaitTimeout", "Launcher Wait Timeout", true, "How many seconds to wait for the launcher to close before giving up.", true)
        this.AddNumberBlock("PoliteCloseWait", "Launcher Polite Close Wait", true, "How many seconds to give the launcher to close after asking politely before forcefully killing it (if applicable)", true)
    }

    ExtraTabControls(tabs) {
        tabs.UseTab("Delays")
        this.AddNumberBlock("ClosePreDelay", "Close Launcher Pre-Delay", true, "How many MS to wait before closing the launcher, which can be useful to allow time for cloud saves to sync", true)
        this.AddNumberBlock("ClosePostDelay", "Close Launcher Post-Delay", true, "How many MS to wait after closing the launcher, which can be useful to allow time for helper processes to fully exit", true)
        this.AddNumberBlock("KillPreDelay", "Kill Launcher Pre-Delay", true, "How many MS to wait before forcefully killing the launcher. This is in addition to any existing delays.", true)
        this.AddNumberBlock("KillPostDelay", "Kill Launcher Post-Delay", true, "How many MS to wait after forcefully killing the launcher. This is in addition to any existing delays.", true)
        this.AddNumberBlock("RecheckDelay", "Launcher Recheck Delay", true, "How many MS to wait between Launchpad checking if the launcher is running or not. Lower numbers increase Launchpad's responsiveness, but use more CPU.", true)
    }

    GetTabNames() {
        tabNames := super.GetTabNames()
        tabNames.Push("Delays")
        return tabNames
    }

    OnDefaultCloseBeforeRun(ctlObj, info) {
        this.SetDefaultValue("CloseBeforeRun", !!(ctlObj.Value), true)
    }

    OnDefaultCloseAfterRun(ctlObj, info) {
        this.SetDefaultValue("CloseAfterRun", !!(ctlObj.Value), true)
    }

    OnDefaultClosePreDelay(ctlObj, info) {
        this.SetDefaultValue("ClosePreDelay", !!(ctlObj.Value), true)
    }

    OnDefaultClosePostDelay(ctlObj, info) {
        this.SetDefaultValue("ClosePostDelay", !!(ctlObj.Value), true)
    }

    OnDefaultCloseMethod(ctlObj, info) {
        this.SetDefaultSelectValue("CloseMethod", this.closeMethods, !!(ctlObj.Value), true)
    }

    OnDefaultRecheckDelay(ctlObj, info) {
        this.SetDefaultValue("RecheckDelay", !!(ctlObj.Value), true)
    }

    OnDefaultWaitTimeout(ctlObj, info) {
        this.SetDefaultValue("WaitTimeout", !!(ctlObj.Value), true)
    }

    OnDefaultKillPreDelay(ctlObj, info) {
        this.SetDefaultValue("KillPreDelay", !!(ctlObj.Value), true)
    }

    OnDefaultKillPostDelay(ctlObj, info) {
        this.SetDefaultValue("KillPostDelay", !!(ctlObj.Value), true)
    }

    OnDefaultPoliteCloseWait(ctlObj, info) {
        this.SetDefaultValue("PoliteCloseWait", !!(ctlObj.Value), true)
    }

    OnCloseBeforeRunChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.CloseBeforeRun := !!(ctlObj.Value)
    }

    OnCloseAfterRunChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.CloseAfterRun := !!(ctlObj.Value)
    }

    OnClosePreDelayChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.ClosePreDelay := ctlObj.Text
    }

    OnClosePostDelayChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.ClosePostDelay := ctlObj.Text
    }

    OnCloseMethodChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.CloseMethod := ctlObj.Text
    }

    OnRecheckDelayChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.RecheckDelay := ctlObj.Text
    }

    OnWaitTimeoutChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.WaitTimeout := ctlObj.Text
    }

    OnKillPreDelayChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.KillPreDelay := ctlObj.Text
    }

    OnKillPostDelayChange(ctlObj, info) {
        this.guiObj.Submit(false)
        this.entityObj.KillPostDelay := ctlObj.Text
    }

    OnPoliteCloseWaitChange(ctlObj, info) {
        this.guiObj.Submit(false)
        
    }
}
