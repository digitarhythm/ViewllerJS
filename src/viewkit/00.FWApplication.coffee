#=============================================================================
#
# Application Library Class
#
#=============================================================================

class FWApplication
  #=========================================================================
  # YES/NO dialog
  #=========================================================================
  @isConfirm = (str, func = undefined)->
    if (window.confirm(str))
      return true
    else
      return false

  #=========================================================================
  # get cookie value
  #=========================================================================
  @getCookieValue = (arg)->
    if (arg)
      cookieData = document.cookie + ";"
      startPoint1 = cookieData.indexOf(arg)
      startPoint2 = cookieData.indexOf("=",startPoint1)+1
      endPoint = cookieData.indexOf(";",startPoint1)
      if(startPoint2 < endPoint && startPoint1 > -1)
        cookieData = cookieData.substring(startPoint2,endPoint)
        cookieData = cookieData
        return cookieData
    return false

  #=========================================================================
  # get unique id
  #=========================================================================
  @getUniqueID:->
    S4 = ->
      return (((1+Math.random())*0x10000)|0).toString(16).substring(1)
    return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4())

  #=========================================================================
  # get browser size(include scrolling bar)
  #=========================================================================
  @getBounds = ->
    width = document.documentElement.clientWidth - 2
    height = document.documentElement.clientHeight - 2
    frame = FWRectMake(0, 0, width, height)
    return frame

  #=========================================================================
  # Color management
  #=========================================================================
  @color = (color)->
    ret = color
    switch color
      when "clearColor"
        ret = "transparent"
    return ret

  #=========================================================================
  # get random value
  #=========================================================================
  @random = (max)->
    return Math.floor(Math.random() * (max + 1))

  #=========================================================================
  # sanitize string
  #=========================================================================
  @escape = (str)->
    if (str?)
      str = str.replace(/&/g, "&amp;")
      str = str.replace(/\'/g, "&quot;")
      str = str.replace(/\"/g, "&quot;")
      str = str.replace(/</g, "&lt;")
      str = str.replace(/>/g, "&gt;")
    return str

  #=========================================================================
  # number of object member
  #=========================================================================
  @objectNum = (obj)->
    if (obj?)
      return Object.keys(obj).length
    else
      return 0

  #=========================================================================
  # touch event check
  #=========================================================================
  @isTouch = ->
    return ('ontouchstart' of window)

  #=========================================================================
  # Android check
  #=========================================================================
  @isAndroid = ->
    return navigator.userAgent.indexOf('Android') != -1

  #=========================================================================
  # get browser kind
  #=========================================================================
  @getBrowser = ->
    ua = navigator.userAgent
    if (ua.match(".*iPhone.*"))
      os = 'iOS'
    else if (ua.match(".*Android"))
      os = 'Android'
    else if (ua.match(".*Windows.*"))
      os = 'Windows'
    else if (ua.match(".*BlackBerry.*"))
      os = 'BlackBerry'
    else if (ua.match(".*Symbian.*"))
      os = 'Symbian'
    else if (ua.match(".*Macintosh.*"))
      os = 'Mac'
    else if (ua.match(".*Linux.*"))
      os = 'Linux'
    else
      os = 'Unknown'

    if (ua.match(".*Safari.*") && !ua.match(".*Android.*") && !ua.match(".*Chrome.*"))
      browser = 'Safari'
    else if (ua.match(".*Gecko.*Firefox.*"))
      browser = "Firefox"
    else if (ua.match(".*Opera*"))
      browser = "Opera"
    else if (ua.match(".*MSIE*"))
      browser = "MSIE"
    else if (ua.match(".*Gecko.*Chrome.*"))
      browser = "Chrome"
    else
      browser = 'Unknown'

    return {os:os, browser:browser}


  #=========================================================================
  # contextmenu
  #=========================================================================
  @contextmenu:(func)->
    if (func? && typeof(func) == 'function')
      document.body.addEventListener "contextmenu", (e)=>
        e.preventDefault()
        pos =
          pageX: e.pageX
          pageY: e.pageY
          offsetX: e.offsetX
          offsetY: e.offsetY
        func(pos, e)
        return false

