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
    @viewelement = undefined # このviewにaddSubviewされたものが追加されるエレメント

    # private values
    @__element = undefined # 外観を形成するエレメント
    @__styleUpdateFlag = false
    @__viewSelector = "#"+@UniqueID
    @__childobj = {}
    @__touched = false
    @__clickpos =
        x: 0
        y: 0
    @__tapaction = undefined
    @__tapaction2 = undefined
    @__dblclickflag = false
    @constraints =
      isActive: false
      position:
        left: undefined
        top: undefined
        right: undefined
        bottom: undefined
      space:
        leading:
          target: undefined
          constant: undefined
        trailing:
          target: undefined
          constant: undefined
        top:
          target: undefined
          constant: undefined
        bottom:
          target: undefined
          constant: undefined
      aspect: undefined
      center:
        horizontal: undefined
        vertical: undefined
      equal:
        width: undefined
        height: undefined


    # style values
    # ここに登録してあるパラーメータはメンバー変数として登録されます。
    # このオブジェクト内の値は、「defineProperty」で変更を検知し、変更
    # を検知した場合「@setStyle()」が呼ばれ、見映えに反映されます。
    # 「UIWindow」を継承したクラスで見映えに影響する変数はこのオブジェクト
    # に追加し、「setStyle()」メソッドをオーバーライドし、追加し
    # たメソッドが変更された場合の、見映えへの反映コードを記述します。
    @__style =
      shadow: false
      shadowStyle: 'box'
      #resizable: false
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
          if (@__styleUpdateFlag && typeof(@setStyle) == 'function')
            setTimeout =>
              styleUpdateBackup = @__styleUpdateFlag
              @__styleUpdateFlag = false
              @setStyle(key)
              @__styleUpdateFlag = styleUpdateBackup
            , 0
        enumerable: true
        configurable: false

    return (stylelist, obj, key=undefined) =>
      if (!stylelist?)
        return
      obj = stylelist if (!obj?)
      setDescriptor(stylelist, obj, key)
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
        addelement = @viewelement || @__element
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

    else if (!key?)
      @__setBackgroundColor()
      @__setDraggable()
      #@__setResizable()
      @__setBorder()
      @__setAlpha()
      @__setFrame(@frame)
      @__setCornerRadius()
      @setShadow(@shadow, @shadowParam)
      @__setHidden()
    else
      flag = false
      if (['backgroundColor'].indexOf(key) >= 0)
        flag = true
        @__setBackgroundColor()
      if (['draggable'].indexOf(key) >= 0)
        flag = true
        @__setDraggable()
      #if (['resizable'].indexOf(key) >= 0)
      #  flag = true
      #  @__setResizable()
      if (['borderColor', 'borderWidth'].indexOf(key) >= 0)
        flag = true
        @__setBorder()
      if (['alpha'].indexOf(key) >= 0)
        flag = true
        @__setAlpha()
      if (['frame', 'size', 'origin'].indexOf(key) >= 0)
        flag = true
        @__setFrame(@frame)
      if (['constraints', 'frame'].indexOf(key) >= 0)
        flag = true
        @__setConstraints(@frame, key)
      if (['cornerRadius'].indexOf(key) >= 0)
        flag = true
        @__setCornerRadius()
      if (['shadow', 'shadowParam'].indexOf(key) >= 0)
        flag = true
        @setShadow(@shadow, @shadowParam)
      if (['hidden'].indexOf(key) >= 0)
        flag = true
        @__setHidden()
      if (!flag)
        @__setBackgroundColor()
        @__setDraggable()
        #@__setResizable()
        @__setBorder()
        @__setAlpha()
        @__setFrame(@frame)
        @__setCornerRadius()
        @setShadow(@shadow, @shadowParam)
        @__setHidden()

    #-------------------------------------------------------------------------
    # click event
    #-------------------------------------------------------------------------
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
      if (@shadowStyle == "box")
        @__element.style.boxShadow = shadowstyle
        @__element.style.filter = "none"
      else if (@shadowStyle == "drop")
        @__element.style.boxShadow = "none"
        @__element.style.dropShadow = "drop-shadow('#{shadowstyle}')"

    else
      @__element.style.boxShadow = "none"
      @__element.style.filter = "none"

  #===========================================================================
  # add sub view
  #===========================================================================
  addSubview:(obj) ->
    if (obj? && obj.__element?)
      obj.parent = @self
      obj.__parent = @self
      @__childobj[obj.UniqueID] = obj
      __VIEWOBJECT[obj.UniqueID] = obj
      if (@__element?)
        obj.__element.style.visibility = "hidden"
        addelement = @viewelement || @__element
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
    delete __VIEWOBJECT[@UniqueID]
    if (@parent?)
      self = document.getElementById(@UniqueID)
      parentnode = @parent.viewelement || @parent.__element
      parentnode.removeChild(self)

  #===========================================================================
  # bring view to front
  #===========================================================================
  bringViewToFront: ->
    @parent.viewelement.removeChild(@__element)
    @parent.viewelement.appendChild(@__element)

  #===========================================================================
  # send view to back
  #===========================================================================
  sendViewToBack: ->
    @parent.viewelement.removeChild(@__element)
    @parent.viewelement.prepend(@__element)

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

    #--------------------------------------
    # mouse down event
    #--------------------------------------
    _touchesbegan = (self, event)=>
      if (!event? || !@userInteractionEnabled)
        return

      if (typeof @touchesBegan == 'function')
        @__touched = true
        ret = @__getMouseClickPosition(event)
        @__clickpos.x = ret.pos.offsetX
        @__clickpos.y = ret.pos.offsetY
        @touchesBegan(ret.pos, ret.event)

    eventlist = ["mousedown", "click", "touchstart"]
    eventlist.forEach (evt) =>
      document.addEventListener evt, _touchesbegan(event), false

    #--------------------------------------
    # mouse move event
    #--------------------------------------
    eventlist = ["mousemove", "touchmove"]
    eventlist.forEach (evt) =>
      document.addEventListener evt, (event) =>
        if (!event? || !@userInteractionEnabled || !@__touched)
          return

        if (typeof @touchesMoved == 'function')
          ret = @__getMouseClickPosition(event)
          echo "draggable=%@, touched=%@, x=%@, y=%@", @draggable, @__touched, ret.pos.offsetX, ret.pos.offsetY
          @touchesMoved(ret.pos, ret.event)
    , false

    #--------------------------------------
    # mouse up event
    #--------------------------------------
    eventlist = ["mouseup", "touchend"]
    eventlist.forEach (evt) =>
      document.addEventListener evt, (event) =>
        @__touched = false
        echo "mouseup: touched=%@", @__touched

        if (!event? || !@userInteractionEnabled)
          return

        if (typeof @touchesEnded == 'function')
          ret = @__getMouseClickPosition(event)
          @touchesEnded(ret.pos, ret.event)
    , false

    #--------------------------------------
    # mouse leave event
    #--------------------------------------
    eventlist = ["mouseleave"]
    eventlist.forEach (evt) =>
      document.addEventListener evt, (event) =>
        if (!event? || !@userInteractionEnabled)
          return

        if (typeof @touchesCanceled == 'function')
          ret = @__getMouseClickPosition(event)
          @touchesCanceled(ret.pos, ret.event)
    , false

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
    ###
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
          style = @__styleUpdateFlag
          @__styleUpdateFlag = false
          @frame.origin.x = parseInt(@__element.style.left.replace(/px/, ""))
          @frame.origin.y = parseInt(@__element.style.top.replace(/px/, ""))
          @__setFrame(@frame)
          @__styleUpdateFlag = style
        stop: (event, ui) =>
          #style = @__styleUpdateFlag
          #@__styleUpdateFlag = false
          @frame = FWRectMake(
            parseFloat(ui.position.left)
            parseFloat(ui.position.top)
            @frame.size.width
            @frame.size.height
          )
          #@__setFrame(@frame)
          #@__styleUpdateFlag = style
    else
      $(@__viewSelector).draggable
        disabled: true
    ###

  #===========================================================================
  # setResizable
  #===========================================================================
  ###
  __setResizable:->
    if (@resizable)
      $(@__viewSelector).resizable
        disabled: false
        handles: "n, e, s, w, se"
        ghost: true
        resize:(event, ui) =>
          style = @__styleUpdateFlag
          @__styleUpdateFlag = false
          @frame = FWRectMake(
            ui.position.left
            ui.position.top
            ui.size.width
            ui.size.height
          )
          @__setFrame(@frame)
          @__styleUpdateFlag = style
        stop: (event, ui) =>
          #style = @__styleUpdateFlag
          #@__styleUpdateFlag = false
          @frame = FWRectMake(
            ui.position.left
            ui.position.top
            ui.size.width
            ui.size.height
          )
          #@__styleUpdateFlag = style
    #else
    #  $(@__viewSelector).resizable
    #    disabled: true
    #    handles: undefined
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
    newframe = {}
    newframe.origin = if (frame.origin?) then frame.origin else @frame.origin
    newframe.size = if (frame.size?) then frame.size else @frame.size

    #@__setConstraints(newframe, 'frame')

    ret = @__getAbsolutePosition
      obj: @self
      x: newframe.origin.x
      y: newframe.origin.y
    @frame.origin.pageX = ret.x
    @frame.origin.pageY = ret.y

    @__element.style.left = "#{newframe.origin.x}px"
    @__element.style.top = "#{newframe.origin.y}px"
    @__element.style.width = "#{newframe.size.width}px"
    @__element.style.height = "#{newframe.size.height}px"

  #===========================================================================
  # setCornerRadius
  #===========================================================================
  __setCornerRadius:->
    if (@__element?)
      @__element.style.borderRadius = @cornerRadius+"px"

      #$(@__viewSelector).css("-webkit-border-radius", @cornerRadius+"px")
      #$(@__viewSelector).css("-moz-border-radius", @cornerRadius+"px")

  #===========================================================================
  # set constraints
  #===========================================================================
  __setConstraints:(frame, key=undefined)->
    #----------------
    # copy current frame to temporary
    #----------------
    tmpframe = objCopy(frame)
    if (@constraints.position.left?)
      tmpframe.origin.x = @constraints.position.left

    if (@constraints.isActive == false)
      return tmpframe

    #----------------
    # position constraints
    #----------------
    if (@constraints.position.left?)
      tmpframe.origin.x = @constraints.position.left

    if (@constraints.position.top?)
      tmpframe.origin.y = @constraints.position.top

    #----------------
    # size constraints
    #----------------
    if (@constraints.position.left? && @constraints.position.right?)
      tmpframe.size.width = @constraints.position.right - @constraints.position.left

    if (@constraints.position.top? && @constraints.position.bottom?)
      tmpframe.size.height = @constraints.position.bottom - @constraints.position.top

    if (@constraints.space.leading.target?)
      if (!@constraints.position.left?)
        constant = @constraints.space.leading.constant || 0
        selfx = tmpframe.origin.x
        targetx = @constraints.space.leading.target.frame.origin.x
        if (selfx < targetx)
        else
          x = (@constraints.space.leading.target.frame.origin.x + @constraints.space.leading.target.frame.size.width) + 1 + constant
      else
        x = @constraints.position.left

      if (!@constraints.position.right?)
        right = @constraints.space.trailing.target.frame.origin.x - 1 - tmpframe.size.width - @constraints.space.trailing.constant

    ###
      constraints:
        position:
          left: undefined
          top: undefined
          right: undefined
          bottom: undefined
        space:
          leading:
            target: undefined
            edge: undefined
            value: undefined
          trailing:
            target: undefined
            edge: undefined
            value: undefined
          top:
            target: undefined
            edge: undefined
            value: undefined
          bottom:
            target: undefined
            edge: undefined
            value: undefined
        aspect: undefined
        center:
          horizontal: undefined
          vertical: undefined
    ###

  #===========================================================================
  # create tag
  #===========================================================================
  __createElement:->
    @__element = document.createElement("div")
    @viewelement = @__element
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
  # trigger event
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
  # get mouse click position for event
  #===========================================================================
  __getMouseClickPosition:(event)->
    if (event.changedTouches != undefined)
      e = event.changedTouches[0]
      pos =
        offsetX: e.pageX - @frame.origin.pageX
        offsetY: e.pageY - @frame.origin.pageY
        pageX: e.pageX
        pageY: e.pageY

      if (pos.offsetX < 0 || pos.offsetY < 0 || pos.offsetX > @frame.size.width || pos.offsetY > @frame.size.height)
        @__triggerEvent(@__element, "touchout")
        return

    else
      e = event
      pos =
        offsetX: e.offsetX
        offsetY: e.offsetY
        pageX: e.pageX
        pageY: e.pageY

    return
      event: e
      pos: pos

  #===========================================================================
  # touch event
  #===========================================================================
  touchesBegan:(pos, e)->

  #===========================================================================
  #===========================================================================
  touchesMoved:(pos, e)->

  #===========================================================================
  #===========================================================================
  touchesEnded:(pos, e)->

  #===========================================================================
  #===========================================================================
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
  #   super(bounds)

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
  #   super(pos, e)

  #==================================
  #==================================
  #touchesMoved:(pos, e)->
  #   super(pos, e)

  #==================================
  #==================================
  #touchesEnded:(pos, e)->
  #   super(pos, e)

  #==================================
  #==================================
  #touchesCanceled:(pos, e)->
  #   super(pos, e)
---model_end---
###
