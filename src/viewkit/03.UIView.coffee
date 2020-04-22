#=============================================================================
# UIView - Createview's foundation view class
#=============================================================================

class UIView extends UIWindow
  #=========================================================================
  # constructor
  #=========================================================================
  constructor: (frame) ->
    super(frame)

    # visual setting
    @clipToBounds = true

    # add view parameter
    @__style.scrollbar = false
    @__style.margin = 0.0
    @__style.scrolling = false

    #-------------------------------------------------------------------------
    # private member
    #-------------------------------------------------------------------------
    @__index = undefined

    #-------------------------------------------------------------------------
    # create base element
    #-------------------------------------------------------------------------
    basewidth = @frame.size.width - (@margin * 2)
    baseheight = @frame.size.height - (@margin * 2)

    @__scrollbase = document.createElement("div")
    @__scrollbase.setAttribute("id", "#{@UniqueID}_scrollbase")
    @__scrollbase.style.position = "absolute"
    @__scrollbase.style.backgroundColor = CSSRGBA(FWColor(0, 0, 0, 0))
    @__scrollbase.style.overflow = "hidden"

    @__scrollbase.style.user-select = "none"
    @__scrollbase.style["-webkit-touch-callout"] = "none"
    @__scrollbase.style["-webkit-user-select"] = "none"
    @__scrollbase.style["-moz-user-select"] = "none"
    @__scrollbase.style["-ms-user-select"] = "none"
    @__scrollbase.style["-khtml-user-select"] = "none"
    @__scrollbase.style["-o-user-select"] = "none"

    #-------------------------------------------------------------------------
    # create scroll element
    #-------------------------------------------------------------------------
    @__scrollelement = document.createElement("div")
    @__scrollelement.setAttribute("id", "#{@UniqueID}_scroll")
    @__scrollelement.style.position = "absolute"
    @__scrollelement.style.backgroundColor = CSSRGBA(FWColor(0, 0, 0, 0))

    @__scrollelement.style.user-select = "none"
    @__scrollelement.style["-webkit-touch-callout"] = "none"
    @__scrollelement.style["-webkit-user-select"] = "none"
    @__scrollelement.style["-moz-user-select"] = "none"
    @__scrollelement.style["-ms-user-select"] = "none"
    @__scrollelement.style["-khtml-user-select"] = "none"
    @__scrollelement.style["-o-user-select"] = "none"

    @viewelement.appendChild(@__scrollbase)
    @__scrollbase.appendChild(@__scrollelement)
    @viewelement = @__scrollelement

    @setObserve(@__style, @)
    @setStyle()

  #=========================================================================
  #=========================================================================
  #=========================================================================
  #
  # overload method
  #
  #=========================================================================
  #=========================================================================
  #=========================================================================

  #=========================================================================
  # view did load
  #=========================================================================
  viewDidLoad: ->
    super()

  #=========================================================================
  # view did appear
  #=========================================================================
  viewDidAppear: ->
    super()

  #=========================================================================
  # destructor
  #=========================================================================
  viewWillDisappear: ->
    super()

  #=========================================================================
  #=========================================================================
  #=========================================================================
  #
  # public method
  #
  #=========================================================================
  #=========================================================================
  #=========================================================================

  #=========================================================================
  # set CSS style
  #=========================================================================
  setStyle:(key)->
    super(key)

    if (!@__scrollbase? || !@__scrollelement?)
      return

    if (@scrollbar || @containment)
      diff = 0
    else
      diff = 16

    if (@scrolling)
      scroll = "auto"
    else
      scroll = "hidden"

    basewidth = @frame.size.width - (@margin * 2)
    baseheight = @frame.size.height - (@margin * 2)
    @__scrollbase.style.left = "#{@margin}px"
    @__scrollbase.style.top = "#{@margin}px"
    @__scrollbase.style.width = "#{basewidth}px"
    @__scrollbase.style.height = "#{baseheight}px"

    @__scrollelement.style.left = "0px"
    @__scrollelement.style.top = "0px"
    @__scrollelement.style.width = "#{basewidth + diff}px"
    @__scrollelement.style.height = "#{baseheight}px"
    @__scrollelement.style.overflow = scroll
    @__scrollelement.style["-webkit-overflowScrolling"] = "touch"

  #=========================================================================
  #=========================================================================
  #=========================================================================
  #
  # delegate method
  #
  #=========================================================================
  #=========================================================================
  #=========================================================================

  #=========================================================================
  # browser resize event
  #=========================================================================
  didBrowserResize:->
    super()

  #=========================================================================
  # behavior method
  #=========================================================================
  behavior:->
    super()

  #=========================================================================
  #=========================================================================
  #=========================================================================
  #
  # private method
  #
  #=========================================================================
  #=========================================================================
  #=========================================================================

  #=========================================================================
  # touch event
  #=========================================================================
  touchesBegan:(pos, e)->
    super()

  touchesMoved:(pos, e)->
    super()

  touchesEnded:(pos, e)->
    super()

  touchesCanceled:(pos, e)->
    super()

###
---model_start---
class [classname] extends UIView
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

