class LauncherBase {
    app := ""
    key := ""
    game := ""
    config := ""
    pid := 0
    progress := ""

    __New(app, key, config := "") {
        if (config == "") {
            config := Map()
        }

        InvalidParameterException.CheckTypes("LauncherBase", "app", app, "AppBase", "key", key, "", "config", config, "Map")
        this.app := app
        this.key := key
        this.game := app.Game
        this.config := config

        if (this.config["ShowProgress"]) {
            this.CreateProgressGui()
        }
    }

    /**
    * IMPLEMENTED METHODS
    */

    CreateProgressGui() {
        if (this.progress == "") {
            progressTitle := StrReplace(this.config["ProgressTitle"], "{g}", this.config["DisplayName"])
            progressText := StrReplace(this.config["ProgressText"], "{g}", this.config["DisplayName"])
            this.progress := this.app.GuiManager.OpenWindow("LauncherProgressIndicator", "", this.key, A_ScriptFullPath, "", "", this.CountLaunchSteps())
        }
    }

    CountLaunchSteps() {
        launchSteps := 0

        if (this.config["LauncherCloseBeforeRun"]) {
            launchSteps++
        }

        if (this.config["LauncherCloseAfterRun"]) {
            launchSteps++
        }

        if (this.config["CloseBefore"]) {
            launchSteps++
        }

        if (this.config["CloseAfter"]) {
            launchSteps++
        }

        if (this.config["RunBefore"]) {
            launchSteps++
        }

        if (this.config["RunAfter"]) {
            launchSteps++
        }

        return launchSteps + this.game.CountRunSteps()
    }

    Log(message, level := "Debug") {
        if (this.app.Logger && this.config["LoggingLevel"] != "None") {
            this.app.Logger.Log(this.key . ": " . message, level)
        }
    }

    LaunchGame() {
        if (this.progress != "") {
            this.progress.SetDetailText("Initializing launcher...")
        }

        this.Log("Starting launcher operations.", "Info")
        
        if (this.config["CloseBefore"]) {
            if (this.progress != "") {
                this.progress.IncrementValue(1, "Closing processes before run...")
            }

            this.CloseProcesses(this.config["CloseBefore"])
        }

        if (this.config["RunBefore"]) {
            if (this.progress != "") {
                this.progress.IncrementValue(1, "Launching processes before run...")
            }

            this.RunProcesses(this.config["RunBefore"], "Before")
        }

        if (this.config["LauncherCloseBeforeRun"]) {
            if (this.progress != "") {
                this.progress.IncrementValue(1, "Closing existing game launcher...")
            }

            this.CloseLauncher("BeforeRun")
        }

        result := this.LaunchGameAction()

        if (this.config["LauncherCloseAfterRun"]) {
            if (this.progress != "") {
                this.progress.IncrementValue(1, "Closing existing game launcher...")
            }

            this.CloseLauncher("AfterRun")
        }

        if (this.config["CloseAfter"]) {
            if (this.progress != "") {
                this.progress.IncrementValue(1, "Closing processes after run...")
            }

            this.CloseProcesses(this.config["CloseAfter"])
        }

        if (this.config["RunAfter"]) {
            if (this.progress != "") {
                this.progress.IncrementValue(1, "Launching processes after run...")
            }

            this.RunProcesses(this.config["RunAfter"], "After")
        }

        this.Log("Finished all launcher operations.", "Info")

        if (this.progress != "") {
            this.progress.Finish()
        }

        return result
    }

    CloseProcesses(processes) {
        processes := StrSplit(processes, ";")

        for index, processExe in processes {
            if (this.progress != "") {
                this.progress.SetDetailText("Closing " . processExe . "...")
            }

            if (WinExist("ahk_exe " . processExe, "", " - Launchpad")) {
                this.Log("Closing process " . processExe)
                WinClose()
                Sleep(1000)
            }

            pid := ProcessExist(processExe)
            if (pid) {
                this.Log("Closing process " . pid)
                ProcessClose(pid)
            }
        }
    }

    RunProcesses(processes, dir) {
        processes := StrSplit(processes, ";")

        for index, command in processes {
            if (this.progress != "") {
                this.progress.SetDetailText("Running " . command . "...")
            }

            taskName := "Launchpad\" . this.key . "\" . dir . "\" . index
            this.Log("Running process " . command)
            this.RunScheduledTask(taskName, command)
        }
    }

    RunScheduledTask(taskname, runCmd) {
        currentTime := FormatTime(,"yyyyMMddHHmmss")
        runTime := FormatTime(DateAdd(currentTime, 0, "Seconds"), "HH:mm")
        RunWait("SCHTASKS /CREATE /SC ONCE /TN `"" . taskName . "`" /TR `"'" . runCmd . "'`" /ST " . runTime . " /f",, "Hide")
        RunWait("SCHTASKS /RUN /TN `"" . taskName . "`"",, "Hide")
        Run("SCHTASKS /DELETE /TN `"" . taskName . "`" /f",, "Hide")
    }

    LaunchGameAction() {
        this.Log("Calling managed game's RunGame action")
        return this.game.RunGame(this.progress)
    }

    CloseLauncher(eventName) {
        if (!this.LauncherIsRunning()) {
            return true
        }

        if (this.config["LauncherClosePreDelay"] > 0) {
            Sleep(this.config["LauncherClosePreDelay"] * 1000)
        }

        this.Log("Attempting to close existing launcher...")

        closed := this.CloseLauncherAction()

        if (closed && this.config["LauncherClosePostDelay"] > 0) {
            Sleep(this.config["LauncherClosePostDelay"] * 1000)
        }

        return closed
    }

    CloseLauncherAction() {
        closed := false

        if (this.config["LauncherCloseMethod"] == "Wait") {
            closed := this.WaitForLauncherToClose()
        } else if (this.config["LauncherCloseMethod"] == "Auto") {
            closed := this.AutoCloseLauncher(true)
        } else if (this.config["LauncherCloseMethod"] == "AutoPolite") {
            closed := this.AutoCloseLauncher()
        } else if (this.config["LauncherCloseMethod"] == "AutoKill") {
            closed := this.KillLauncher()
        } else { ; Default to "Prompt"
            closed := this.PromptForLauncherToClose()
        }

        return closed
    }

    LauncherIsRunning() {
        pid := ""

        if (this.config["LauncherProcessId"] != "") {
            if (this.config["LauncherProcessType"] == "Title") {
                hwnd := WinExist(this.config["LauncherProcessId"],, " - Launchpad")
                if (hwnd) {
                    pid := WinGetPID("ahk_id " . hwnd)
                }
            } else if (this.config["LauncherProcessType"] == "Class") {
                hwnd := WinExist("ahk_class " . this.config["LauncherProcessId"],, " - Launchpad")
                if (hwnd) {
                    pid := WinGetPID("ahk_id " . hwnd)
                }
            } else { ; Default to Exe
                pid := ProcessExist(this.config["LauncherProcessId"])
            }
        }

        if (pid == "") {
            pid := 0
        }

        this.pid := pid
        return pid
    }

    WaitForLauncherToClose() {
        isRunning := this.LauncherIsRunning()

        if (isRunning) {
            startTime := FormatTime(,"yyyyMMddHHmmss")

            Loop {
                isRunning := this.LauncherIsRunning()

                If (!isRunning) {
                    break
                }

                if (DateDiff(FormatTime(,"yyyyMMddHHmmss"), startTime, "Seconds") >= this.config["WaitTimeout"]) {
                    break
                }

                this.WaitLoopAction()
            }
        }
        
        return isRunning
    }

    WaitLoopAction() {
        if (this.config["LauncherRecheckDelay"] > 0) {
            Sleep(this.config["LauncherRecheckDelay"] * 1000)
        }
    }

    AutoCloseLauncher(force := false) {
        isRunning := this.LauncherIsRunning()

        if (isRunning) {
            this.AutoCloseAction()
        }

        isRunning := this.LauncherIsRunning()

        if (isRunning && force) {
            isRunning := this.KillLauncher()
        }
        
        return isRunning
    }

    AutoCloseAction() {
        if (this.pid > 0 && WinExist("ahk_pid " . this.pid)) {
            WinClose("ahk_pid " . this.pid, "", this.config["LauncherPoliteCloseWait"])
        }
    }

    KillLauncher() {
        isRunning := this.LauncherIsRunning()

        if (isRunning) {
            if (this.config["LauncherKillPreDelay"] > 0) {
                Sleep(this.config["LauncherKillPreDelay"] * 1000)
                isRunning := this.LauncherIsRunning()
            }

            if (isRunning) {
                this.KillLauncherAction()

                if (this.config["LauncherKillPostDelay"] > 0) {
                    Sleep(this.config["LauncherKillPostDelay"] * 1000)
                }

                isRunning := this.LauncherIsRunning()
            }
        }

        return isRunning
    }

    KillLauncherAction() {
        if (this.pid > 0 && ProcessExist(this.pid)) {
            this.Log("Forecefully killing launcher...")
            ProcessClose(this.pid)
        }
    }

    PromptForLauncherToClose() {
        ; @todo Implement GUI class and instantiate it here
    }
}
