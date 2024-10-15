function init()
    m.layout = m.top.findNode("layout")
    m.icon = m.top.findNode("icon")
    m.iconBg = m.top.findNode("iconBg")
    m.title = m.top.findNode("title")
    m.top.observeField("itemHasFocus", "onFocusChanged")
    m.parent = m.top.getParent()
    m.parent.observeField("focusedChild", "onParentFocusChanged")
    m.parent.observeField("itemSelected", "onItemSelected")
    m.parent.observeField("jumpToItem", "onItemSelected")
    m.parent.observeField("itemFocused", "onItemFocused")
end function

sub onContentChanged(nodeEvent as object)
    m.content = nodeEvent.getData()
    m.iconBg.uri = m.content.background
    m.icon.uri = m.content.foreground
    m.title.text = m.content.title

    updateFocus(m.top.focusPercent)
    updateSelected(m.parent.itemSelected)
end sub

function onParentFocusChanged(nodeEvent as object)
    data = nodeEvent.getData()
    if(data = invalid) updateFocus(0)
end function

function onItemSelected(nodeEvent as object)
    data = nodeEvent.getData()
    updateSelected(data)
end function

function onItemFocused(nodeEvent as object)
    data = nodeEvent.getData()
    focused = m.parent.content.getChild(data)
    if((m.content <> invalid) and (focused <> invalid))
        if(focused.id = m.content.id)
            updateFocus(1)
        else
            updateFocus(0)
        end if
    end if
end function

function onFocusChanged(nodeEvent as object)
    data = nodeEvent.getData()
    if(data)
        updateFocus(1)
    else
        updateFocus(0)
    end if
end function

sub onFocusPercentChanged(nodeEvent as object)
    percent = nodeEvent.getData()
    updateFocus(percent)
end sub

sub onGridFocusChanged(nodeEvent as object)
    focused = nodeEvent.getData()
    if focused then
        updateFocus(m.top.focusPercent)
    else
        updateFocus(0)
    end if
end sub

function updateSelected(item as integer)
    selected = m.parent.content.getChild(item)
    if((m.content <> invalid) and (selected <> invalid))
        if(selected.id = m.content.id)
            m.iconBg.blendColor = "0x204da4ff" 'Darker version of CBS-blueish
        else
            m.iconBg.blendColor = "0x00000000" 
        end if
    end if
end function

function updateFocus(percent as float)
    if(percent > 0)
        m.title.color = "0x2457b8ff" 'Note: Text needs to be a little brighter, for readability
    else
        m.title.color = "0xffffffff"
    end if
end function
