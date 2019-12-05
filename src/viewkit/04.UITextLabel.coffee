#============================================================================
# UITextLabel - text data display only one line
#============================================================================

class UITextLabel extends UIView
  constructor:(param)->
    super(param)

    # default parameter
    @clipToBounds = true
    @cornerRadius = 4.0

    @__style.textAlign = "UITextAlignmentLeft"
    @__style.verticalAlign = "UITextVerticalAlignmentMiddle"
    @__style.type = "UITextTypeNormal"
    @__style.editable = false
    @__style.text = ""
    @__style.margin = 0
    @__style.font =
      size: 11.0
      weight: "normal"
      color:
        red: 0
        green: 127
        blue: 255
        alpha: 1.0
      textShadow:false
      textShadowParam:
        color:
          red: 64
          green: 64
          blue: 64
          alpha: 0.5
        offset:
          x: 2
          y: 2
        width: 4
      family: "gothic"

    @__textelement = undefined
    @__parentelement = @__addelement

    @setObserve(@__style, @)

  destructor:->
    super()

  viewDidLoad:->
    super()

  viewDidAppear:->
    super()

  #=========================================================================
  # set style
  #=========================================================================
  setStyle:(key = undefined)->
    super(key)

    if (key == "editable" || !@__textelement?)
      if (!@__changeEditable())
        return

    if ((!key? || key == "editable"))
      if (@editable == true)
        @userInteractionEnabled = true
      else
        @userInteractionEnabled = false

    #=================================================
    # エレメント設定
    #=================================================
    if (@editable == true)
      if (@type == "UITextTypePassword")
        @__textelement.setAttribute("type", "password")
      else
        @__textelement.setAttribute("type", "text")

    #=======================================
    # テキスト位置（横方向）
    #=======================================
    switch (@textAlign)
      when "UITextAlignmentCenter"
        halign = "center"
      when "UITextAlignmentLeft"
        halign = "left"
      when "UITextAlignmentRight"
        halign = "right"
      else
        halign = "center"
    @__textelement.style.textAlign = halign

    #=======================================
    # テキスト位置（縦方向）
    #=======================================
    switch (@verticalAlign)
      when "UITextVerticalAlignmentMiddle"
        valign = "middle"
      when "UITextVerticalAlignmentTop"
        valign = "top"
      when "UITextVerticalAlignmentBottom"
        valign = "bottom"
      else
        valign = "middle"
    @__textelement.style.verticalAlign = valign

    #=======================================
    # フォント設定
    #=======================================
    family = @__getFontFamily()
    if (@font.textShadow)
      @__textelement.style.textShadow = CSSRGBA(FWColor(@font.textShadowParam.color.red, @font.textShadowParam.color.green, @font.textShadowParam.color.blue, @font.textShadowParam.color.alpha))+" #{@font.textShadowParam.offset.x}px #{@font.textShadowParam.offset.y}px #{@font.textShadowParam.width}px"
    else
      @__textelement.style.textShadow = "none"

    @__textelement.style.color = CSSRGBA(FWColor(@font.color.red, @font.color.green, @font.color.blue, @font.color.alpha))
    @__textelement.style.fontFamily = family
    @__textelement.style.fontSize = "#{@font.size}pt"
    @__textelement.style.fontWeight = @font.weight

    #=================================================
    # テキストエレメントに文字列を設定する
    #=================================================
    if (@editable)
      @__textelement.setAttribute("value", @text)
      @__textelement.textContent = @text
      @__textelement.setSelectionRange(-1, -1)
      select = "text"
    else
      if (@type == "UITextTypePassword")
        str = "*".repeat(@text.length)
      else
        str = @text
      @__textelement.textContent = str
      select = "none"

    @__textelement.style.userSelect = select
    @__textelement.style["-webkit-touch-callout"] = select
    @__textelement.style["-webkit-user-select"] = select
    @__textelement.style["-moz-user-select"] = select
    @__textelement.style["-ms-user-select"] = select
    @__textelement.style["-khtml-user-select"] = select
    @__textelement.style["-o-user-select"] = select

#============================================================================
# private method
#============================================================================

  #=================================================
  # テキストエレメント作成
  #=================================================
  __changeEditable:->
    if (!@editable?)
      return false

    # 閲覧モード、且つテキストエレメントが存在する場合は、編集結果を取得
    if (!@editable && @__textelement?)
      @text = @__textelement.value || @text

    # __textelementが存在する場合は削除
    if (@__textelement?)
      @__textelement.remove()

    # 編集可否によってテキストエレメントを作る
    if (@editable)
      @__textelement = document.createElement("input")
      ["input", "change"].forEach (evt) =>
        @__textelement.addEventListener evt, (e) =>
          styleUpdateBackup = @__styleUpdateFlag
          @__styleUpdateFlag = false
          @text = @__textelement.value
          @__styleUpdateFlag = styleUpdateBackup
      @__textelement.addEventListener "keypress", (e)=>
        if (e.keyCode == 13 && @editable && typeof(@submit) == 'function')
          @submit()
    else
      @__textelement = document.createElement("div")
    @__parentelement.appendChild(@__textelement)

    @__textelement.setAttribute("id", @UniqueID+"_text")
    @__textelement.style.display = "table-cell"
    @__textelement.style.zIndex = 1
    @__textelement.style.position = "absolute"
    @__textelement.style.width = "#{@frame.size.width-(@margin*2)}px"
    @__textelement.style.height = "#{@frame.size.height-(@margin*2)}px"
    @__textelement.style.lineHeight = "#{@frame.size.height}px"
    @__textelement.style.top = "0px"
    @__textelement.style.left = "#{@margin}px"
    @__textelement.style.border = "0px #ffffff solid"
    @__textelement.style.backgroundColor = CSSRGBA(FWColor(0, 0, 0, 0))

  #=========================================================================
  # set font
  #=========================================================================
  __setFont:(param) ->
    size = if (param.size?) then param.size else 12
    weight = if (param.weight?) then param.weight else "normal"
    color = if (param.color?) then param.color else {red:0,green:128,blue:255,alpha:0.8}
    shadowparam = if (param.textShadowParam?) then param.textShadowParam else {color:{red:64,green:64,blue:64,alpha:0.5},offset:{x:2,y:2},width:4}

    switch (param.family)
      when "mincho"
        family = "serif"
      when "gothic default"
        family = "sans-serif"
    @font =
      weight: weight
      size: size
      color: color
      textShadowParam: shadowparam
      family: family

  #=========================================================================
  # get font family
  #=========================================================================
  __getFontFamily:(f = undefined)->
    f = f || @font.family
    switch (f)
      when "fixed"
        family = "monospace, monospace !important"
      when "gothic"
        family = "sans-serif"
      when "mincho"
        family = "serif"
      else
        family = "Monaco"
    return family

  behavior:->
    super()

###
---model_start---
class [classname] extends UITextLabel
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
