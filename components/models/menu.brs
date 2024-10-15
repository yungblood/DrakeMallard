function init()
end function

function onJsonChanged(nodeEvent as object)
    json = nodeEvent.getData()
    if json <> invalid then
        m.top.id            = json.id
        m.top.title         = json.title
        m.top.foreground    = json.foreground
        m.top.background    = json.background
    end if
end function
