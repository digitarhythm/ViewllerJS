#=============================================================================
# UIButton - Button library
#=============================================================================

class UIButton extends UIView
  constructor:(param)->
    super(param)

    # set style parameter
    @cornerRadius = 8.0
    @clipToBounds = true
    @backgroundColor = FWColor(0, 0, 0, 0.0)
    @borderWidth = 1.0
    @borderColor = FWColor(100, 100, 100, 1.0)
    @destinationDir = ""
    @setShadow true,
      x: 1
      y: 1
      width: 2
      color: FWColor(0, 0, 0, 0.5)
    size = parseInt(@frame.size.height * 0.4)

    # addtional parameter
    @__style.title = "Button"
    @__style.textAlign = "UITextAlignCenter"
    @__style.type = "UIButtonTypeNormal"
    @__style.buttonColor = FWColor(32, 32, 32, 1.0)
    @__style.highlight = FWColor(64, 64, 64, 0.8)
    @__style.tintColor = FWColor(120, 120, 120, 0.8)
    @__style.tintFontColor = FWColor(255, 255, 255, 0.8)
    @__style.font =
      size: @frame.size.height / 3.2
      weight: "normal"
      color:
        red: 255
        green: 255
        blue: 255
        alpha: 1.0
      textShadow: false
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

    # private value
    @__org_x = @frame.origin.x
    @__org_y = @frame.origin.y
    @__enterflag = false
    @__clickflag = false
    @__parentelement = @__addelement
    @__textshadowparam = undefined

    @__buttonelement = document.createElement("div")
    @__buttonelement.setAttribute("id", @UniqueID+"_button")
    @__buttonelement.style.display = "inline-block"
    @__buttonelement.style.position = "absolute"
    @__buttonelement.style.overflow = "hidden"
    @__buttonelement.style.fontWeight = "bold"
    @__buttonelement.style.user-select = "none"
    @__buttonelement.style["-webkit-touch-callout"] = "none"
    @__buttonelement.style["-webkit-user-select"] = "none"
    @__buttonelement.style["-moz-user-select"] = "none"
    @__buttonelement.style["-ms-user-select"] = "none"
    @__buttonelement.style["-khtml-user-select"] = "none"
    @__buttonelement.style["-o-user-select"] = "none"

    @__parentelement.appendChild(@__buttonelement)

    @__buttonelement.addEventListener 'mouseenter', (event) =>
      if (@userInteractionEnabled)
        @__enterflag = true
        @__buttonelement.style.backgroundColor = CSSRGBA(@highlight)

    @__buttonelement.addEventListener 'mouseleave', (event) =>
      if (@userInteractionEnabled)
        @__enterflag = false
        @__buttonelement.style.backgroundColor = CSSRGBA(@buttonColor)

    # instance value
    @func = undefined

    @setObserve(@__style, @)

  #===========================================================================
  #===========================================================================
  #===========================================================================
  #
  # private method
  #
  #===========================================================================
  #===========================================================================
  #===========================================================================

  #===========================================================================
  # set addtional parameter value
  #===========================================================================
  setStyle:(key=undefined)->
    super(key)

    if (!@__buttonelement)
      return

    #-------------------------------------------------------------------------
    # title font
    #-------------------------------------------------------------------------
    @__buttonelement.style.fontSize = "#{@font.size}pt"
    if (@userInteractionEnabled)
      @__buttonelement.style.color = CSSRGBA(@font.color)
      if (@__clickflag)
        @__buttonelement.style.backgroundColor = CSSRGBA(@tintColor)
        @__buttonelement.style.color = CSSRGBA(@tintFontColor)
      else
        if (@__enterflag)
          @__buttonelement.style.backgroundColor = CSSRGBA(@highlight)
        else
          @__buttonelement.style.backgroundColor = CSSRGBA(@buttonColor)
    else
        @__buttonelement.style.color = CSSRGBA(FWColor(128, 128, 128, 0.3))

    #-------------------------------------------------------------------------
    # button style
    #-------------------------------------------------------------------------
    @__buttonelement.style.borderRadius = @cornerRadius
    @__buttonelement.style.lineHeight = "#{@frame.size.height}px"
    @__buttonelement.style.left = "0px"
    @__buttonelement.style.top = "0px"
    @__buttonelement.style.width = @frame.size.width+"px"
    @__buttonelement.style.height = @frame.size.height+"px"

    if (@font.textShadow)
      @__textshadowparam = CSSRGBA(FWColor(@font.textShadowParam.color.red, @font.textShadowParam.color.green, @font.textShadowParam.color.blue, @font.textShadowParam.color.alpha))+" #{@font.textShadowParam.offset.x}px #{@font.textShadowParam.offset.y}px #{@font.textShadowParam.width}px"
    else
      @__textshadowparam = "none"
    @__buttonelement.style.textShadow = @__textshadowparam

    #-------------------------------------------------------------------------
    # text alignment
    #-------------------------------------------------------------------------
    switch (@type)
      when "UIButtonTypeNormal"
        switch (@textAlign)
          when "UITextAlignmentCenter"
            align = "center"
          when "UITextAlignmentLeft"
            align = "left"
          when "UITextAlignmentRight"
            align = "right"
          else
            align = "center"

      when "UIButtonTypeUpload"
        align = "center"
    @__buttonelement.style.textAlign = align

    #-------------------------------------------------------------------------
    # button type
    #-------------------------------------------------------------------------
    if (key == "type" || !key?)
      switch (@type)
        #---------------------------------------------------------------------
        # normal button
        #---------------------------------------------------------------------
        when "UIButtonTypeNormal"
          @__buttonelement.innerHTML = "<div id='#{@UniqueID}_title'><div>"

        #---------------------------------------------------------------------
        # file upload button
        #---------------------------------------------------------------------
        when "UIButtonTypeUpload"
          @__buttonelement.innerHTML = """
            <form id='#{@UniqueID}_upload_form' enctype='multipart/form-data' method='post'>
              <input type='file' name='upload_file' id='#{@UniqueID}_file' style='display:none;' multiple='multiple'>
              <div id='#{@UniqueID}_title'><div>
            </form>
          """
          fd = new FormData($("#{@__viewSelector}_upload_form")[0])
          $("#{@__viewSelector}_file").change =>
            @__buttonelement.style.boxShadow = "2px 2px 4px rgba(64, 64, 64, 0.6)"
            fd = new FormData($("#{@__viewSelector}_upload_form")[0])
            $.ajaxSetup
              type: "POST"
              dataType: 'json'
              timeout : 30000
              headers:
                'pragma'           : 'no-cache'
                'Cache-Control'    : 'no-cache'
                'If-Modified-Since': 'Thu, 01 Jun 1970 00:00:00 GMT'
            $.ajax
              url: "#{ORIGIN}/api/file_upload"
              data: fd
              processData: false
              contentType: false
              headers: {
                dir: @destinationDir
              }
            .done (ret, status, xhr) =>
              @func(ret) if (@func?)
            .fail (jqXHR, textStatus, errorThrown)=>
              if (@func?)
                @func
                  err: -1
                  message: textStatus

    if (@title != "")
      switch (@type)
        when "UIButtonTypeNormal"
          buttonstr = @title || "Button"
        when "UIButtonTypeUpload"
          buttonstr = @title || "⬆"
    else
      buttonstr = ""
    $("#{@__viewSelector}_title").html(buttonstr)

  #===========================================================================
  #===========================================================================
  #===========================================================================
  #
  # public method
  #
  #===========================================================================
  #===========================================================================
  #===========================================================================

  addTarget:(@func)->

  #===========================================================================
  #===========================================================================
  #===========================================================================
  #
  # overload method
  #
  #===========================================================================
  #===========================================================================
  #===========================================================================

  viewDidLoad:->
    super()

  viewDidAppear:->
    super()

  touchesBegan:(pos, e)->
    super()
    @__clickflag = true
    @shadow = false
    @__element.style.transform = "translateY(1px)"

  touchesMoved:(pos, e)->
    super()

  touchesEnded:(pos, e)->
    super()
    if (@type == "UIButtonTypeUpload")
      $("#{@__viewSelector}_file").click()
    else
      if (@func?)
        @func(pos, @self)

    @__clickflag = false
    @shadow = true
    @__element.style.transform = "translateY(0px)"

  touchesCanceled:(pos, e)->
    super()
    @__clickflag = false
    @shadow = true
    @__element.style.transform = "translateY(0px)"

###
---model_start---
class [classname] extends UIButton
  constructor:(param)->
    super(param)
    #================================
    # Please describe the initialization process below this.
    #================================



    #================================
    @setObserve(@__style, @)
---require_method---
---model_end---
###
