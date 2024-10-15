function init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.shadow = m.top.findNode("shadow")
    m.header = m.top.findNode("header")
    m.mainMenu = m.top.findNode("mainMenu")
    'm.mainMenu.itemSelected = 0
    m.mainMenu.observeField("itemSelected", "onItemSelected")
    m.mainMenu.observeField("content", "onContentChanged")
    m.mainMenu.observeField("jumpToItem", "onJumpToItemChanged")
    m.footer = m.top.findNode("footer")
    m.expandWidths = [10]
    m.headers = []
    m.footers = []
end function

function onFocusChanged(nodeEvent)
    data = nodeEvent.getData()
    if(m.top.isSameNode(data))
        m.mainMenu.jumpToItem = m.mainMenu.itemSelected
        m.mainMenu.setFocus(true)
    end if
end function

function updateNav(nodeEvent)
    field = nodeEvent.getField()
    data = nodeEvent.getData()
    m[field] = data
end function

function updateExpand(nodeEvent)
    data = nodeEvent.getData()
    if(m.expandWidths[data] = invalid) data = m.expandWidths.count() - 1
    m.shadow.width = data * ((m.header.translation[0] * 2) + m.expandWidths[data]) + 1
    m.mainMenu.itemSize = [m.expandWidths[data], m.mainMenu.itemSize[1]]
    m.header.removeChildrenIndex(m.header.getChildCount(), 0)
    m.footer.removeChildrenIndex(m.footer.getChildCount(), 0)
    if(data > 0)
        m.header.appendChild(m.headers[1])
        m.footer.appendChild(m.footers[1])
    else
        m.header.appendChild(m.headers[0])
        m.footer.appendChild(m.footers[0])
    end if
end function

function onItemSelected(nodeEvent)
    data = nodeEvent.getData()
    m.top.itemSelected = m.mainMenu.content.getChild(data)
end function

function onContentChanged(nodeEvent)
    data = nodeEvent.getData()
    debug(3, "sideNav", "onContentChanged()", data)
    jump = m.mainMenu.jumpToItem
    m.mainMenu.jumpToItem = -1
    m.mainMenu.jumpToItem = jump
end function

function onJumpToItemChanged(nodeEvent)
    data = nodeEvent.getData()
    m.mainMenu.unobserveField("itemSelected")
    m.mainMenu.itemFocused = data
    m.mainMenu.itemSelected = data
    m.mainMenu.observeField("itemSelected", "onItemSelected")
end function
