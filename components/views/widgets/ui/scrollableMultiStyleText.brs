function init()
    m.label = m.top.findNode("label")
    m.track = m.top.findNode("track")
    m.thumb = m.top.findNode("thumb")
    m.scrollHeight = 0
    m.labelTop = 0
    m.key = ""
    m.label.enableRenderTracking = true
    m.label.observeField("renderTracking", "onRenderTrackChanged")
    m.keyTimer = m.top.findNode("keyTimer")
    m.keyTimer.ObserveField("fire","animateScroll")
    m.size = 1
    m.scrollSize = 10
end function

function onFieldChanged(nodeEvent)
    data = nodeEvent.getData()
    field = nodeEvent.getField()
    if (field = "text")
        m.label[field] = data
        m.label.translation = [m.label.translation[0], m.labelTop]
        m.thumb.translation = [0, 0]
        updateLayout(m.top.width, m.top.height, data)
        m.label.clippingRect = [0, 0, m.top.width, m.track.height]
    else if (field = "height")
        updateLayout(m.top.width, data)
    else if (field = "width")
        updateLayout(data)
    else
        m.label[field] = data
    end if
end function

function updateLayout(width = m.top.width as float, height = m.top.height as float, text = m.top.text as string)
    m.track.visible = false
    if not isNullOrEmpty(text) and height > 0 and width > 0
        m.track.visible = true
        m.label.height = 0
        m.label.width = width - 30
        m.scrollHeight = m.label.boundingRect().height
        m.track.height = height
        m.track.translation = [width + 6,0]
        m.size = 1
        if m.scrollHeight > height
            m.size = height / m.scrollHeight
        end if
        m.thumb.height = height * m.size
    else
        m.track.visible = false
    end if
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if(key = "down") or (key = "up")
        if(press)
            m.key = key
        else
            m.key = ""
        end if
        animateScroll()
        return true
    end if
    return false
end function

function animateScroll(mode = m.key as string)
    if not isNullOrEmpty(m.key)
        thumbPosition = m.thumb.translation[1]
        labelX = m.label.translation[0]
        labelPosition = m.label.translation[1]
        if m.key = "up" and thumbPosition > 0
            thumbPosition -= m.scrollSize
            labelPosition += m.scrollSize / m.size
        else if m.key = "down" and thumbPosition < m.track.height - m.thumb.height
            thumbPosition += m.scrollSize
            labelPosition -= m.scrollSize / m.size
        end if
        m.thumb.translation = [0, thumbPosition]
        m.label.translation = [labelX, labelPosition]
        m.label.clippingRect = [0, m.labelTop - labelPosition, m.top.width, m.track.height]
        m.keyTimer.control = "start"
    else
        m.keyTimer.control = "stop"
    end if
end function

function onRenderTrackChanged()
    if not isNullOrEmpty(m.label.text)
        if m.label.inheritParentTransform
            scene = m.label.sceneBoundingRect()
            m.label.inheritParentTransform = false
            m.label.translation = [scene.x, scene.y]
            m.labelTop = scene.y
        end if
        updateLayout()
    end if
end function