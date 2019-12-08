#=========================================================================
#
# Frontend main library
#
# 2017.07.21 coded by Hajime Oh-yake
#
#=========================================================================
GLOBAL = {}
ORIGIN = node_origin
LAPSEDTIME = Date.now()
__ACTORLIST = []

#=========================================================================
# remove element from Array
#=========================================================================
Array.remove = (xs) ->
  (x) ->
    xs.filter (_, i, arr) =>
      i != arr.indexOf(x)

#=========================================================================
# debug write
#=========================================================================
echo = (a, b...) ->
  if (node_env == "develop")
    for data in b
      if (typeof(data) == 'object')
        data = JSON.stringify(data)
      a = a.replace('%@', data)
    console.log(a)

#=========================================================================
# format strings
#=========================================================================
sprintf = (a, b...) ->
  for data in b
    if (typeof(data) == 'object')
      data = JSON.stringify(data)
    match = a.match(/%0\d*@/)
    if (match?)
      repstr = match[0]
      num = parseInt(repstr.match(/\d+/))
      zero =""
      zero += "0" while (zero.length < num)
      data2 = (zero+data).substr(-num)
      a = a.replace(repstr, data2)
    else
      a = a.replace('%@', data)
  return a

#=========================================================================
# real copy for object
#=========================================================================
objCopy = (a)->
  return $.extend(true, {}, a)

#=========================================================================
# rgba
#=========================================================================
CSSRGBA = (param, defvalue = undefined) ->
  if (!defvalue?)
    defvalue =
      red: 255
      green: 255
      blue: 255
      alpha: 1.0
  if (param?)
    red = if (param.red?) then param.red else defvalue.red
    green = if (param.green?) then param.green else defvalue.green
    blue = if (param.blue?) then param.blue else defvalue.blue
    alpha = if (param.alpha?) then param.alpha else defvalue.alpha
  else
    red = defvalue.red
    green = defvalue.green
    blue = defvalue.blue
    alpha = defvalue.alpha
  str = "rgba(#{red}, #{green}, #{blue}, #{alpha})"
  return str

#=========================================================================
# Color Object
#=========================================================================
FWColor = (r, g, b, a) ->
  return
    red: r
    green: g
    blue: b
    alpha: a

#=========================================================================
# create rect
#=========================================================================
FWRectMake = (x, y, w, h) ->
  origin =
    x: x
    y: y
  size =
    width: w
    height: h
  frame =
    origin: origin
    size: size
  return frame

#=========================================================================
# create range
#=========================================================================
FWRangeMake = (loc, len) ->
  range =
    location: loc
    length: len
  return range

#=========================================================================
# PATH search
#=========================================================================
FWSearchPathForDirectoriesInDomains = (kind)->
  switch (kind)
    when "FWPictureDirectory"
      path = "public/picture"
    when "FWPublicDirectory"
      path = "public"
    when "FWLibraryDirectory"
      path = "library"
    else
      path = undefined

  return path

#=========================================================================
# API Access function
#=========================================================================
FWAPICALL = (param, func = undefined) ->
  type = param.type || 'POST'
  file = node_pkg+"/api/"+param.file
  endpoint = param.endpoint
  headers = param.headers
  data = JSON.stringify(param.data) if (typeof param.data == 'object')
  url = "#{window.origin}/#{file}/#{endpoint}"
  $.ajaxSetup
    type    : type
    dataType: 'json'
    timeout : 30000
    headers:
      'pragma'           : 'no-cache'
      'Cache-Control'    : 'no-cache'
      'If-Modified-Since': 'Thu, 01 Jun 1970 00:00:00 GMT'
  $.ajax
    url:url
    headers: headers
    data: data
  .done (ret) ->
    func(ret) if (typeof(func) == "function")
  .fail (jqXHR, textStatus, errorThrown)->
    func
      err: -1
      message: textStatus

#=========================================================================
# return toggle
#=========================================================================
toggle = (value) ->
  return !value

#=========================================================================
# execute a number of times
#=========================================================================
timesFunc = (num, func) ->
  for i in [0...num]
    func()

#=========================================================================
# escape HTML tag
#=========================================================================
escapeHTML = (s) ->
  escapeRules =
    "&": "&amp;"
    "\"": "&quot;"
    "<": "&lt;"
    ">": "&gt;"
  s.replace /[&"<>]/g, (c) ->
    escapeRules[c]

#=========================================================================
# boot proc
#=========================================================================
$ ->
  requestAnimationFrame = window.requestAnimationFrame ||
              window.mozRequestAnimationFrame ||
              window.webkitRequestAnimationFrame ||
              window.msRequestAnimationFrame
  window.requestAnimationFrame = requestAnimationFrame

  #=========================================================================
  # animation frame
  #=========================================================================
  __animationRequest = (func) ->
    func()
    window.requestAnimationFrame ->
      __animationRequest(func)

  __animationRequest ->
    LAPSEDTIME = Date.now()
    for id, obj of __ACTORLIST
      if (typeof(obj.behavior) == 'function')
        obj.behavior()

  $.Finger =
    pressDuration: 300
    doubleTapInterval: 100
    flickDuration: 150
    motionThreshold: 5

  $("html").css("width", "100%")
  $("html").css("height", "100%")
  $("html").css("overflow", "hidden")
  $("body").css("position", "absolute")
  $("body").css("top", "0px")
  $("body").css("left", "0px")
  $("body").css("right", "0px")
  $("body").css("bottom", "0px")
  $("body").css("overflow", "auto")

  $(document).on "contextmenu", (e) =>
    e.preventDefault()
    return false
  frm = FWApplication.getBounds()
  main = new applicationMain(frm)
  __ACTORLIST[main.UniqueID] = main
  main.borderWidth = 0.0
  main.containment = true
  main.clipToBounds = true
  main.backgroundColor = FWColor(255, 255, 255, 1.0)
  main.__setFrame(frm)
  timer = false
  window.onresize = ->
    if (timer != false)
      clearTimeout(timer)
    timer = setTimeout ->
      frm = FWApplication.getBounds()
      $(main.__viewSelector).css("width", frm.size.width)
      $(main.__viewSelector).css("height", frm.size.height)
      main.didBrowserResize(frm)
    , 300
  $("body").append(main.__element)
  main.setStyle()
  main.__bindGesture()
  main.__setTouches()
  GLOBAL['rootview'] = main

  main.didFinishLaunching()

