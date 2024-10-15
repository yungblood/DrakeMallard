function init()
end function

function onJsonChanged(nodeEvent as object)
    json = nodeEvent.getData()
    onBaseJsonChanged(json)
end function
