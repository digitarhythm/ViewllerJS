#=============================================================================
# UISlidebarView - slidebar
#=============================================================================

class UISlidebarView extends UIView
  #=========================================================================
  # constructor
  #=========================================================================
  constructor: (param) ->
    super(param)
    @backgroundColor.alpha = 0.0
    @borderWidth = 0.5
    @borderColor = FWColor(0, 0, 0, 0.1)
    @clipToBounds = true

    @func = undefined

    @__slider_width = 8
    @__slider_height = 24
    @__drag = false
    @__slider = undefined
    @__gauge = undefined
    @__margin = 64
    @__parentelement = @viewelement

    @__style.sliderColor = FWColor(0, 127, 255, 0.8)
    @__style.value = 0
    @__style.min = 0
    @__style.max = 255
    #=====================================
    @setObserve(@__style, @)

  #========================================================================
  # set addtional parameter value
  #========================================================================
  setStyle:(key)->
    super(key)

    if (@__slider?)
      @__slider.style.backgroundColor = CSSRGBA(@sliderColor)

    if (@value? && @max? && @__length?)
      x = @value / @max * @__length + @frame.origin.x
      if (x? && @value?)
        if (Math.round(@__margin/2) <= x && x <= (@__gauge_width + @__gauge_x - @__slider_width))
          @__slider.style.left = x+"px"

  #========================================================================
  #========================================================================
  viewDidLoad:->
    super()
    @__gauge_x = (Math.round(@__margin/2))
    @__gauge_width = (@frame.size.width-@__margin)
    @__length = @__gauge_width - @__slider_width

    @__gauge = document.createElement("div")
    @__gauge.setAttribute("id", "#{@UniqueID}_gauge")
    @__gauge.style.position = "absolute"
    @__gauge.style.width = (@__gauge_width-4)+"px"
    @__gauge.style.height = "4px"
    @__gauge.style.left = @__gauge_x+"px"
    @__gauge.style.top = (Math.round(@frame.size.height / 2) - 4)+"px"
    @__gauge.style.backgroundColor = CSSRGBA(FWColor(200, 200, 200, 0.8))
    @__gauge.style.border = "1px #f0f0f0 inset"
    @__gauge.style.user-select = "none"
    @__gauge.style["-webkit-touch-callout"] = "none"
    @__gauge.style["-webkit-user-select"] = "none"
    @__gauge.style["-moz-user-select"] = "none"
    @__gauge.style["-ms-user-select"] = "none"
    @__gauge.style["-khtml-user-select"] = "none"
    @__gauge.style["-o-user-select"] = "none"

    @__parentelement.appendChild(@__gauge)

    @__slider = document.createElement("div")
    @__slider.setAttribute("id", "#{@UniqueID}_slider")
    @__slider.style.position = "absolute"
    @__slider.style.width = @__slider_width+"px"
    @__slider.style.height = @__slider_height+"px"
    @__slider.style.top = "#{Math.floor((@frame.size.height - @__slider_height) / 2)}px"
    x = Math.round(@value / @max * @__length + Math.round(@__margin/2))
    @__slider.style.left = x+"px"
    @__slider.style.backgroundColor = CSSRGBA(@sliderColor)
    @__slider.style.user-select = "none"
    @__slider.style["-webkit-touch-callout"] = "none"
    @__slider.style["-webkit-user-select"] = "none"
    @__slider.style["-moz-user-select"] = "none"
    @__slider.style["-ms-user-select"] = "none"
    @__slider.style["-khtml-user-select"] = "none"
    @__slider.style["-o-user-select"] = "none"

    @__parentelement.appendChild(@__slider)

    @viewelement.addEventListener 'mouseleave', (event) =>
      @__drag = false

  #========================================================================
  #========================================================================
  viewDidAppear:->
    super()

  #========================================================================
  #========================================================================
  touchesBegan:(pos, e)->
    super()
    ret = @__getAbsolutePosition
      obj: @self
    @frame.origin.pageX = ret.x
    @frame.origin.pageY = ret.y

    if (e.button == 0)
      @__clickGauge(pos)
      @__drag = true
    else
      @__drag = false

  #========================================================================
  #========================================================================
  touchesMoved:(pos, e)->
    super()
    if (@__drag)
      @__clickGauge(pos)


  #========================================================================
  #========================================================================
  __clickGauge:(pos)->
    x = pos.pageX - @frame.origin.pageX - Math.round(@__slider_width/2)
    if (Math.round(@__margin/2) <= x && x < (@__gauge_width + @__gauge_x - @__slider_width))
      @__slider.style.left = x+"px"

      # パラメーターの変更検知に反応しないようにする
      backupStyleFlag = @__styleUpdateFlag
      @__styleUpdateFlag = false
      @value = Math.ceil((x-Math.round(@__margin/2))/@__length*100)/100*@max
      @__styleUpdateFlag = backupStyleFlag

      @func(@value) if (@func?)

  #========================================================================
  #========================================================================
  touchesEnded:(pos, e)->
    super()
    if (@__drag)
      @__clickGauge(pos)

    @__drag = false

  #========================================================================
  #========================================================================
  touchesCanceled:(pos, e)->
    super()
    @__drag = false

###
---model_start---
class [classname] extends UISlidebarView
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
