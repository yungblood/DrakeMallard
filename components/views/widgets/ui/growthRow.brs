function init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("content", "onContentChanged")
    m.rowHeader = m.top.findNode("rowHeader")
    m.rowLabel = m.top.findNode("rowLabel")
    m.rowCounter = m.top.findNode("rowCounter")
    m.list = m.top.findNode("list")
    m.list.observeField("currFocusItemIndex", "onListFieldChanged")
    m.list.observeField("itemSelected", "onListFieldChanged")
    m.list.observeField("itemFocused", "onListFieldChanged")
    m.list.observeField("itemUnfocused", "onListFieldChanged")
    m.list.observeField("currTargetSet", "onListCurrTargetSetChanged")
    m.focused = m.top.findNode("focused")
    m.itemSpacing = m.top.findNode("itemSpacing")

    m.carouselFields = {}
    m.focusedTargetSet = createObject("roSGNode", "TargetSet")
    m.focusedTargetSet.focusIndex = 0
    m.unfocusedTargetSet = createObject("roSGNode", "TargetSet")
    m.unfocusedTargetSet.focusIndex = 0
    'm.list.showTargetRects = true
    m.list.advanceKey = "right"
    m.list.reverseKey = "left"
    m.customLabel = invalid
end function

sub onFocusChanged(nodeEvent as object)
    focus = nodeEvent.getData()
    debug(1, "growthRow", "onFocusChanged()", focus)
    if focus <> invalid then
        m.list.targetSet = m.focusedTargetSet
        if not focus.isSameNode(m.list)
            m.list.setFocus(true)
            debug(1, "growthRow", "onFocusChanged()", "setFocus")
            m.top["currFocusColumn"] = m.list.["currFocusItemIndex"]
            m.top["itemFocused"] = m.list.["itemFocused"]
            debug(1, "GrowthRow", "node", m.list)
        end if
    else
        m.list.targetSet = m.unfocusedTargetSet
        m.focused.opacity = 0
    end if
end sub

function onListFieldChanged(nodeEvent as object)
    value = nodeEvent.getData()
    field = nodeEvent.getField()
    if field = "currFocusItemIndex"
        field = "currFocusColumn"
        m.focused.opacity = 0
    else if field = "itemFocused"
        if m.list.hasFocus()
            if m.focused.width = 0
                targetSet = m.focusedTargetSet
                targetRect = targetSet.targetRects[targetSet.focusIndex]
                if targetRect <> invalid
                    m.focused.width = targetRect.width
                    m.focused.height = targetRect.height
                    m.focused.translation = [targetRect.x, targetRect.y]
                end if
            end if
            m.focused.opacity = 1
            content = m.list.content.getChild(value)
            if content?.image?.tile <> invalid
                m.focused.uri = content.image.tile
            else
                m.focused.uri = "pkg:/images/missing.jpg"
            end if
        end if
    end if
    m.top[field] = value
end function

function onCarouselFieldChanged(nodeEvent as object)
    value = nodeEvent.getData()
    field = nodeEvent.getField()
    if value <> invalid
        m.carouselFields[field] = value
        if field = "rowLabelColor" or field = "rowLabelFont"
            nodeField = lcase(field.mid(8))
            m.rowLabel[nodeField] = value
            m.rowCounter[nodeField] = value
        else if field = "itemSpacing"
            m.itemSpacing.height = value[1]
        else if field = "rowTitleComponentName"
            m.customLabel = m.rowHeader.createChild(value)
            if m.customLabel <> invalid
                m.rowHeader.removeChildrenIndex(m.rowHeader.getChildCount() - 1, 0)
            end if
        end if
    else
        m.carouselFields.delete(field)
    end if
end function

function onContentChanged(nodeEvent as object)
    content = nodeEvent.getData()
    if content <> invalid
        if m.customLabel <> invalid
            m.customLabel.text = content.title
        else
            m.rowLabel.text = content.title
        end if
        createTargetSet()
        m.list.setFocus(true)
        debug(1, "growthRow", "onContentChanged()", "setFocus")
    end if
    debug(2, "GrowthRow", "onContentChanged", content.title, content.getChildCount(), m.list)
end function

function createTargetSet()
    if m.carouselFields.itemSize <> invalid and m.carouselFields.rowItemSize <> invalid
        rowItemSpacing = m.carouselFields.rowItemSpacing[0]
        itemSize = m.carouselFields.itemSize
        rowItemSize = m.carouselFields.rowItemSize
        width = rowItemSize[0]
        height = rowItemSize[1]
        numColumns = int(itemSize[0] / (width + rowItemSpacing))
        
        growthPercentage = m.carouselFields.growthPercentage
        unfocusedTargetRects = []
        for c = 0 to numColumns
            unfocusedTargetRects.push({ x:c*(width+rowItemSpacing), y:-(height/2), width:width, height:height })
        next
        m.unfocusedTargetSet.targetRects = unfocusedTargetRects
        focusedTargetRects = []
        focusedTargetRects.append(unfocusedTargetRects)
        growthWidth = width + (width * growthPercentage)
        growthHeight = height + (height * growthPercentage)
        focusedTargetRects[m.focusedTargetSet.focusIndex] = {x:m.focusedTargetSet.focusIndex*(width+rowItemSpacing), y:-(growthHeight/2), width:growthWidth, height:growthHeight }
        m.focusedTargetSet.targetRects = focusedTargetRects
    end if
end function

function onListCurrTargetSetChanged(nodeEvent as object)
    value = nodeEvent.getData()
    debug(4, "GrowthRow", "onListCurrTargetSetChanged", value)
end function