function isNullOrEmpty(obj)
    if obj = invalid then return true
    if(type(obj) = "String") or (type(obj) = "roString")
        if(obj = "") return true
    else if(type(obj) = "roAssociativeArray")
        if(obj.keys().count() = 0) return true
    else if(type(obj) = "roArray")
        if(obj.count() = 0) return true
    end if
    return false
end function

function asString(obj as object, default = "" as string) as string
    if obj <> invalid
        objType = type(obj)
        if objType = "roString" then return obj
        if objType = "roInt" or objType = "roFloat" then return obj.toStr()
        if objType = "roBoolean" then
            if obj then
                return "true"
            else
                return "false"
            end if
        end if
    end if
    return default
end function

function asInteger(obj as object, default = 0 as integer) as integer
    if obj <> invalid
        objType = type(obj)
        if objType = "roInt" then return obj
        if objType = "roString" then return obj.toInt()
        if objType = "roBoolean" and obj then return 1
    end if
    return default
end function

function asFloat(obj as object, default = 0 as float) as float
    if obj <> invalid
        objType = type(obj)
        if objType = "roInt" or objType = "roFloat" then return obj
        if objType = "roString" then return obj.toFloat()
    end if
    return default
end function

function asBoolean(obj as object, default = false as boolean) as boolean
    if obj <> invalid
        objType = type(obj)
        if objType = "roBoolean" then return obj
        if objType = "roString" and lCase(obj) = "true" then return true
        if objType = "roInt" and obj > 0 then return true
    end if
    return default
end function

function iif(check as boolean, obj1, obj2)
    if(check) return obj1
    return obj2
end function

function readJsonFile(base as string, locale = "" as string, file = "" as string, backupLocale = "" as string)
    jsonFile = [base, locale, file].join("")
    backup = [base, backupLocale, file].join("")
    if not fileExists(jsonFile)
        if isNullOrEmpty(backupLocale) return invalid
        if not fileExists(backup) return invalid
            jsonFile = backup
    end if
    data = readAsciiFile(jsonFile)
    if (isNullOrEmpty(data)) return invalid
    json = parseJson(data)
    if (isNullOrEmpty(json)) return invalid
    return json
end function

function fileExists(file as string)
    if (isNullOrEmpty(file)) return false
    pieces = file.split("/")
    fileName = pieces.pop()
    pathName = pieces.join("/") + "/"
    match = matchFiles(pathName, fileName)
    if (match.count() = 0) return false
    return true
end function

function debug(level as integer, file as string, label as string, value1 = "", value2 = "", value3 = "", value4 = "", value5 = "")
    if(m.debugLevel = invalid)
        appInfo = createObject("roAppInfo")
        if(not appInfo.isDev()) return invalid
        m.debugLevel = val(appInfo.getValue("debugLevel"), 0)
    end if
    if(file.len() < 23) file += string(23 - file.len(), " ")
    if(m.debugLevel >= level)
        ?"Debug: "; file, level; " /"; m.debugLevel, label, value1, value2, value3, value4, value5
    end if
end function

function aaMerge(array1 = {} as object, array2 = {} as object, array3 = {} as object, array4 = {} as object, array5 = {} as object, array6 = {} as object, array7 = {} as object, array8 = {} as object, array9 = {} as object)
    aa = {}
    if(type(array1) = "roAssociativeArray") aa.append(array1)
    if(type(array2) = "roAssociativeArray") aa.append(array2)
    if(type(array3) = "roAssociativeArray") aa.append(array3)
    if(type(array4) = "roAssociativeArray") aa.append(array4)
    if(type(array5) = "roAssociativeArray") aa.append(array5)
    if(type(array6) = "roAssociativeArray") aa.append(array6)
    if(type(array7) = "roAssociativeArray") aa.append(array7)
    if(type(array8) = "roAssociativeArray") aa.append(array8)
    if(type(array9) = "roAssociativeArray") aa.append(array9)
    return aa
end function

function changeFirstCase(str as string) as string
    first = str.left(1)
    if (lCase(first) = first)
        first = uCase(first)
    else
        first = lCase(first)
    end if
    return first + str.mid(1)
end function

function node2Array(node as object)
    if(type(node) = "roSGNode")
        fields = ["change", "focusable", "focusedChild", "id"]
        array = node.getFields()
        for each field in fields
            array.delete(field)
        next
        for each key in array.keys()
            if type(array[key]) = "roSGNode"
                array.delete(key)
            end if
        next
        return array
    end if
    return node
end function

function asOneLine(text as string) as string
    return text.replace(chr(10)," ").replace(chr(13),"")
end function

function getAPIJson(data as object) as object
    json = invalid
    if not isNullOrEmpty(data.file)
        json = readJsonFile(data.file)
    else if not isNullOrEmpty(data.body)
        json = parseJson(data.body)
    end if
    return json
end function

function addGlobal(fieldname as string, value as object, fieldtype as string, alwaysNotify = true as boolean)
    if(m.global[fieldname] = invalid) m.global.addField(fieldname, fieldtype, alwaysNotify)
    m.global[fieldname] = value
end function

function showSpinner(visible = true as boolean)
    scene = m.top.getScene()
    if scene <> invalid
        spinner = scene.findNode("spinner")
        if spinner = invalid
            screenSize = scene.boundingRect()
            layout = scene.createChild("LayoutGroup")
            layout.inheritParentTransform = false
            layout.translation = [1920/2,1080/2]
            layout.horizAlignment = "center"
            layout.vertAlignment = "center"
            spinner = layout.createChild("BusySpinner")
            spinner.id = "spinner"
            spinner.poster.uri = "pkg:/images/loader.png"
        end if
        if spinner <> invalid
            spinner.visible = visible
            spinner.control = iif(visible, "start", "stop")
        end if
    end if
end function

function isDev()
    appInfo = CreateObject("roAppInfo")
    return appInfo.isDev() and asBoolean(appInfo.getValue("localConfig"))
end function

function max(a as float, b as float) as object
    if a > b then return a
    return b
end function

function min(a as float, b as float) as object
    if a < b then return a
    return b
end function

function avg(value = invalid, depth = 10 as integer)
    ret = 0
    if m.avg = invalid
        m.avg = []
    end if
    if lCase(type(value)).inStr("int") > -1
        m.avg.push(value)
    end if
    delta = m.avg.count() - depth
    for i = m.avg.count() - 1 to 0 step -1
        if i > delta
            ret += m.avg[i]
        else
            m.avg.shift()
        end if
    end for
    if m.avg.count() = 0 then return 0
    return ret / m.avg.count()
end function

function strcmp(a as string, b as string) as integer
    diff = 0
    p = 0
    lenA = a.len()
    lenB = b.len()
    minl = min(lenA, lenB)
    while diff = 0 and p < minl
        diff = asc(b.mid(p,1)) - asc(a.mid(p,1))
        p++
    end while
    if diff = 0 and lenA <> lenB
        if lenA > lenB
            return 0 - asc(a.mid(p,1))
        else
            return asc(b.mid(p,1))
        end if
    end if
    return diff
end function

function strMatchLen(a as string, b as string) as integer
    diff = 0
    p = 0
    lenA = a.len()
    lenB = b.len()
    minl = min(lenA, lenB)
    while p < minl
        diff = asc(b.mid(p,1)) - asc(a.mid(p,1))
        if diff <> 0 then return p
        p++
    end while
    return p
end function

function getNowMS() as string
    time = createObject("roDateTime")
    return asString(time.asSeconds()) + asString(time.getMilliSeconds() + 1000).right(3)
end function

function getTimeDiff(begin as string, finish as string) as integer
    match = strMatchLen(begin, finish)
    return asInteger(finish.mid(match)) - asInteger(begin.mid(match))
end function
