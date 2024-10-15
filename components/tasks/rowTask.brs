function init()
    m.top.functionName = "doWork"
    m.port = CreateObject("roMessagePort")
    m.top.observeField("refId", m.port)
end function

function doWork()
    msg = wait(0, m.port)
    if(type(msg) = "roSGNodeEvent")
        refId = msg.getData()
        debug(2, "rowTask", "refId", refId)
        response = http().makeRequest("https://cd-static.bamgrid.com/dp-117731241344/sets/" + refId + ".json", "GET")
        debug(4, "rowTask", "response", response)

        json = parseJson(response.body)
        debug(2, "rowTask", "json", json)
        response.body = ""
        response["refId"] = refId
        if json?.data <> invalid
            node = createObject("roSgNode", "Container")
            node.json = json.data
            response.row = node
            debug(2, "rowTask", "node", node)
        end if
        m.top.response = response
    end if
end function