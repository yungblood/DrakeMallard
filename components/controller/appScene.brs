sub init()
    addGlobal("favorites", {}, "assocarray")
    addGlobal("session_number", 0, "integer")
    debug(3, "appScene", "init()", "")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.deeplink = invalid
    m.lastBeacon = ""

    m.registry = CreateObject("roRegistry")
    m.conf = CreateObject("roRegistrySection", "Conf")

    appInfo = CreateObject("roAppInfo")
    devInfo = CreateObject("roDeviceInfo")

    m.channelCred = {}
    m.purchases = []

    m.screens = m.top.findNode("screens")
    m.homeScreen = CreateObject("roSGNode", "homeScreen")
    m.homeScreen.ObserveField("itemSelected", "onItemSelected")
    m.screens.appendChild(m.homeScreen)

    m.store = m.top.findNode("store")
    fields = ["userData", "userRegionData", "channelCred", "storeChannelCredDataStatus", "requestPartnerOrderStatus", "purchases", "catalog", "orderStatus", "storeCatalog", "confirmPartnerOrderStatus"]
    for each field in fields
        m.store.ObserveField(field, "onStoreResult", ["command"])
    next
    m.store.command = "getUserRegionData"

    m.lastFocus = m.top
    m.lastFocusType = "None"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if(press)
        if(key = "back")
            'TODO: Popup confirmation dialog
        end if
    end if
    return false
end function

sub onFocusChanged(nodeEvent as object)
    data = nodeEvent.getData()
    if (data <> invalid)
        m.lastFocus = data
        m.lastFocusType = data.focusedChild.subType()
    end if
end sub

function onLaunchInfoChanged(nodeEvent as object)
    data = nodeEvent.getData()
    debug(3, "appScene", "onLaunchInfoChanged()", data)
    if data.args <> invalid then
        if data.args.mediaType <> invalid and data.args.contentId <> invalid then
            m.deeplink = {
                mediaType: data.args.mediaType
                contentId: data.args.contentId
            }
        end if
    end if
    m.launchInfo = data
    addGlobal("launchInfo", data, "assocarray")
    m.homeScreen.setFocus(true)
    debug(1, "appScene", "onLaunchInfoChanged()", "setFocus")
end function

function onDeeplinkChanged(nodeEvent as object)
    data = nodeEvent.getData()
    debug(1, "appScene", "onDeeplinkChanged()", data)
    m.deeplink = data
    openDeeplink(data)
end function

function openDeeplink(link as object)
    debug(1, "appScene", "openDeeplink()", link)
    if link <> invalid
        if not isNullOrEmpty(link.mediaType) and not isNullOrEmpty(link.contentId)
            mediaType = link.mediaType
            contentId = link.contentId
            if mediaType = "screen"
                'TODO: Add deeplinking code here.
            else if mediaType = "proxy"
                ?"YB-proxy-config", contentId
                m.conf.write("proxy", contentId)
                m.conf.flush()
            end if
        end if
    end if
    m.deeplink = invalid
end function

function onTransportChanged(nodeEvent as object)
    data = nodeEvent.getData()
    debug(1, "appScene", "onTransportChanged()", data)
end function

function onItemSelected(nodeEvent as object)
    data = nodeEvent.getData()
    node = nodeEvent.getRoSGNode()
    if(data <> invalid)
        dataType = data.subtype()
        if(dataType = "xxx")
        end if
        debug(1, "appScene", "onItemSelected()", dataType, data.id, data, node)
        detail = CreateObject("roSGNode", "DetailScreen")
        detail.ObserveField("close", "onClose")
        detail.content = data
        m.screens.appendChild(detail)
        m.homeScreen.visible = false
        m.homeScreen.setFocus(false)
        detail.setFocus(true)
    end if
end function

function onStoreResult(nodeEvent as object)
    if(m.userData = invalid) m.userData = {}
    data = nodeEvent.getData()
    field = nodeEvent.getField()
    'context = nodeEvent.getInfo() YB-NOTE: unused var, do we really need it?
    debug(2, "appScene", "onStoreResult(" + field + ")", data)
    if(field = "userRegionData")
        m.userData.append(node2Array(data))
        m.store.command = "getCatalog"
    else if(field = "storeChannelCredDataStatus")
        ?"YB-storeChannelCred", data
    else if(field = "channelCred")
        if not isNullOrEmpty(data.json) then
            m.channelCred = parseJson(data.json)
            ?"YB-channelCred", m.channelCred
            if (m.channelCred <> invalid)
                ?"YB-get userid from store", m.channelCred.channel_data
            end if
        end if
        m.store.command = "getUserRegionData"
    else if(field = "catalog")
        m.catalog = {}
        for each child in data.getChildren(-1, 0)
            option = node2Array(child)
            optionCode = option.code.split("-")[0]
            m.catalog[optionCode] = option
        next
        addGlobal("catalog", m.catalog, "assocarray")
        m.store.command = "getPurchases"
    else if(field = "purchases")
        m.purchases = []
        for each child in data.getChildren(-1, 0)
            m.purchases.push(node2Array(child))
        next
        addGlobal("purchases", m.purchases, "array", false)
    else if(field = "userData")
        'TODO: process userData
    else if(field = "orderStatus")
        if(data.status = 1) 'Successful
            purchase = node2Array(data.getChild(0))
            purchase["userid"] = m.userid
            m.api.call = { command: "logPurchase": method: "POST", url: "purchase", postData: purchase }
            user = m.global.user
            user.account = purchase.name
            purchase["renewalDate"] = "Purchased" 'YB-HACK: hide resubscribe button.
            m.purchases.push(purchase)
            '?"YB-orderStatus", m.purchases.count(), purchase
            addGlobal("purchases", m.purchases, "array", false)
        else if(data.status = 2) 'Canceled
            ?"YB-Canceled"
        else
            ?"YB-Other Error"
        end if
    end if
end function

function onClose(nodeEvent as object)
    node = nodeEvent.getRoSGNode()
    data = nodeEvent.getData()
    debug(1, "appScene", "onClose()", data)
    node.visible = false
    m.screens.removeChild(node)
    m.homeScreen.visible = true
    m.homeScreen.setFocus(true)
    debug(1, "appScene", "onClose()", "setFocus")
end function

function exitApp(nodeEvent as object)
    data = nodeEvent.getData()
    debug(3, "appScene", "exitApp()", data)
    m.top.close = true
end function

function doAction(action = "" as string)
    debug(3, "appScene", "doAction()", action)
    m.top.UnobserveField("action")
    if(not isNullOrEmpty(action))
        m.top.ObserveField("action", action)
    end if
    m.top.action = action
end function

function menuSelect(itemId = "" as string)
    debug(1, "appScene", "menuSelect()", itemId)
    if(m.menu <> invalid) and (itemId <> "")
        c = 0
        for each child in m.menu.getChildren(-1, 0)
            if(child.id = itemId)
                m.homeScreen.selectItem = child
                m.homeScreen.jumpToItem = c
            end if
            c++
        next
    end if
    if m.deeplink <> invalid then
        m.top.deeplink = m.deeplink
        m.deeplink = invalid
    end if
end function

function sendSignalBeacon(nodeEvent as object)
    beacon = nodeEvent.getData()
    if(m.lastBeacon <> "AppLaunchComplete")
        if((m.lastBeacon = "AppDialogInitiate") and (beacon = "AppLaunchComplete"))
            m.top.signalBeacon("AppDialogComplete")
        end if
        m.top.signalBeacon(beacon)
        m.lastBeacon = beacon
    end if
end function
