function init()
    m.top.functionName = "doWork"
end function

function doWork()
    debug(4, "homeTask", "doWork", true)
    response = http().makeRequest("https://cd-static.bamgrid.com/dp-117731241344/home.json", "GET")
    debug(4, "homeTask", "response", response)

    content = CreateObject("roSgNode", "ContentNode")
    json = parseJson(response.body)
    if json?.data?.StandardCollection <> invalid
        collection = json.data.StandardCollection
        pageTitle = collection?.text?.title?.full?.collection?.default?.content
        content = CreateObject("roSgNode", "ContentNode")
        for each container in collection.containers
            node = content.createChild("Container")
            node.json = container
        next
        response.body = ""
        response.content = content
        response.pageTitle = pageTitle
    end if

    m.top.response = response
end function