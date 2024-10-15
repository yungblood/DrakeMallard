function http()
    if m.http = invalid
        m.http = http_new()
    end if
    return m.http
end function

function http_new()
    this = {}
    this.port =         CreateObject("roMessagePort")
    this.urlTrans =     CreateObject("roUrlTransfer")

    this.urlTrans.setMessagePort(this.port)

    this.getResponse =      http_getResponse
    this.setHeaders =       http_setHeaders
    this.wait =             http_wait
    this.makeRequest =      http_makeRequest
    this.setAuth =          http_setAuth
    this.proxy =            http_proxy
    this.safeFormatJson =   http_safeFormatJson

    this.identity =     this.urlTrans.getIdentity()
    this.noRequest = {
        code:           0
        error:          "Unable to send request."
        body:           ""
        headers:        {}
        source:         0
        ip:             ""
    }
    this.toFile =       ""
    this.url =          ""
    this.auth =         invalid
    this.user =         ""
    this.pass =         ""
    this.headers =      {}
    return this
end function

function http_setHeaders(headerArray as object)
    if headerArray <> invalid
        if type(headerArray) = "roAssociativeArray"
            headerArray = [headerArray]
        end if
        for each header in headerArray
            debug(5, "http", "header", header.key + " = " + header.val)
            m.headers[header.key] = header.val
            m.urlTrans.setHeaders(m.headers)
        next
    end if
end function

function http_getResponse(msg as object)
    if(type(msg) = "roUrlEvent")
        response = {
            code:       msg.getResponseCode()
            error:      msg.getFailureReason().trim()
            body:       msg.getString()
            headers:    msg.getResponseHeaders()
            source:     msg.getSourceIdentity()
            ip:         msg.getTargetIpAddress()
            file:       m.toFile
            url:        m.url
            postData:   m.postData
        }
        debug(5,"http", "response", response)
        if(m.toFile <> "")
            'TODO: Don't try to print if image...
            'if (response.headers <> invalid) and (response.headers["content-type"] <> invalid)
            debug(5,"http", "file", ReadAsciiFile(m.toFile))
        end if
        return response
    end if
    return invalid
end function

function http_setAuth(url as string)
    auth = url.Instr(8,"@")
    dom = url.Instr(8,"/")
    sep = url.Instr(8,":")
    if((auth > 0) and (auth < dom))
        if((sep > 0) and (sep < auth))
            proto = "http://"
            if(lcase(url.left(8)) = "https://") proto = "https://"
            user = url.Mid(len(proto),sep-len(proto))
            pass = url.Mid(sep+1,auth-sep-1)
            url = proto + url.mid(auth+1)
            if(m.auth = invalid)
                m.urlTrans.setUrl(m.proxy(url))
                noAuth = m.getResponse(m.urlTrans.head())
                if(noAuth.code >= 200 and noAuth.code < 400)
                    m.auth = ""
                else if(user <> "")
                    m.urlTrans.SetUserAndPassword(user, pass)
                    digest = m.getResponse(m.urlTrans.head())
                    if(digest.code >= 200 and digest.code < 400)
                        m.user = user
                        m.pass = pass
                        m.auth = ""
                    else
                        ba = CreateObject("roByteArray")
                        ba.FromAsciiString(user + ":" + pass)
                        m.auth = "Basic " + ba.ToBase64String()
                    end if
                end if
            end if
        end if
    else
        m.auth = ""
    end if
    if(m.auth <> "")
        debug(5,"http", "auth", "Basic")
        m.headers["Authorization"] = m.auth
    else if(m.user <> "")
        debug(5,"http", "auth", "Digest")
        m.urlTrans.SetUserAndPassword(m.user, m.pass)
    else
        debug(5,"http", "auth", "None")
    end if
    m.url = url
    m.urlTrans.setUrl(m.proxy(m.url))
end function

function http_makeRequest(url as string, method = "GET" as string, toFile = "" as string, postData = invalid as object, headers = [] as object, async = false as boolean) as dynamic
    if(lcase(url.left(8)) = "https://")
        m.urlTrans.setCertificatesFile("common:/certs/ca-bundle.crt")
        m.urlTrans.initClientCertificates()
    end if
    debug(5, "http", "request", method + " - " + url)

    m.urlTrans.setRequest(method)
    m.setHeaders(headers)
    m.toFile = toFile
    m.postData = {}
    if (postData <> invalid) m.postdata = postData
    if(lcase(url.left(4)) = "http")
        m.setAuth(url)
        if toFile = ""
            if (method = "GET")
                request = m.urlTrans.asyncGetToString()
            else
                debug(5,"http", "postData", postData)
                m.setHeaders([{key: "Content-Type", val: "application/json"}])
                request = m.urlTrans.asyncPostFromString(m.safeFormatJson(postData))
            end if
        else
            if (method = "GET")
                request = m.urlTrans.asyncGetToFile(toFile)
            else
                debug(5,"http", "postData", postData)
                m.setHeaders([{key: "Content-Type", val: "application/json"}])
                fromFile = "tmp:/http_" + m.identity.toStr() + ".json"
                WriteAsciiFile(fromFile, m.safeFormatJson(postData))
                request = m.urlTrans.asyncPostFromFileToFile(fromFile, toFile)
            end if
        end if
    else
        response = {
            code:       -1
            error:      "Invalid Address"
            body:       ""
            headers:    {}
            source:     ""
            ip:         ""
            file:       toFile
            url:        url
            postData:   {}
        }
        return response
    end if

    if not request or async
        return request
    end if

    while (true)
        msg = m.wait(0)
        response = m.getResponse(msg)
        if response <> invalid
            return response
        end if
    end while
end function

function http_wait(timeout as integer)
    return wait(timeout, m.port)
end function

function http_proxy(url as string)
    ret = url
    appInfo = createObject("roAppInfo")
    if appInfo.isDev()
        #if enableProxy
            if isNullOrEmpty(m.proxyAddress)
                conf = CreateObject("roRegistrySection", "Conf")
                m.proxyAddress = conf.read("proxy")
            end if
            if not isNullOrEmpty(m.proxyAddress)
                ret = m.proxyAddress + url
            end if
        #endif
    end if
    return ret
end function

function http_safeFormatJson(json as object)
    if(json = invalid) return ""
    for each key in json
        if type(json[key]) = "roString"
            json[key] = json[key].replace(chr(34), "\" + chr(34))
        end if
    next
    ret = formatJson(json)
    return ret
end function