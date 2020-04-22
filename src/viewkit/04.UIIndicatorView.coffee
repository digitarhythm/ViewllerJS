#============================================================================
# UIIndicatorView - activity indicator view class
#============================================================================

class UIIndicatorView extends UIWindow
  constructor:(param)->
    super(param)
    #================================
    # Please describe the initialization process below this.
    #================================
    @scale = 0.2
    @backgroundColor = FWColor(0, 0, 0, 0.0)
    @hidden = true

    @__indicatorelement = document.createElement("img")
    @__indicatorelement.setAttribute("id", "#{@UniqueID}_indicator")
    @__indicatorelement.setAttribute("width", "100%")
    @__indicatorelement.setAttribute("height", "100%")
    @__indicatorelement.style.user-select = "none"
    @__indicatorelement.style["-webkit-touch-callout"] = "none"
    @__indicatorelement.style["-webkit-user-select"] = "none"
    @__indicatorelement.style["-moz-user-select"] = "none"
    @__indicatorelement.style["-ms-user-select"] = "none"
    @__indicatorelement.style["-khtml-user-select"] = "none"
    @__indicatorelement.style["-o-user-select"] = "none"

    @__style.type = "UIIndicatorTypeWhite"

    @__parentelement = @viewelement

    #================================
    @setObserve(@__style, @)

  setStyle:(param)->
    super(param)

    if (@type == "UIIndicatorTypeBlack")
      indicator_file = "#{node_pkg}/sysimages/loading_indicator_gray.gif"
    else if (@type == "UIIndicatorTypeWhite")
      indicator_file = "#{node_pkg}/sysimages/loading_indicator_white.gif"
    else
      indicator_file = "#{node_pkg}/sysimages/loading_indicator_white.gif"

    indicator = new Image()
    indicator.src = indicator_file
    indicator.onload = =>
      $("#"+@UniqueID+"_indicator").attr("src", indicator_file)

  viewDidLoad:->
    super()
    wtmp = Math.floor(@frame.size.width * @scale)
    htmp = Math.floor(@frame.size.height * @scale)
    if (wtmp > htmp)
      width = htmp
      height = htmp
    else
      width = wtmp
      height = wtmp
    x = Math.floor((@frame.size.width - width) / 2)
    y = Math.floor((@frame.size.height - height) / 2)

    @frame.origin.x += x
    @frame.origin.y += y
    @frame.size.width = width
    @frame.size.height = height

  viewDidAppear:->
    super()
    @__parentelement.appendChild(@__indicatorelement)

  viewWillDisappear:->
    super()

  start:->
    @hidden = false

  stop:->
    @hidden = true

  #didBrowserResize:(bounds)->
  #   super()

  #hehavior:->
  #   super()

  #touchesBegan:(pos, e)->
  #   super()

  #touchesMoved:(pos, e)->
  #   super()

  #touchesEnded:(pos, e)->
  #   super()

  #touchesCanceled:(pos, e)->
  #   super()

