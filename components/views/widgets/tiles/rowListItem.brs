function init() as void
	m.top.observeField("itemUnfocused", "onLayoutChanged", ["groupHasFocus"])
	m.top.observeField("currTarget", "onLayoutChanged", ["groupHasFocus"])
	m.top.observeField("currRect", "onLayoutChanged", ["groupHasFocus"])
	m.top.observeField("index", "onLayoutChanged", ["groupHasFocus"])
	m.top.observeField("groupHasFocus", "onLayoutChanged", ["groupHasFocus"])
	m.top.observeField("focusPercent", "onLayoutChanged", ["groupHasFocus"])
	m.top.observeField("itemHasFocus", "onLayoutChanged", ["groupHasFocus"])

	m.base = m.top.findNode("base") 
	m.itemImage = m.top.findNode("itemImage") 
	m.itemImage.ObserveField("loadStatus", "onStatusChange")
	m.itemText = m.top.findNode("itemText")
	m.content = invalid
end function

function itemContentChanged(nodeEvent as object)
	content = nodeEvent.getData()
	m.content = content
	debug(4, "rowListItem", "itemContentChanged()", content, content.image)
	if content <> invalid
		if content.image <> invalid and not isNullOrEmpty(content.title)
			m.itemImage.uri = content.image.tile
			m.itemText.text = content.title
		end if
	end if
end function

function onStatusChange(nodeEvent as object)
	loadStatus = nodeEvent.getData()
	m.itemText.visible = loadStatus = "failed"
end function

function onLayoutChanged(nodeEvent as object)
	value = nodeEvent.getData()
    field = nodeEvent.getField()
	context = nodeEvent.getInfo()
	debug(4, "rowListItem", field, context.groupHasFocus, m.content?.title, value)
	if field = "currRect"
		size = { width:value.width, height:value.height}
		m.base.update(size)
		m.itemImage.update(size)
		m.itemText.update(size)
	end if
end function

