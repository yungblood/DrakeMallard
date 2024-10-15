function init()
    debug(3, "detailScreen", "init()", "")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("content", "onContentChanged")
    m.background = m.top.FindNode("background")
    m.label = m.top.FindNode("label")
end function

sub onFocusChanged(nodeEvent as object)
    focus = nodeEvent.getData()
    debug(1, "detailScreen", "onFocusChanged()", focus)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if(press)
        debug(1, "detailScreen", "onKeyEvent()", key)
        if(key = "back")
            m.top.close = true
            return true
        end if
    else
        return true
    end if
    return false
end function

function onContentChanged(nodeEvent as object)
    content = nodeEvent.getData()
    debug(1, "detailScreen", "onContentChanged()", content)
    if content.image.background <> invalid
        m.background.uri = content.image.background
    else
        m.background.uri = content.image.hero_collection
    end if
    m.label.text = formatJson(content.json)
    m.top.setFocus(true)
end function
