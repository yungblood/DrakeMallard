function init()
    debug(3, "homeScreen", "init()", "")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("content", "onContentChanged")
    m.menu = m.top.FindNode("menu")
    m.menu.ObserveField("itemFocused", "onMenuItemFocused", ["content"])
    m.menu.ObserveField("itemSelected", "onItemSelected")
    m.background = m.top.FindNode("background")
    m.lg = m.top.FindNode("lg")
    m.title = m.top.FindNode("title")
    m.callToAction = m.top.FindNode("callToAction")
    m.preview = m.top.FindNode("preview")
    m.preview.ObserveField("state", "onPreviewStateChanged")
    m.previewDelay = m.top.FindNode("previewDelay")
    m.previewDelay.ObserveField("fire", "onPreviewDelayFired")
    m.previewAnimation = m.top.FindNode("previewAnimation")
    m.previewAnimation.ObserveField("state", "onPreviewAnimationStateChanged")
    m.backgroundInterp = m.top.findNode("backgroundInterp")
    m.selectTimer = m.top.FindNode("selectTimer")
    m.selectTimer.ObserveField("fire", "onSelectTimerFired")
    m.listInterp = m.top.findNode("listInterp")
    m.shadow = m.top.findNode("shadow")
    m.list = m.top.findNode("list")
    m.list.ObserveField("rowItemFocused", "onListRowItemFocused", ["content"])
    m.list.ObserveField("rowItemSelected", "onListRowItemSelected")
    m.homeTask = CreateObject("roSGNode", "HomeTask")
    m.homeTask.ObserveField("response", "onContentLoaded")
    m.homeTask.control = "run"
    m.menuBg = m.top.FindNode("menuBg")
    m.lastIndex = ""
    m.lastFocus = m.menu
    m.lastMenuFocus = -1
    m.page = 0
    m.list.setFocus(true)
    debug(1, "homeScreen", "init()", "setFocus")
    m.content = invalid
    m.rowTasks = []
end function

sub onFocusChanged(nodeEvent as object)
    focus = nodeEvent.getData()
    debug(1, "homeScreen", "onFocusChanged()", focus)

    if focus <> invalid then
        m.lastFocus.setFocus(true)
        hideUI(false)
        debug(1, "homeScreen", "onFocusChanged()", "setFocus")
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if(press)
        debug(1, "homeScreen", "onKeyEvent()", key)
        if(key = "left") return showMenu()
        if(key = "right") return hideMenu()
        if(key = "back")
            if not m.lg.visible
                hideUI(false)
            else if not m.lastFocus.isSameNode(m.menu)
                showMenu()
            else
                return false
            end if
            return true
        end if
    else
        return true
    end if
    return false
end function

function onContentLoaded(nodeEvent as object)
    response = nodeEvent.getData()
    debug(2, "homeScreen", "onContentLoaded()", response)
    if response.content <> invalid and response.content.getChildCount() > 0
        m.list.content = response.content
        hideMenu()
    end if
end function

function onRowLoaded(nodeEvent as object)
    response = nodeEvent.getData()
    debug(2, "homeScreen", "onRowLoaded()", response.row)
    row = response.row
    content = m.list.content
    for c = 0 to content.getChildCount() - 1
        child = content.getChild(c)
        if response.refId = child.refId
            debug(2, "homeScreen", "onRowLoaded()", child.getChildCount())
            child.appendChildren(row.getChildren(-1,0))
            m.list.content = content
            exit for
        end if
    next
end function

function onMenuItemFocused(nodeEvent as object)
    data = nodeEvent.getData()
    context = nodeEvent.getInfo()
    debug(3, "homeScreen", "onMenuItemFocused()", data)
    if context.content <> invalid
        focused = context.content.getChild(data)
        if focused <> invalid and isNullOrEmpty(focused.title)
            if (data > m.lastMenuFocus)
                data++
            else if (data < m.lastMenuFocus)
                data--
            end if
            m.menu.jumpToItem = data
        end if
    end if
    m.lastMenuFocus = data
end function

function onListRowItemFocused(nodeEvent as object)
    indices = nodeEvent.getData()
    rowIndex = indices[0]
    itemIndex = indices[1]
    context = nodeEvent.getInfo()
    debug(1, "homeScreen", "onListItemFocused()", indices)
    hideUI(false)
    m.background.uri = ""
    m.title.uri = ""
    m.callToAction.text = ""
    m.previewDelay.control = "stop"
    if m.preview.state = "playing"
        m.preview.control = "pause"
    end if
    if context.content <> invalid
        maxRowIndex = context.content.getChildCount() - 1
        row = context.content.getChild(rowIndex)
        if row <> invalid
            item = row.getChild(itemIndex)
            if item <> invalid
                if item.image.background <> invalid
                    m.background.uri = item.image.background
                else
                    m.background.uri = item.image.hero_collection
                end if
                if item.image.title_treatment <> invalid
                    m.title.uri = item.image.title_treatment
                else
                    m.title.uri = item.image.logo_layer
                end if
                m.callToAction.text = item.callToAction
                if item.videoArt.count() > 0
                    video = createObject("RoSGNode", "ContentNode")
                    video.url = item.videoArt.peek()
                    video.title = item.title
                    video.streamformat = "mp4"
                    m.preview.content = video
                    m.preview.control = "prebuffer"
                    m.previewDelay.control = "start"
                end if
                debug(3, "homeScreen", "onListItemFocused()", item.videoArt)
            end if
        end if
        'Check next rows to see if they need to be updated.
        debug(2, "homeScreen", "onListItemFocused()", rowIndex, maxRowIndex, min(rowIndex + 3, maxRowIndex))
        if rowIndex < maxRowIndex
            for i = rowIndex + 1 to min(rowIndex + 3, maxRowIndex)
                row = context.content.getChild(i)
                debug(2, "homeScreen", "onListItemFocused()", i, row?.type)
                if row?.type = "SetRef"
                    rowTask = CreateObject("roSGNode", "RowTask")
                    rowTask.ObserveField("response", "onRowLoaded")
                    rowTask.control = "run"
                    rowTask.refId = row.refId
                    row.type = "Updating"
                    m.rowTasks.push(rowTask)
                end if
            next
        end if    
    end if
end function

function onPreviewDelayFired()
    m.backgroundInterp.reverse = "false"
    m.listInterp.reverse = "false"
    m.previewAnimation.control = "start"
    m.preview.visible = true
    m.preview.control = "play"
end function

function onListRowItemSelected(nodeEvent as object)
    indices = nodeEvent.getData()
    rowIndex = indices[0]
    itemIndex = indices[1]
    debug(1, "homeScreen", "onListRowItemSelected()", FormatJson(indices))
    hideUI()
    m.previewDelay.control = "stop"
    content = m.list.content
    if content <> invalid
        row = content.getChild(rowIndex)
        if row <> invalid
            item = row.getChild(itemIndex)
            m.top.itemSelected = item
        end if
    end if
end function

function onSelectTimerFired()
    hideUI(false)
end function

function hideUI(hide = true as boolean)
    m.lg.visible = not hide
    m.shadow.visible = not hide
    m.list.visible = not hide
    m.menu.visible = not hide
end function

function onPreviewStateChanged(nodeEvent as object)
    state = nodeEvent.getData()
    if state = "playing"
        m.lg.visible = false
    else if state = "finished" or state = "paused"
        m.backgroundInterp.reverse = "true"
        m.lg.visible = true
        m.listInterp.reverse = "true"
        m.previewAnimation.control = "start"
    end if
    debug(1, "homeScreen", "onPreviewStateChanged()", state)
end function

function onPreviewAnimationStateChanged(nodeEvent as object)
    state = nodeEvent.getData()
    if state = "stopped" and m.shadow.translation[1] = 555
        m.preview.visible = false
    end if
end function

function onItemSelected(nodeEvent as object)
    data = nodeEvent.getData()
    node = nodeEvent.getRoSGNode()
    if (data <> invalid)
        debug(1, "homeScreen", "onItemSelected()", node.subType(), nodeEvent.getField(), data.id, data)
    end if
    m.top.itemSelected = data
    m.top.itemSelected = invalid
end function

function onActionSelected(nodeEvent as object)
    data = nodeEvent.getData()
    debug(3, "homeScreen", "onActionSelected()", data)
    m.top.UnobserveField("action")
    if(data <> "")
        m.top.ObserveField("action", data)
    end if
    m.top.action = data
end function

function showMenu()
    if(not m.lastFocus.isSameNode(m.menu))
        debug(3, "homeScreen", "showMenu()", "")
        m.previewDelay.control = "stop"
        if m.preview.state = "playing"
            m.preview.control = "pause"
        end if    
        m.lastFocus = m.menu
        m.menu.expand = 1
        m.menu.setFocus(true)
        debug(1, "homeScreen", "showMenu()", "setFocus")
        return true
    end if
    return false
end function

function hideMenu()
    if(m.lastFocus.isSameNode(m.menu))
        debug(3, "homeScreen", "hideMenu()", "")
        m.menu.expand = 0
        m.lastFocus = m.list
        m.list.setFocus(true)
        debug(1, "homeScreen", "hideMenu()", "setFocus")
        return true
    end if
    return false
end function
