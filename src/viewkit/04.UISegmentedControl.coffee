#=============================================================================
# UISegmentedControl - segment select view class
#=============================================================================

class UISegmentedControl extends UIView
  constructor:(param)->
    super(param)

    @cornerRadius = 8.0
    @borderWidth = 1.0
    @borderColor = FWColor(0, 0, 0, 0.4)
    @backgroundColor = FWColor(0, 0, 0, 0)
    @shadow = true
    @delegate = @self
    @selected = undefined
    @withIdentifier = @UniqueID

    @__style.controls = []
    @__style.normalColor = FWColor(255, 255, 255, 1.0)
    @__style.highlight = FWColor(0, 127, 255, 1.0)
    @__style.tintColor = FWColor(127, 255, 127, 1.0)
    @__style.tintFontColor = FWColor(0, 127, 255, 1.0)
    @__style.font =
      size: 12
      weight: "normal"
      color: FWColor(0, 127, 255, 1.0)

    @__segmentelements = []

    #================================
    # don't delete
    @setObserve(@__style, @)
    #================================

 #==================================
  #==================================
  viewDidLoad:->
    super()

  #==================================
  #==================================
  viewDidAppear:->
    super()

  #==================================
  #==================================
  viewWillDisappear:->
    super()
    for e in @__segmentelements
      e.remove()
    @__segmentelements = []

  #==================================
  #==================================
  setStyle:(key=undefined)->
    super(key)

    if (!@controls?)
      return

    for elm in @__segmentelements
      elm.remove()
    @__segmentelements = []

    segwidth = (@frame.size.width + 4) / @controls.length
    segheight = @frame.size.height
    left = -2
    top = -1
    for title, idx in @controls
      elm = document.createElement("div")
      @__segmentelements.push(elm)
      elm.index = idx
      elm.setAttribute("id", @UniqueID+"_segment_"+idx)
      elm.style.position = "absolute"
      elm.style.left = left+"px"
      elm.style.top = top+"px"
      elm.style.border = "1px #909090 solid"
      elm.style.border = "1px #f0f0f0 inset"
      elm.style.width = segwidth+"px"
      elm.style.height = segheight+"px"
      elm.style.overflow = "hidden"
      elm.style.textAlign = "center"
      elm.style.lineHeight = segheight+"px"
      elm.style["-webkit-touch-callout"] = "none"
      elm.style["-webkit-user-select"] = "none"
      elm.style["-moz-user-select"] = "none"
      elm.style["-ms-user-select"] = "none"
      elm.style["-khtml-user-select"] = "none"
      elm.style["-o-user-select"] = "none"

      elm.style.size = @font.size+"pt"
      elm.style.fontWeight = @font.weight
      if (@selected == idx)
        elm.style.backgroundColor = CSSRGBA(@tintColor)
        elm.style.color = CSSRGBA(@tintFontColor)
        elm.style.fontWeight = 'bold'
      else
        elm.style.backgroundColor = CSSRGBA(@normalColor)
        elm.style.color = CSSRGBA(@font.color)
        elm.style.fontWeight = 'normal'

      elm.addEventListener 'mouseenter', (event) =>
        if (@userInteractionEnabled)
          self = event.target
          self.style.backgroundColor = CSSRGBA(@highlight)
          self.style.color = CSSRGBA(@tintFontColor.color)

      elm.addEventListener 'mouseleave', (event) =>
        if (@userInteractionEnabled)
          self = event.target
          if (@selected == self.index)
            self.style.backgroundColor = CSSRGBA(@tintColor)
            self.style.color = CSSRGBA(@tintFontColor)
          else
            self.style.backgroundColor = CSSRGBA(@normalColor)
            self.style.color = CSSRGBA(@font.color)

      elm.addEventListener 'click', (event) =>
        if (@userInteractionEnabled)
          if (@selected?)
            elm2 = @__segmentelements[@selected]
            elm2.style.backgroundColor = CSSRGBA(@normalColor)
            elm2.style.color = CSSRGBA(@font.color)
            elm2.style.fontWeight = 'normal'
          self = event.target
          @selected = self.index
          self.style.backgroundColor = CSSRGBA(@tintColor)
          self.style.color = CSSRGBA(@tintFontColor)
          self.style.fontWeight = 'bold'
          @delegate.didSelectRowAtIndexPath(self.index, @withIdentifier) if (typeof(@delegate.didSelectRowAtIndexPath) == 'function')

      elm.textContent = @controls[idx]
      @viewelement.appendChild(elm)
      left += segwidth

###
---model_start---
class [classname] extends UISegmentedControl
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
  #didSelectRowAtIndexPath:(index, id=undefined)->
  #  super()
---model_end---
###
