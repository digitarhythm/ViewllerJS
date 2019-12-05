#=============================================================================
# UIWinodw - Createview's foundation window class
#=============================================================================

class UIWindow extends FWObject
  #===========================================================================
  # constructor
  #===========================================================================
  constructor: (frame) ->
    super()
    if (!frame?)
      frame = FWRectMake(
        8
        8
        320
        240
      )

    # view property
    @parent = undefined

    # private values
    @__element = undefined
    @__baseelement = undefined
    @__addelement = undefined
    @__styleUpdateFlag = false
    @__viewSelector = "#"+@UniqueID
    @__childobj = {}
    @__touched = false
    @__tapaction = undefined
    @__tapaction2 = undefined
    @__dblclickflag = false
    @__pageorigin =
      x: frame.origin.x
      y: frame.origin.y

    # style values
    # ここに登録してあるパラーメータはメンバー変数として登録されます。
    # このオブジェクト内の値は、「defineProperty」で変更を検知し、変更
    # を検知した場合「@setStyle()」が呼ばれ、見映えに反映されます。
    # 「UIWindow」を継承したクラスで見映えに影響する変数はこのオブジェクト
    # に追加し、「setStyle()」メソッドをオーバーライドし、追加し
    # たメソッドが変更された場合の、見映えへの反映コードを記述します。
    @__style =
      shadow: false
      resizable: false
      draggable: false
      hidden: false
      frame: frame
      alpha: 1.0
      cornerRadius: 0.0
      borderWidth: 1.0
      containment: false
      clipToBounds: false
      userInteractionEnabled: true
      backgroundColor:
        red: 250
        green: 250
        blue: 250
        alpha: 1.0
      borderColor:
        red: 200
        green: 200
        blue: 200
        alpha: 1.0
      shadowParam:
        x: 2
        y: 2
        width: 8
        color:
          red: 0
          green: 0
          blue: 0
          alpha: 0.6

    @setObserve = @__setObserveStyle()
    @setObserve(@__style, @)
    @__createElement()

    ret = @__getAbsolutePosition
      obj: @self
      x: frame.origin.x
      y: frame.origin.y
    @frame.origin.pageX = ret.x
    @frame.origin.pageY = ret.y

  #===========================================================================
  # check style value observation
  #===========================================================================
  __setObserveStyle: =>

    setDescriptor = (stylelist, obj, key=undefined) =>
      for param, val of stylelist
        key2 = key
        key = key || param
        try
          ret = Object.defineProperty(obj, param, descriptor(key, stylelist[param], obj))
          if (typeof(val) == 'object')
            obj[param] = {}
            setDescriptor(val, obj[param], key)
          else
            obj[param] = val
        key = key2

      $(obj).on 'propertychange', (e, obj, key, v) =>
        if (@__styleUpdateFlag && typeof(@setStyle) == 'function')
          setTimeout =>
            styleUpdateBackup = @__styleUpdateFlag
            @__styleUpdateFlag = false
            @setStyle(key)
            @__styleUpdateFlag = styleUpdateBackup
          , 0

    descriptor = (key, value0, obj) =>
      value = value0
      return
        get: =>
          if (@__styleUpdateFlag && typeof(@__dataBindUpdate) == 'function')
            styleUpdateBackup = @__styleUpdateFlag
            @__styleUpdateFlag = false
            @__dataBindUpdate()
            @__styleUpdateFlag = styleUpdateBackup
          return value
        set: (v) =>
          value = v
          if (typeof(v) == 'object' && !Array.isArray(v))
            @setObserve(v, obj[key], key)
          $(obj).trigger 'propertychange', [obj, key, v]
          return
        enumerable: true
        configurable: false

    return (stylelist, obj) =>
      if (!stylelist?)
        return
      obj = stylelist if (!obj?)
      setDescriptor(stylelist, obj)
      return


  #===========================================================================
  #===========================================================================
  #===========================================================================
  #
  # overload method
  #
  #===========================================================================
  #===========================================================================
  #===========================================================================

  #===========================================================================
  # destructor
  #===========================================================================
  viewWillDisappear: ->

  #===========================================================================
  # view did load
  #===========================================================================
  viewDidLoad: ->
    @setStyle()

  #===========================================================================
  # view did appear
  #===========================================================================
  viewDidAppear: ->
    for key, obj of @__childobj
      if (!obj.__element?)
        obj.__element.style.visibility = "hidden"
        addelement = @__addelement || @__element
        addelement.appendChild(obj.__element)
        obj.viewDidLoad()
        obj.viewDidAppear()
        obj.setStyle()
        obj.__setTouches()
        obj.__bindGesture()
        setTimeout =>
          obj.__element.style.visibility = "visible"
        , 0

  #===========================================================================
  #===========================================================================
  #===========================================================================
  #
  # public method
  #
  #===========================================================================
  #===========================================================================
  #===========================================================================

  #===========================================================================
  # set CSS style
  #===========================================================================
  setStyle:(key=undefined)->
    if (!@__element?)
      return

    @__setBackgroundColor()
    @__setDraggable()
    @__setResizable()
    @__setBorder()
    @__setAlpha()
    @__setFrame(@frame)
    @__setCornerRadius()
    @setShadow(@shadow, @shadowParam)
    @__setHidden()
    @__bindGesture()

    #-------------------------------------------------------------------------
    # cursor kind
    #-------------------------------------------------------------------------
    if (@draggable || @__tapaction? || @__tapaction2?)
      @__element.style.cursor = "pointer"
    else
      @__element.style.cursor = "auto"

    @__element.style.pointerEvents = if (@userInteractionEnabled) then "auto" else "none"

    ret = @__getAbsolutePosition
      obj: @self
      x: @frame.origin.x
      y: @frame.origin.y
    @frame.origin.pageX = ret.x
    @frame.origin.pageY = ret.y

  #===========================================================================
  # set CSS
  #===========================================================================
  setCSS:(name)->

  #===========================================================================
  # setShadow
  #===========================================================================
  setShadow: (@shadow, shadowParam = undefined)->
    if (@shadow)
      if (shadowParam?)
        x = if (shadowParam.x?) then shadowParam.x else @shadowParam.x
        y = if (shadowParam.y?) then shadowParam.y else @shadowParam.y
        width = if (shadowParam.width?) then shadowParam.width else @shadowParam.width

        if (shadowParam.color?)
          color = if (shadowParam.color?) then shadowParam.color else @shadowParam.color
        else
          color = @shadowParam.color

      else
        x = @shadowParam.x
        y = @shadowParam.y
        width = @shadowParam.width
        color = @shadowParam.color

      @shadowParam.x = x
      @shadowParam.y = y
      @shadowParam.width = width
      @shadowParam.color = color

      shadowstyle = "#{x}px #{y}px #{width}px rgba(#{color.red}, #{color.green}, #{color.blue}, #{color.alpha})"
      @__element.style.boxShadow = shadowstyle

    else
      @__element.style.boxShadow = "none"

  #===========================================================================
  # add sub view
  #===========================================================================
  addSubview:(obj) ->
    if (obj? && obj.__element?)
      obj.parent = @self
      obj.__parent = @self
      @__childobj[obj.UniqueID] = obj
      __ACTORLIST[obj.UniqueID] = obj
      if (@__element?)
        obj.__element.style.visibility = "hidden"
        addelement = @__addelement || @__element
        addelement.appendChild(obj.__element)
        obj.viewDidLoad()
        obj.viewDidAppear()
        obj.setStyle()
        obj.__styleUpdateFlag = true
        obj.__setTouches()
        obj.__bindGesture()
        setTimeout =>
          obj.__element.style.visibility = "visible"
        , 0

  #===========================================================================
  # remove from super view
  #===========================================================================
  removeFromSuperview: ->
    @viewWillDisappear() if (@viewWillDisappear?)
    if (@parent?)
      @parent.__removeChildobj(@UniqueID)
    for id, obj of @__childobj
      obj.removeFromSuperview()
    @__childobj = undefined
    delete __ACTORLIST[@UniqueID]
    $(@__viewSelector).remove()

  #===========================================================================
  # bring view to front
  #===========================================================================
  bringViewToFront: ->
    if (!@editable)
      v = $(@__viewSelector)
      v.appendTo(v.parent())

  #===========================================================================
  # send view to back
  #===========================================================================
  sendViewToBack: ->
    if (!@editable)
      v = $(@__viewSelector)
      v.prependTo(v.parent())

  #===========================================================================
  # animate with duration
  #===========================================================================
  animateWithDuration:(duration, animations, completion = undefined) ->
    duration *= 1000
    animobj = {}
    for key, value of animations
      switch (key)
        when "x"
          key = "left"
        when "y"
          key = "top"
        when "alpha"
          key = "opacity"
        when "backgroundColor"
          key = "background-color"
          value = CSSRGBA(value)
      animobj[key] = value

    @__styleUpdateFlag = false
    $(@__viewSelector).animate animobj, duration, =>
      for key, value of animobj
        switch key
          when "left"
            @frame.origin.x = value
          when "top"
            @frame.origin.y = value
          when "width"
            @frame.size.width = value
          when "height"
            @frame.size.height = value
          when "opacity"
            @alpha = value
          when "border-width"
            @borderWidth = value
          when "border-color"
            @borderColor = value
          when "background-color"
            @backgroundColor = animations['backgroundColor']

      if (completion?)
        @setStyle()
        completion(@self)

    @__styleUpdateFlag = true

  #===========================================================================
  # add tap gesture
  #===========================================================================
  addTapGesture:(tapaction, tapnum = 1) ->
    if (tapnum == 1)
      @__tapaction = tapaction
    else if (tapnum == 2)
      @__tapaction2 = tapaction

  #===========================================================================
  #===========================================================================
  removeTapGesture:(tapnum)->
    if (!@__element?)
      return

    $(@__viewSelector).unbind("click tap")
    switch tapnum
      when 1
        @__tapaction = undefined
      when 2
        @__tapaction2 = undefined

  #===========================================================================
  #===========================================================================
  #===========================================================================
  #
  # delegate method
  #
  #===========================================================================
  #===========================================================================
  #===========================================================================

  #===========================================================================
  # window resize
  #===========================================================================
  didWindowsResize:->

  #===========================================================================
  # browser resize event
  #===========================================================================
  didBrowserResize:->
    bounds = FWApplication.getBounds()
    for key, obj of @__childobj
      obj.didBrowserResize(bounds) if (typeof(obj.didBrowserResize) == 'function')

  #===========================================================================
  # behavior method
  #===========================================================================
  behavior:->

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
  # bind gesture
  #===========================================================================
  __bindGesture:->
    $(@__viewSelector).unbind("tap")
    $(@__viewSelector).on "tap", (event) =>

      if (@userInteractionEnabled)
        event.stopPropagation()

      if (!@__tapaction? || @userInteractionEnabled == false || @hidden == true)
        return false

      setTimeout =>
        if (!@__dblclickflag)
          if (event.changedTouches != undefined)
            evt = event.changedTouches[0]
          else
            evt = event
          pos =
            offsetX: evt.x
            offsetY: evt.y
          @__tapaction(evt, pos, @)
        @__dblclickflag = false
      , 200
      return false

    $(@__viewSelector).unbind("doubletap")
    $(@__viewSelector).on "doubletap", (event)=>

      if (@userInteractionEnabled)
        event.stopPropagation()

      if (!@__tapaction2? || @userInteractionEnabled == false || @hidden == true)
        return false

      if (event.changedTouches != undefined)
        evt = event.changedTouches[0]
      else
        evt = event
      pos =
        offsetX: evt.x
        offsetY: evt.y
      @__tapaction2(evt, pos, @)
      @__dblclickflag = true
      return false

  #===========================================================================
  # add touch gesture
  #===========================================================================
  __setTouches:->
    if (!@__element?)
      return

    $(@__viewSelector).bind
      'touchstart mousedown':(event)=>
        if (!event? || !@userInteractionEnabled)
          return

        @__touched = true

        if (event.changedTouches != undefined)
          e = event.changedTouches[0]
        else
          e = event
        pos =
          offsetX: Math.floor(e.offsetX)
          offsetY: Math.floor(e.offsetY)
          pageX: Math.floor(e.pageX)
          pageY: Math.floor(e.pageY)

        if (typeof @touchesBegan == 'function')
          @touchesBegan(pos, e)

      'touchmove mousemove':(event)=>
        if (!event? || !@userInteractionEnabled)
          return

        if (event.changedTouches != undefined)
          e = event.changedTouches[0]
          pos =
            offsetX: Math.floor(e.pageX - @__pageorigin.x)
            offsetY: Math.floor(e.pageY - @__pageorigin.y)
            pageX: Math.floor(e.pageX)
            pageY: Math.floor(e.pageY)
          if (pos.offsetX < 0 || pos.offsetY < 0 || pos.offsetX > @frame.size.width || pos.offsetY > @frame.size.height)
            @__triggerEvent(@__element, "touchout")
            return
        else
          e = event
          pos =
            offsetX: Math.floor(e.offsetX)
            offsetY: Math.floor(e.offsetY)
            pageX: Math.floor(e.pageX)
            pageY: Math.floor(e.pageY)

        if (typeof @touchesMoved == 'function')
          @touchesMoved(pos, e)

      'touchend mouseup':(event)=>
        if (!@__touched || !event? || !@userInteractionEnabled)
          return

        if (event.changedTouches != undefined)
          e = event.changedTouches[0]
        else
          e = event
        pos =
          offsetX: Math.floor(e.offsetX)
          offsetY: Math.floor(e.offsetY)
          pageX: Math.floor(e.pageX)
          pageY: Math.floor(e.pageY)

        @__touched = false
        if (typeof @touchesEnded == 'function')
          @touchesEnded(pos, e)

      'touchcancel mouseleave':(event)=>
        if (!@__touched || !event? || !@userInteractionEnabled)
          return

        @__touched = false
        if (event.changedTouches != undefined)
          e = event.changedTouches[0]
        else
          e = event
        pos =
          offsetX: e.offsetX
          offsetY: e.offsetY
          pageX: e.pageX
          pageY: e.pageY

        if (typeof @touchesCanceled == 'function')
          @touchesCanceled(pos, e)

  #===========================================================================
  # remove child obj
  #===========================================================================
  __removeChildobj:(id) ->
    delete @__childobj[id]

  #===========================================================================
  # get absolute position
  #===========================================================================
  __getAbsolutePosition:(param)->
    obj = param.obj
    x = param.x || 0
    y = param.y || 0
    x += obj.frame.origin.x
    y += obj.frame.origin.y

    if (!obj.parent?)
      return param
    else
      ret = @__getAbsolutePosition
        obj: obj.parent
        x: x
        y: y
    return ret

  #===========================================================================
  # setDraggable
  #===========================================================================
  __setDraggable:->
    # ドラッグがtrueかfalseかで処理を分ける
    if (@draggable)
      dragalpha = if (@alpha < 0.8) then @alpha else 0.8
      # 親のviewエリアに束縛されていた
      if (!@parent.containment?)
        $(@__viewSelector).draggable
          disabled: true
        $(@__viewSelector).draggable("destroy")

      # draggableの設定
      $(@__viewSelector).draggable
        disabled: false
        containment: if (@parent.containment) then "parent" else false
        opacity: dragalpha
        start: (event, ui) =>
        drag:(event, ui) =>
          @__styleUpdateFlag = false
          x = parseInt(@__element.style.left.replace(/px/, ""))
          y = parseInt(@__element.style.top.replace(/px/, ""))
          @frame.origin.x = x
          @frame.origin.y = y
          @__styleUpdateFlag = true
        stop: (event, ui) =>
          @__styleUpdateFlag = false
          @frame = FWRectMake(
            parseFloat(ui.position.left)
            parseFloat(ui.position.top)
            @frame.size.width
            @frame.size.height
          )
          @__styleUpdateFlag = true
    else
      $(@__viewSelector).draggable
        disabled: true

  #===========================================================================
  # setResizable
  #===========================================================================
  __setResizable:->
    if (@resizable)
      $(@__viewSelector).resizable
        disabled: false
        handles: "n, e, s, w, se"
        ghost: true
        stop: (event, ui) =>
          @__styleUpdateFlag = false
          @frame = FWRectMake(
            ui.position.left
            ui.position.top
            ui.size.width
            ui.size.height
          )
          @didWindowResize()
          @__styleUpdateFlag = true
    ###
    else
      $(@__viewSelector).resizable
        disabled: true
        handles: undefined
    ###

  #===========================================================================
  # setBackgroundColor
  #===========================================================================
  __setBackgroundColor:->
    @__element.style.backgroundColor = CSSRGBA(@backgroundColor)

  #===========================================================================
  # setBorder
  #===========================================================================
  __setBorder:->
    @__element.style.border = "#{@borderWidth}px solid "+CSSRGBA(@borderColor)

  #===========================================================================
  # setAlpha
  #===========================================================================
  __setAlpha:->
    @__element.style.opacity = @alpha

  #===========================================================================
  # setHidden
  #===========================================================================
  __setHidden:->
    hidden = if (@hidden) then "none" else "table-cell"
    @__element.style.display = hidden

  #===========================================================================
  # setFrame
  #===========================================================================
  __setFrame:(frame) ->
    bounds = FWApplication.getBounds()
    origin = if (frame.origin?) then frame.origin else @frame.origin
    size = if (frame.size?) then frame.size else @frame.size
    @__element.style.left = "#{@frame.origin.x}px"
    @__element.style.top = "#{@frame.origin.y}px"
    @__element.style.width = "#{@frame.size.width}px"
    @__element.style.height = "#{@frame.size.height}px"

  #===========================================================================
  # setCornerRadius
  #===========================================================================
  __setCornerRadius:->
    if (@__element?)
      @__element.style.borderRadius = @cornerRadius+"px"

      $(@__viewSelector).css("-webkit-border-radius", @cornerRadius+"px")
      $(@__viewSelector).css("-moz-border-radius", @cornerRadius+"px")

  #===========================================================================
  # create tag
  #===========================================================================
  __createElement:->
    @__element = document.createElement("div")
    @__addelement = @__element
    @__element.setAttribute("id", @UniqueID)
    @__element.style.position = "absolute"
    @__element.style.zIndex = 1
    @__element.style.display = "table-cell"
    @__element.style.wordBreak = "break-all"
    @__element.style.overflow = "hidden"

    @__element.style.userSelect = "none"
    @__element.style["-webkit-touch-callout"] = "none"
    @__element.style["-webkit-user-select"] = "none"
    @__element.style["-moz-user-select"] = "none"
    @__element.style["-ms-user-select"] = "none"
    @__element.style["-khtml-user-select"] = "none"
    @__element.style["-o-user-select"] = "none"

  #===========================================================================
  #trigger event
  #===========================================================================
  __triggerEvent:(element, event)->
    if (document.createEvent)
      evt = document.createEvent("mouseEvents")
      evt.initEvent(event, false, true )
      return element.dispatchEvent(evt)
     else
      evt = document.createEventObject()
      return element.fireEvent("on"+event, evt)

  #===========================================================================
  # touch event
  #===========================================================================
  touchesBegan:(pos, e)->
  touchesMoved:(pos, e)->
  touchesEnded:(pos, e)->
  touchesCanceled:(pos, e)->

###
---model_start---
class [classname] extends UIWindow
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

  #==================================
  #==================================
  setStyle:(key=undefined)->
    super(key)

  #==================================
  #==================================
  #didBrowserResize:(bounds)->
  #   super()

  #==================================
  #==================================
  #didWindowsResize:->
  #   super()

  #==================================
  #==================================
  #behavior:->
  #   super()

  #==================================
  #==================================
  #touchesBegan:(pos, e)->
  #   super()

  #==================================
  #==================================
  #touchesMoved:(pos, e)->
  #   super()

  #==================================
  #==================================
  #touchesEnded:(pos, e)->
  #   super()

  #==================================
  #==================================
  #touchesCanceled:(pos, e)->
  #   super()
---model_end---
###
