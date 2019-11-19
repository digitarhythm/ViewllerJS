#============================================================================
# UITextView - text data display class
#============================================================================

class UITextView extends UIView
  constructor:(param)->
    super(param)
    # default parameter
    @borderColor = FWColor(255, 255, 255, 0.0)
    @borderWidth = 1.0
    @clipToBounds = true
    @backgroundColor = FWColor(255, 255, 255, 1.0)
    @scrolling = true

    # additional parameter
    @__style.lineHeight = 1.1
    @__style.textAlign = "UITextAlignmentLeft"
    @__style.verticalAlign = "UITextVerticalAlignmentTop"
    @__style.type = "UITextTypeNormal"
    @__style.editable = false
    @__style.writemode = "UITextWriteModeHorizontal"
    @__style.editormode = "normal"
    @__style.scrollbar = true
    @__style.text = ""
    @__style.theme = "iplastic"
    @__style.lang = "js"
    @__style.font =
      size: 16.0
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
      family: "fixed"
    @setObserve(@__style, @)

    # add text element
    @__frameelement = undefined
    @__textelement = undefined
    @__editordiv = undefined
    @__parentelement = @__addelement

  destructor:->
    super()

  viewDidLoad:->
    super()

  viewDidAppear:->
    super()

  bringViewToFront: ->
    super()
    @__textelement.focus()

  didWindowResize:->
    @setStyle("editable")

  #=========================================================================
  # set style
  #=========================================================================
  setStyle:(key = undefined)->
    super(key)

    if (!@__element?)
      return

    if (key == "editable" || !@__textelement?)
      @__changeEditable()

    if (!@__textelement?)
      return

    if (!key? || key == "editable")
      if (@editable)
        @userInteractionEnabled = true
      else
        @userInteractionEnabled = @scrolling

    if (key == "text" || key == "editable" || !key?)
      #------------------------------------------------------------------------
      # テキストエレメントに文字列を設定する（編集モード且つ通常編集モード）
      #------------------------------------------------------------------------
      if (@editable && @editormode == "normal")
        @__textelement.value = @text

      #------------------------------------------------------------------------
      # テキストエレメントに文字列を設定する（編集モード、またはvim編集モード）
      #------------------------------------------------------------------------
      else if (@editable && (@editormode == "vim" || @editormode == "editor"))
        @__textelement.innerHTML = "<pre><code>"+@text+"</code></pre>"

      #------------------------------------------------------------------------
      # テキストエレメントに文字列を設定する（閲覧モード）
      #------------------------------------------------------------------------
      else
        text = @text || ""
        if (@type == "UITextTypeMarkdown")
          renderer = new marked.Renderer()
          renderer.code = (code, lang) =>
            return '<pre><code class="hljs">' + hljs.highlight(@lang, code).value + '</code></pre>'
          renderer.table = (header, body) =>
            if (body)
              body = '<tbody>'+body+'</tbody>'
            return '<table border="1" style="border-collapse:collapse; border:1px #a0a0a0; solid;">'+'<thead>'+header+'</thead>'+body+'</table>'
          marked.setOptions
            gfm: true
            tables: true
            breaks: true
            sanitize: true
            smartLists: true
            smartypants: true
            langPrefix: ''
            renderer: renderer
          html = marked(text)
          @__textelement.innerHTML = html
        else
          text = escapeHTML(text)
          @__textelement.innerHTML = text.replace(/\r*\n/g, "<br>")

    if (@editable)
      @__textelement.style.user-select = "text"
      #----------------------------------------------------------------------
      # 編集モード時のエディターモード設定
      #----------------------------------------------------------------------
      if (@editormode == "vim" || @editormode == "editor")
        #--------------------------------------------------------------------
        # aceエディター
        #--------------------------------------------------------------------
        acedoc = ace.require("ace/document").Document
        doc = new acedoc(@text)
        session = ace.createEditSession(doc, "ace/mode/coffee")
        editidname = @UniqueID+"_text"
        family = @__getFontFamily("fixed")
        @__editordiv = ace.edit(editidname)
        @__editordiv.setSession(session)
        @__editordiv.$blockScrolling = Infinity
        @__editordiv.setTheme("ace/theme/#{@theme}")
        @__editordiv.setOptions
          wrap: true
          cursorStyle: "wide"
          fontSize: "#{@font.size}pt"
          fontFamily: family
          useSoftTabs: true
          tabSize: 2
          highlightSelectedWord: true
          mergeUndoDeltas: "always"

        if (@editormode == "vim")
          #------------------------------------------------------------------
          # vimキーバインドモード
          #------------------------------------------------------------------
          @__editordiv.setKeyboardHandler("ace/keyboard/vim")

        else
          #------------------------------------------------------------------
          # 通常モード or 通常キーバインドモード
          #------------------------------------------------------------------
          @__editordiv.setKeyboardHandler()

        @__editordiv.setValue(@text)
        @__editordiv.resize()

      else
        #--------------------------------------------------------------------
        # TEXTAREA
        #--------------------------------------------------------------------
        @__editordiv = undefined

      #------------------------------------------------------------------------
      # 編集モード時は常にテキストを左上に寄せる
      #------------------------------------------------------------------------
      halign = "left"
      valign = "top"

    else
      @__textelement.style.user-select = "none"
      @__textelement.style["-webkit-touch-callout"] = "none"
      @__textelement.style["-webkit-user-select"] = "none"
      @__textelement.style["-moz-user-select"] = "none"
      @__textelement.style["-ms-user-select"] = "none"
      @__textelement.style["-khtml-user-select"] = "none"
      @__textelement.style["-o-user-select"] = "none"

      #------------------------------------------------------------------------
      # テキスト位置（横方向）
      #------------------------------------------------------------------------
      switch (@textAlign)
        when "UITextAlignmentCenter"
          halign = "center"
        when "UITextAlignmentLeft"
          halign = "left"
        when "UITextAlignmentRight"
          halign = "right"
        else
          halign = "left"
      #------------------------------------------------------------------------
      # テキスト位置（縦方向）
      #------------------------------------------------------------------------
      switch (@verticalAlign)
        when "UITextVerticalAlignmentMiddle"
          valign = "middle"
        when "UITextVerticalAlignmentTop"
          valign = "top"
        when "UITextVerticalAlignmentBottom"
          valign = "bottom"
        else
          valign = "top"

    @__textelement.style.textAlign = halign
    @__textelement.style.verticalAlign = valign

    @__textelement.style.lineHeight = @lineHeight

    #------------------------------------------------------------------------
    # 縦書き／横書き
    #------------------------------------------------------------------------
    switch (@writemode)
      when "UITextWriteModeHorizontal"
        @__textelement.style.writingMode = "horizontal-tb"
      when "UITextWriteModeVertical"
        @__textelement.style.writingMode = "vertical-rl"

    #------------------------------------------------------------------------
    # border設定
    #------------------------------------------------------------------------
    @__textelement.style.border = "0px"

    #------------------------------------------------------------------------
    # テキストエレメント設定
    #------------------------------------------------------------------------
    @__adjustElement()

#============================================================================
# private method
#============================================================================

  #=========================================================================
  # change editable
  #=========================================================================
  __changeEditable:->

    if (!@editable?)
      return

    #------------------------------------------------------------------------
    # すでにテキストエレメントがあった場合は削除
    #------------------------------------------------------------------------
    @__textelement.remove() if (@__textelement?)
    @__frameelement.remove() if (@__frameelement?)

    # marginを考慮したフレームエレメントを作成
    @__frameelement = document.createElement("div")
    @__frameelement.setAttribute("id", "#{@UniqueID}_frame")
    @__parentelement.appendChild(@__frameelement)

    #--------------------------------------------------------------------------
    # テキストエレメント作成
    #--------------------------------------------------------------------------
    if (@editable && @editormode == "normal")
      #------------------------------------------------------------------------
      # 編集モード且つ通常編集モード
      #------------------------------------------------------------------------
      diff = 4
      @__textelement = document.createElement("textarea")
      ["input", "change"].forEach (evt) =>
        @__textelement.addEventListener evt, (e) =>
          @text = @__textelement.value
    else
      #------------------------------------------------------------------------
      # 閲覧モード or エディター編集モード
      #------------------------------------------------------------------------
      diff = 0
      @__textelement = document.createElement("div")
    @__textelement.setAttribute("id", @UniqueID+"_text")

    @__frameelement.appendChild(@__textelement)
    @__addelement = @__textelement

    #--------------------------------------------------------------------------
    # エレメント設定
    #--------------------------------------------------------------------------
    @__adjustElement(diff)

    #------------------------------------------------------------------------
    # テキストエレメントをDOMの最前面にする
    #------------------------------------------------------------------------
    v = $(@__viewSelector+"_text")
    v.prependTo(v.parent())

  #=========================================================================
  # エレメントのパラメーターを設定する
  #=========================================================================
  __adjustElement:(diff)->
    # marginを考慮したフレームエレメントを作成
    if (@scrollbar)
      scrollbar_size = 0
    else
      scrollbar_size = 24

    framewidth = @frame.size.width - (@margin * 2)
    frameheight = @frame.size.height - (@margin * 2)

    #-------------------------------------------------------------------------
    # マージンを考慮した枠の設定
    #-------------------------------------------------------------------------
    @__frameelement.style.position = "absolute"
    @__frameelement.style.zIndex = 1
    @__frameelement.style.overflow = "auto"
    @__frameelement.style.backgroundColor = CSSRGBA(FWColor(0, 255, 0, 0.0))

    @__frameelement.style.left = "0px"
    @__frameelement.style.top = "0px"

    #-------------------------------------------------------------------------
    # 実際のテキストエレメントの設定
    #-------------------------------------------------------------------------
    @__textelement.style.position = "relative"
    @__textelement.style.zIndex = 1
    @__textelement.style.wordBreak = "break-all"
    @__textelement.style.display = "table-cell"
    @__textelement.style.overflow = "normal"

    family = @__getFontFamily()
    @__textelement.style.fontFamily = family
    @__textelement.style.fontSize = "#{@font.size}pt"
    @__textelement.style.fontWeight = @font.weight
    if (@font.textShadow)
      @__textelement.style.textShadow = CSSRGBA(FWColor(@font.textShadowParam.color.red, @font.textShadowParam.color.green, @font.textShadowParam.color.blue, @font.textShadowParam.color.alpha))+" #{@font.textShadowParam.offset.x}px #{@font.textShadowParam.offset.y}px #{@font.textShadowParam.width}px"
    else
      @__textelement.style.textShadow = "none"

    @__textelement.style.color = CSSRGBA(FWColor(@font.color.red, @font.color.green, @font.color.blue, @font.color.alpha))
    @__textelement.style.left = "0px"
    @__textelement.style.top = "0px"
    @__textelement.style.width = "#{framewidth-diff}px"
    @__textelement.style.height = "#{frameheight-diff}px"
    @__textelement.style.backgroundColor = CSSRGBA(FWColor(0, 0, 255, 0.0))

  #=========================================================================
  # text data update
  #=========================================================================
  __dataBindUpdate:->
    if (@editable)
      nodeName = $(@__viewSelector+"_text").prop("nodeName")
      try
        if (nodeName == "TEXTAREA")
          @text = $(@__viewSelector+"_text").val()
        else if (@editormode == "vim" || @editormode == "editor")
          @text = @__editordiv.getSession().getValue() if (@__editordiv?)
        else
          @text = @__textelement.value.replace(/<br>/g, "\r\n") if (@__textelement?)

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

###
---model_start---
class [classname] extends UITextView
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

