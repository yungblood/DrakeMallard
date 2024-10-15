function blank(var)
    showFunc("/library/utils.brs", "blank")
    if(type(var) = "Invalid")
        return true
    else if((type(var) = "String") and (var = "")) 
        return true
    end if
    return false
end function

function showFunc(file="unknown", func="unknown")
    print string(60,"*")
    print file; " - "; func; "()"
end function