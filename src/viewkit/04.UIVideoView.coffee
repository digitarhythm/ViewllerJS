#============================================================================#
# video display class
#============================================================================#

class UIVideoView extends UIView
  constructor:(param)->
    super(param)

    # values
    @videoid = "#"+@UniqueID+"_video"
    @playflag = undefined
    @func = undefined
    @loop = false
    @autoplay = false

    # add video element
    @__style.video = undefined
    @__style.controls = false

    # add private element
    @__parentelement = @__addelement
    @__videoelement = document.createElement("video")
    @__videoelement.setAttribute("id", @UniqueID+"_video")
    @__videoelement.addEventListener 'play', =>
      @playflag = true
    @__videoelement.addEventListener 'pause', (obj) =>
      @playflag = false

  destructor:->
    super()

  viewDidLoad:->
    super()
    @clipToBounds = true
    @__videoelement.autoplay = @autoplay
    @__videoelement.loop = @loop
    if (@controls)
      @__videoelement.setAttribute("controls", "")
    else
      @__videoelement.removeAttribute("controls")

  viewDidAppear:->
    super()
    @__parentelement.appendChild(@__videoelement)

    # video onload event
    @__element.addEventListener "loadedmetadata", =>
      @__videoelement.style.width = "#{@frame.size.width}px"
      @__videoelement.style.height = "#{@frame.size.height}px"
      @__videoelement.style.position = "absolute"
      @__videoelement.style.left = "0px"
      @__videoelement.style.top = "0px"
      @vidwidth = @__videoelement.videoWidth
      @vidheight = @__videoelement.videoHeight

    @__element.addEventListener "loadeddata", =>
      if (@func?)
        @func(@)
        @func = undefined

  didBrowserResize:->
    super()

  bringViewToFront:->
    super()
    if (@playflag)
      @play()

  setVideo:(video = undefined, func = undefined)->
    if (func?)
      @func = func

    if (video?)
      @video = video
      if (video != "")
        prefix = @video.match(/^(http|https):.*$/)
        if (!prefix? || prefix.length < 2)
          videosrc = "#{pkgname}/public/#{@video}"
        else
          videosrc = @video
        @__videoelement.autoplay = @autoplay
        @__videoelement.loop = @loop
        @__videoelement.src = videosrc
      else
        @__videoelement.src = ""
    else
      @__videoelement.src = ""

  play:->
    @__videoelement.play()

  pause:->
    @__videoelement.pause()

#=============================================================================
# Style Method
#=============================================================================
  setStyle:(param)->
    super(param)

    if (@__checkParameterKey(param, ["frame"]))
      @__videoelement.style.width = "#{@frame.size.width}px"
      @__videoelement.style.height = "#{@frame.size.height}px"
      @__videoelement.style.position = "absolute"
      @__videoelement.style.left = "0px"
      @__videoelement.style.top = "0px"

    if (@__checkParameterKey(param, ["autoplay"]))
      @__videoelement.autoplay = @autoplay

    if (@__checkParameterKey(param, ["controls"]))
      @__videoelement.controls = @controls

    @__videoelement.loop = @loop
    @vidwidth = @__videoelement.videoWidth
    @vidheight = @__videoelement.videoHeight

    @__videoelement.style.user-select = "none"
    @__videoelement.style["-webkit-touch-callout"] = "none"
    @__videoelement.style["-webkit-user-select"] = "none"
    @__videoelement.style["-moz-user-select"] = "none"
    @__videoelement.style["-ms-user-select"] = "none"
    @__videoelement.style["-khtml-user-select"] = "none"
    @__videoelement.style["-o-user-select"] = "none"

###
---model_start---
class [classname] extends UIVideoView
  constructor:(param)->
    super(param)
    #================================
    # Please describe the initialization process below this.
    #================================



    #================================
    # don't delete
    @setObserve(@__style, @)
    #================================
---require_method---
---model_end---
###

