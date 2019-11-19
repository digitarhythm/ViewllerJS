#============================================================================
# UIImageView - image handling class
#============================================================================

class UIImageView extends UIView
  constructor:(param)->
    super(param)

    # values
    @imgframe = undefined
    @imgobject = undefined
    @func = undefined
    @image = undefined
    #@imgid = "#"+@UniqueID+"_image"
    @contentModeList = [
      "UIImageScaleToFill"
      "UIImageScaleAspectFit"
      "UIImageScaleAspectFill"
      "UIImageTop"
      "UIImageCenter"
      "UIImageBottom"
      "UIImageLeft"
      "UIImageRight"
      "UIImageTopLeft"
      "UIImageTopRight"
      "UIImageBottomLeft"
      "UIImageBottomRight"
    ]

    # set style
    @borderwidth = 1.0
    @borderColor = FWColor(0, 128, 255, 0.0)
    @backgroundColor.alpha = 0.0
    @clipToBounds = true

    # additional style parameter
    @__style.image = undefined
    @__style.offsetX = 0.0
    @__style.offsetY = 0.0
    @__style.contentMode = "UIImageScaleAspectFit"

    # add private element
    @__imageelement = document.createElement("canvas")
    @__imageelement.setAttribute("id", "#{@UniqueID}_image")
    @__parentelement = @__addelement
    @__orignSize = undefined

    @setObserve(@__style, @)

  destructor:->
    super()

  viewDidLoad:->
    super()
    @setImage(@image)

  viewDidAppear:->
    super()
    @__parentelement.appendChild(@__imageelement)

  didBrowserResize:->
    super()

  #==========================================================================
  # image load
  #==========================================================================
  setImage:(src = undefined, func = undefined)->
    if (func?)
      @func = func

    @image = src
    if (!@__imageelement?)
      return

    if (@image?)
      @imgobject = new Image() if (!@imgobject?)

      if (@image != "")
        prefix = @image.match(/^(http|https):.*$/)
        if (!prefix? || prefix.length < 2)
          src2 = "#{node_pkg}/#{@image}"
        else
          src2 = @image
        @imgobject.src = src2

      @imgobject.onload = =>
        @__originSize = FWRectMake(0, 0, @imgobject.width, @imgobject.height)
        @__imageResize()
        @__createImage()
        $(@__viewSelector+"_image").css("display", "block")
        if (@func?)
          @func(@)
          @func = undefined
    else

      @imgobject.src = "" if (@imgobject?)
      $(@__viewSelector+"_image").css("display", "none")
      if (@func?)
        @func(@)
        @func = undefined

    @__imageelement.style.user-select = "none"
    @__imageelement.style["-webkit-touch-callout"] = "none"
    @__imageelement.style["-webkit-user-select"] = "none"
    @__imageelement.style["-moz-user-select"] = "none"
    @__imageelement.style["-ms-user-select"] = "none"
    @__imageelement.style["-khtml-user-select"] = "none"
    @__imageelement.style["-o-user-select"] = "none"

  setStyle:(key)->
    super(key)

    #-------------------------------------------------------------------------
    # image
    #-------------------------------------------------------------------------
    @setImage(@image)

  #==========================================================================
  # bitmap data copy to canvas from image object
  #==========================================================================
  __createImage:->
    ctx = @__imageelement.getContext('2d')
    ctx.drawImage(@imgobject, @imgframe.origin.x, @imgframe.origin.y, @imgframe.size.width, @imgframe.size.height)


  #==========================================================================
  # contentModeによって画像サイズ、位置を設定する
  #==========================================================================
  __imageResize:->
    if (!@imgobject?)
      return

    switch (@contentMode)
      when "UIImageScaleToFill"
        @imgframe = @__UIImageScaleToFill()
      when "UIImageScaleAspectFit"
        @imgframe = @__UIImageScaleAspectFit()
      when "UIImageScaleAspectFill"
        @imgframe = @__UIImageScaleAspectFill()
      when "UIImageTop"
        @imgframe = @__UIImageTop()
      when "UIImageCenter"
        @imgframe = @__UIImageCenter()
      when "UIImageBottom"
        @imgframe = @__UIImageBottom()
      when "UIImageLeft"
        @imgframe = @__UIImageLeft()
      when "UIImageRight"
        @imgframe = @__UIImageRight()
      when "UIImageTopLeft"
        @imgframe = @__UIImageTopLeft()
      when "UIImageTopRight"
        @imgframe = @__UIImageTopRight()
      when "UIImageBottomLeft"
        @imgframe = @__UIImageBottomLeft()
      when "UIImageBottomRight"
        @imgframe = @__UIImageBottomRight()
      else
        @imgframe = @__UIImageScaleAspectFit()

    if (@__imageelement? && @imgframe)
      @__imageelement.style.position = "absolute"
      @__imageelement.style.width = "#{@frame.size.width}px"
      @__imageelement.style.height = "#{@frame.size.height}px"
      @__imageelement.style.left = "0px"
      @__imageelement.style.top = "0px"

      style = @__imageelement.ownerDocument.defaultView.getComputedStyle(@__imageelement, "")
      @__imageelement.width  = Math.round(parseFloat(style.width ))
      @__imageelement.height = Math.round(parseFloat(style.height))

  #==========================================================================
  # モードを渡すと縦、横のうち優先される値を元にして求めたRectリストを返す
  #==========================================================================
  __getImageAspectLength:(mode)->
    if (!@imgobject?)
      return

    orgwidth = @imgobject.width
    orgheight = @imgobject.height
    aspect = orgwidth / orgheight

    frmwidth = @frame.size.width - (@margin * 2)
    frmheight = @frame.size.height - (@margin * 2)

    switch mode
      when 0 # 幅優先
        imgwidth = parseFloat(frmwidth)
        imgheight = parseFloat(frmwidth / aspect)
      when 1 # 縦優先
        imgwidth = parseFloat(frmheight * aspect)
        imgheight = parseFloat(frmheight)

    imgx = Math.floor((frmwidth - imgwidth) / 2.0) + @offsetX
    imgy = Math.floor((frmheight - imgheight) / 2.0) + @offsetY

    return FWRectMake(imgx, imgy, imgwidth, imgheight)

  #==========================================================================
  # アスペクト比を変えてview全体に表示
  #==========================================================================
  __UIImageScaleToFill:->
    return FWRectMake(0, 0, @frame.size.width - (@margin * 2), @frame.size.height - (@margin * 2))

  #==========================================================================
  # アスペクト比を変えずに画像全体が表示されるように
  # 拡大／縮小（画像全体が表示される）
  #==========================================================================
  __UIImageScaleAspectFit:->
    if (!@imgobject?)
      return

    imgwidth = @imgobject.width
    imgheight = @imgobject.height
    aspect = imgwidth / imgheight

    if (aspect <= 1.0) # 縦長画像
      frmwidth = (@frame.size.height - (@margin * 2)) * aspect
      frmheight = @frame.size.height - (@margin * 2)
      if (frmwidth < (@frame.size.width - (@margin * 2)))
        mode = 1 # 縦優先　
      else
        mode = 0 # 幅優先
    else # 横長画像
      frmwidth = @frame.size.width - (@margin * 2)
      frmheight = (@frame.size.width - (@margin * 2)) / aspect
      if (frmheight < (@frame.size.height - (@margin * 2)))
        mode = 0 # 幅優先
      else
        mode = 1 # 縦優先

    imgframe = @__getImageAspectLength(mode)
    return imgframe

  #==========================================================================
  # アスペクト比を変えずにview全体に表示されるように拡大／縮小
  # （画像全体が表示されない）
  #==========================================================================
  __UIImageScaleAspectFill:->
    if (!@imgobject?)
      return

    width = @imgobject.width
    height = @imgobject.height
    aspect = width / height

    if (aspect <= 1.0) # 縦長画像
      tmpwidth = @frame.size.width
      tmpheight = @frame.size.width / aspect
      if (tmpheight < @frame.size.height)
        mode = 1 # 縦優先　
      else
        mode = 0 # 幅優先
    else # 横長画像
      tmpwidth = @frame.size.height * aspect
      tmpheight = @frame.size.height
      if (tmpwidth < @frame.size.width)
        mode = 0 # 幅優先
      else
        mode = 1 # 縦優先

    imgframe = @__getImageAspectLength(mode)
    x = Math.floor((@frame.size.width - imgframe.size.width) / 2)
    y = Math.floor((@frame.size.height - imgframe.size.height) / 2)
    imgframe.origin.x = x
    imgframe.origin.y = y
    return imgframe

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの上部に揃えて表示
  #==========================================================================
  __UIImageTop:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    x = Math.floor((@frame.size.width - width) / 2)

    return FWRectMake(x, 0, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの中央に表示
  #==========================================================================
  __UIImageCenter:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    x = Math.floor((@frame.size.width - width) / 2)
    y = Math.floor((@frame.size.height - height) / 2)

    return FWRectMake(x, y, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの下部に揃えて表示
  #==========================================================================
  __UIImageBottom:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    x = Math.floor((@frame.size.width - width) / 2)
    y = Math.floor(@frame.size.height - height)

    return FWRectMake(x, y, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの左側に揃えて表示
  #==========================================================================
  __UIImageLeft:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    y = Math.floor((@frame.size.height - height) / 2)

    return FWRectMake(0, y, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの右側に揃えて表示
  #==========================================================================
  __UIImageRight:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    x = Math.floor(@frame.size.width - width)
    y = Math.floor((@frame.size.height - height) / 2)

    return FWRectMake(x, y, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの左上に揃えて表示
  #==========================================================================
  __UIImageTopLeft:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    return FWRectMake(0, 0, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの右上にそろえて表示
  #==========================================================================
  __UIImageTopRight:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    x = Math.floor(@frame.size.width - width)

    return FWRectMake(x, 0, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの左下に揃えて表示
  #==========================================================================
  __UIImageBottomLeft:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    y = Math.floor(@frame.size.height - height)

    return FWRectMake(0, y, width, height)

  #==========================================================================
  # 画像サイズ、アスペクト比を変えずにviewの右下に揃えて表示
  #==========================================================================
  __UIImageBottomRight:->
    if (!@imgobject? || !@__originSize)
      return

    width = @__originSize.size.width
    height = @__originSize.size.height

    x = Math.floor(@frame.size.width - width)
    y = Math.floor(@frame.size.height - height)

    return FWRectMake(x, y, width, height)

  #==========================================================================
  # リサイズ
  #==========================================================================
  didBowserResize:(bouds)->
    @__imageResize()

###
---model_start---
class [classname] extends UIImageView
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
