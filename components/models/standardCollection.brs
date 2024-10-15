function init()
end function

function onJsonChanged(nodeEvent as object)
    json = nodeEvent.getData()
    onBaseJsonChanged(json)

    if json <> invalid then
        m.top.collectionId = asString(json.collectionId)
    end if
end function
