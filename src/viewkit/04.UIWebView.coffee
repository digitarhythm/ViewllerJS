#=============================================================================
#
# UIWebView - Web IFrame view
#
#=============================================================================

class UIWebView extends UIView
  constructor:(param)->
    super(param)

    @__style.src = ""

    @__parentelement = @__addelement

    @__webelement = document.createElement("iframe")
    @__webelement.setAttribute("id", @UniqueID+"_frame")
    @__webelement.style.backgroundColor = CSSRGBA(FWColor(255, 255, 255, 0.0))
    @__webelement.style.borderColor = CSSRGBA(FWColor(255, 255, 255, 0.0))
    @__webelement.style.position = "absolute"
    @__webelement.style.overflow = "hidden"
    @__webelement.style.display = "normal"
    @__webelement.style.left = "0px"
    @__webelement.style.top = "0px"
    @__webelement.style.width = @frame.size.width+"px"
    @__webelement.style.height = @frame.size.height+"px"

    @setObserve(@__style, @)

  viewDidLoad:->
    super()

  viewDidAppear:->
    super()
    @__parentelement.appendChild(@__webelement)

  viewWillDisappear:->
    super()

  setStyle:(param)->
    super(param)

    if (@__checkParameterKey(param, ["src"]))
      @__webelement.setAttribute("src", @src) if (@__webelement?)

    @__webelement.style.display = if (@hidden) then "none" else "table-cell"
    @__webelement.style.user-select = "none"
    @__webelement.style["-webkit-touch-callout"] = "none"
    @__webelement.style["-webkit-user-select"] = "none"
    @__webelement.style["-moz-user-select"] = "none"
    @__webelement.style["-ms-user-select"] = "none"
    @__webelement.style["-khtml-user-select"] = "none"
    @__webelement.style["-o-user-select"] = "none"

###
---model_start---
class [classname] extends UIWebView
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
