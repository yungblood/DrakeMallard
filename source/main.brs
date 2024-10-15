function Main(args as dynamic) as void
    launchInfo = {}
    port = CreateObject("roMessagePort")
    appMgr = CreateObject("roAppManager")
    appInfo = CreateObject("roAppInfo")
    devInfo = CreateObject("roDeviceInfo")
    devInfo.setMessagePort(port)
    memInfo = CreateObject("roAppMemoryMonitor")
    memInfo.setMessagePort(port)
    memMon = memInfo.EnableMemoryWarningEvent(true)
    if(memMon <> true)
        devInfo.enableLowGeneralMemoryEvent(true)
    end if
    launchInfo = {
        "args": args,
        "appId": appInfo.getId(),
        "appVersion": appInfo.getVersion(),
        "model": devInfo.getModel(),
        "modelDisplayName": devInfo.getModelDisplayName(),
        "modelType": devInfo.getModelType(),
        "modelDetails": devInfo.getModelDetails(),
        "friendlyName": devInfo.GetFriendlyName(),
        "osVersion": devInfo.getOSVersion(),
        "devid": devInfo.getChannelClientId(),
        "userCountryCode": devInfo.getUserCountryCode(),
        "timeZone": devInfo.getTimeZone(),
        "currentLocale": devInfo.getCurrentLocale().replace("_","-"),
        "countryCode": devInfo.getCountryCode(),
        "connectionInfo": formatJson(devInfo.getConnectionInfo()),
        "displayType": devInfo.getDisplayType(),
        "displayMode": devInfo.getDisplayMode(),
        "guestId": "roku-" + devInfo.getChannelClientId(),
        "screensaverTimeout": (appMgr.GetScreensaverTimeout() * 60).toStr()
    }
    input = createObject("roInput")
    input.setMessagePort(port)
    input.enableTransportEvents()
    screen = CreateObject("roSGScreen")
    screen.setMessagePort(port)
    appScene = screen.CreateScene("appScene")
    appScene.launchInfo = launchInfo
    screen.Show()
    appScene.observeField("close", port)
    while(true)
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent" then
            if msg.isScreenClosed() then return
        else if msgType = "roSGNodeEvent" then
            if msg.getField() = "close" then return
        else if msgType = "roInputEvent" then
            data = msg.getInfo()
            if data.type = "transport" then
                appScene.setField("transport", data)
                input.eventResponse({ id: data.id, status: "success" })
            else
                appScene.setField("deeplink", data)
            end if
        else if msgType = "roAppMemoryNotificationEvent"
            print "YB-Event MemoryUsagePercent = " msg.getInfo().lookup("MemoryUsagePercent")
            'm.global.getEvent="true"
        else if msgType = "roDeviceInfoEvent"
            print "YB-Event generalMemoryLevel = " msg.getInfo().lookup("generalMemoryLevel")
            'm.global.getEvent="true"
        end if
    end while
end function

function isNullOrEmpty(obj)
    if obj = invalid then return true
    if(type(obj) = "String") or (type(obj) = "roString")
        if(obj = "") return true
    else if(type(obj) = "roAssociativeArray")
        if(obj.keys().count() = 0) return true
    else if(type(obj) = "roArray")
        if(obj.count() = 0) return true
    end if
    return false
end function
