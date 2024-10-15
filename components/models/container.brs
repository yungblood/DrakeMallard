function init()
end function

function onJsonChanged(nodeEvent as object)
    json = nodeEvent.getData()
    set = invalid
    for each key in json.keys()
        if lCase(key).right(3) = "set"
            set = json[key]
        end if
    next
    if set <> invalid then
        m.top.setId = asString(set.setId)
        m.top.refId = asString(set.refId)
        m.top.title = asString(set.text?.title?.full?.set?.default?.content)
        m.top.language = asString(set.text?.title?.full?.set?.default?.language)
        m.top.sourceEntity = asString(set.text?.title?.full?.set?.default?.sourceEntity)
        m.top.type  = asString(set.type)
        m.top.class  = asString(set.contentClass)
        if set.items <> invalid
            for each item in set.items
                node = invalid
                if item.type = "DmcSeries"
                    node = m.top.createChild("DmcSeries")
                else if item.type = "DmcVideo"
                    node = m.top.createChild("DmcVideo")
                else if item.type = "StandardCollection"
                    node = m.top.createChild("StandardCollection")
                else
                    ?"Unknown item type:", item.type, item
                end if
                if node <> invalid
                    node.json = item
                end if
            next
        end if
    end if
end function
