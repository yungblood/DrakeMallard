function init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("content", "onContentChanged")
    m.list = m.top.findNode("list")
    m.listAnim = m.top.findNode("listAnim")
    m.listAnim.observeField("state", "onListAnimStateChanged")
    m.listInterp = m.top.findNode("listInterp")
    m.listInterp.observeField("fraction", "onListInterpFractionChanged", ["reverse","key","keyValue"])
    m.rows = []
    m.rowPositions = []
    m.carouselFields = {}
    m.listFields = {}
    m.keyPressed = ""
    m.currFocusRow = -1
    m.rowSelected = -1
    m.rowFocused = -1
    m.rowUnfocused = -1
    m.animItemIndex = -1
    m.indexMethod = "jump"
    m.internalRowUnfocused = 0
    m.internalRowFocused = 0
    m.fieldTypes = m.top.getFieldTypes()
end function

sub onFocusChanged(nodeEvent as object)
    focus = nodeEvent.getData()
    debug(1, "GrowthRowList", "onFocusChanged()", focus)

    if m.top.hasFocus() then
        if m.rows[m.internalRowFocused] <> invalid
            m.rows[m.internalRowFocused].setFocus(true)
            debug(1, "GrowthRowList", "onFocusChanged()", "setFocus")
        end if
        debug(2, "GrowthRowList", "node", m.top)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        debug(1, "growthRowList", "onKeyEvent()", key)
        unfocused = m.internalRowFocused
        if key = "up"
            if m.internalRowFocused > 0
                m.internalRowFocused--
                handled = true
            end if
        else if key = "down"
            if m.internalRowFocused < m.list.getChildCount() - 1
                m.internalRowFocused++
                handled = true
            end if
        end if
        if handled
            m.keyPressed = key
            m.internalRowUnfocused = unfocused
            m.list.getChild(m.internalRowFocused).setFocus(true)
            debug(1, "GrowthRowList", "onKeyEvent()", "setFocus")
            m.listInterp.reverse = unfocused > m.internalRowFocused
            m.listInterp.keyValue = [m.rowPositions[unfocused], m.rowPositions[m.internalRowFocused]]
            m.listAnim.control = "start"
        end if
    else
        if m.keyPressed <> ""
            handled = true
            m.keyPressed = ""
        end if
    end if
    return handled
end function


function onCarouselFieldChanged(nodeEvent as object)
    value = nodeEvent.getData()
    field = nodeEvent.getField()
    m.carouselFields[field] = value
    updateCarouselField(field, value)
end function

function updateCarouselField(field as string, value as object)
    for each row in m.rows
        row[field] = value
    next
end function

function onContentChanged(nodeEvent as object)
    content = nodeEvent.getData()
    m.list.removeChildrenIndex(m.list.getChildCount(), 0)
    m.rows = []
    m.rowPositions = []

    for c = 0 to content.getChildCount() - 1
        debug(4, "GrowthRowList", "row", content.getChild(c).title)
        row = m.list.createChild("GrowthRow")
        for each item in m.carouselFields.items()
            field = item.key
            value = item.value
            debug(4, "GrowthRowList", field, value)
            if m.fieldTypes[field]?.right?(5) = "array"
                row[field] = value[0]
            else
                row[field] = value
            end if
            debug(2, "GrowthRowList", "onContentChanged()", field, row[field])
        next
        row.content = content.getChild(c)
        row.observeField("currFocusItemIndex", "onRowCurrFocusItemChanged")
        row.observeField("itemSelected", "onRowFocusItemChanged")
        row.observeField("itemFocused", "onRowFocusItemChanged")
        row.observeField("itemUnfocused", "onRowFocusItemChanged")
        m.rows.push(row)
        m.rowPositions.push(c*m.carouselFields.itemSize[1])
    next
    m.list.getChild(m.internalRowFocused).setFocus(true)
    debug(1, "GrowthRowList", "onContentChanged()", "setFocus")
    if m.rowFocused = -1
        m.top.rowItemFocused = [0,0]
        m.rowFocused = 0
    end if
end function

function onListFieldChanged(nodeEvent as object)
    value = nodeEvent.getData()
    field = nodeEvent.getField()
    'm.carouselFields[field] = value
    'updateCarouselField(field, value)
end function

function onIndexFieldChanged(nodeEvent as object)
    value = nodeEvent.getData()
    field = nodeEvent.getField()
    'm.carouselFields[field] = value
    'updateCarouselField(field, value)
end function

function onRowCurrFocusItemChanged(nodeEvent as object)
    currFocusItem = nodeEvent.getData()
    row = nodeEvent.getRoSgNode()
    for c = 0 to m.rows.count() - 1
        if row.isSameNode(m.rows[c])
            m.top.currFocusColumn = c
            exit for
        end if
    next
end function

function onRowFocusItemChanged(nodeEvent as object)
    itemIndex = nodeEvent.getData()
    rowIndex = -1
    field = nodeEvent.getField()
    row = nodeEvent.getRoSgNode()
    for c = 0 to m.rows.count() - 1
        if row.isSameNode(m.rows[c])
            rowIndex = c
            exit for
        end if
    next
    debug(2, "GrowthRowList", "row", field, rowIndex, itemIndex)
    m.top["row" + changeFirstCase(field)] = [rowIndex, itemIndex]
end function

function onListAnimStateChanged(nodeEvent as object)
    state = nodeEvent.getData()
    if state = "stopped" 
        if m.keyPressed <> ""
            onKeyEvent(m.keyPressed, true)
        else
            rowIndex = m.internalRowFocused
            itemIndex = max(0, m.rows[m.internalRowFocused].itemFocused)
            m.top.rowItemFocused = [rowIndex, itemIndex]
            m.rowFocused = rowIndex
        end if
    end if
    debug(2, "GrowthRowList", "onListAnimStateChanged()", state, m.keyPressed)
end function

function onListInterpFractionChanged(nodeEvent as object)
    fraction = nodeEvent.getData()
    context = nodeEvent.getInfo() '["reverse","key","keyValue"]
    debug(2, "GrowthRowList", "onListInterpFractionChanged()", fraction, context.reverse, formatJson(context.key), formatJson(context.keyValue))
    if context.reverse
        fraction = 1 - fraction
    end if
    diff = abs(context.keyValue[1] - context.keyValue[0])
    position = min(context.keyValue[1], context.keyValue[0]) + (fraction * diff)
    m.list.translation = [m.list.translation[0], 0 - position]
    m.list.clippingRect = [0, position, 1920, position + 99999]
end function
