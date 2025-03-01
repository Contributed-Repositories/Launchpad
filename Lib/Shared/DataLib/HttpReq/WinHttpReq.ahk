class WinHttpReq extends HttpReqBase {
    static winHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    static adoStream := ComObjCreate("adodb.stream")

    Send(method := "GET", data := "", uploadFile := false) {
        if (IsObject(this.url)) {
            ; Clear cookie
            return WinHttpReq.winHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        }

        if (data != "" && method == "GET") {
            method := "POST"
        }

        WinHttpReq.winHttp.Open(method, this.url, true)

        if (data != "" && !this.requestHeaders.Has("Content-Type")) {
            contentType := Type(data) == "String" ? "application/x-www-form-urlencoded" : "application/json"
            WinHttpReq.winHttp.SetRequestHeader("Content-Type", contentType)
        }

        if (data && uploadFile && FileExist(data)) {
            this.adoStream.Type := 1 ; Binary
            this.adoStream.Open()
            this.adoStream.LoadFromFile(data)
            data := this.adoStream
        } else if (data && IsObject(data)) {
            json := JsonData.new()
            data := json.ToString(data)
        }

        this.ProcessHeaders(WinHttpReq.winHttp)

        if (this.proxy != "") {
            WinHttpReq.winHttp.SetProxy(2, SubStr(A_LoopField, this.pos + 6))
        }

        if (this.codepage != "") {
            WinHttpReq.winHttp.Option[2] := SubStr(A_LoopField, this.pos + 9)
        }

        WinHttpReq.winHttp.Option[6] := this.autoRedirect

        WinHttpReq.winHttp.Send(data)
	    returnCode := WinHttpReq.winHttp.WaitForResponse(this.timeout ? this.timeout : -1)

        this.responseBody := WinHttpReq.winHttp.ResponseBody
        this.responseHeaders := "HTTP/1.1 " WinHttpReq.winHttp.Status() "`n" WinHttpReq.winHttp.GetAllResponseHeaders()
        this.responseData := WinHttpReq.winHttp.ResponseText
        this.statusCode := WinHttpReq.winHttp.Status()

        this.returnCode := returnCode
        return returnCode
    }

    ProcessHeaders(oHTTP) {
        headers := ""

        if (this.requestHeaders) {
            for (key, val in this.requestHeaders) {
                oHTTP.SetRequestHeader(key, val)
            }
        }

        return headers
    }
}
