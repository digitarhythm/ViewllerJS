#============================================================================
# UIDialogView - dialog input value
#============================================================================

class UIDialogView extends UIView
  constructor:(@param)->
    super()
    @hidden = true
    @backgroundColor = FWColor(0, 0, 0, 0.0)

    @delegate = undefined
    if (@param.cancel?)
      @cancel = @param.cancel
    else
      @cancel = true

    @__style.tintColor = FWColor(200, 200, 200, 0.8)
    @__style.tintFontColor = FWColor(0, 0, 0, 0.8)
    @__style.submitColor = FWColor(0, 0, 0, 0.9)
    @__style.cancelColor = FWColor(100, 100, 100, 0.9)
    @__style.submitFontColor = FWColor(200, 200, 200, 0.9)
    @__style.cancelFontColor = FWColor(0, 0, 0, 0.9)

    @__rootview = GLOBAL['rootview']
    @__coverview = new UIView(FWRectMake(
      0
      0
      @__rootview.frame.size.width
      @__rootview.frame.size.height
    ))
    @__coverview.backgroundColor = FWColor(0, 0, 0, 0.8)
    @__coverview.alpha = 1.0
    @__coverview.hidden = true
    @__rootview.addSubview(@__coverview)

    @__title = undefined
    @__cancel = undefined
    @__dialog = undefined
    @__dialogID = @param.id || @UniqueID
    @__submit_flag = false
    @__cancel_flag = false
    @__columnlist = []

    if (@param.column?)
      for item, idx in @param.column
        @__columnlist[idx] = item

    @setObserve(@__style, @)

  viewDidLoad:->
    super()

  viewWillDisappear:->
    super()
    $(@__title).remove()
    $(@__cancel).remove()
    $(@__form).remove()
    $(@__dialog).remove()
    @__coverview.removeFromSuperview()

  didBrowserResize:->
    bounds = FWApplication.getBounds()
    @__coverview.frame = bounds

  show:(func = undefined)->
    @__coverview.backgroundColor = FWColor(0, 0, 0, 0.0)
    @__coverview.hidden = false
    @__coverview.animateWithDuration 0.3,
      backgroundColor: FWColor(0, 0, 0, 0.9)
    , =>
      dwidth = Math.floor(@__rootview.frame.size.width / 3)
      if (dwidth < 480 && @__rootview.frame.size.width < 480)
        dwidth = @__rootview.frame.size.width - 32

      titlewidth = dwidth
      titleheight = 48
      descheight = 24
      inputheight = 32
      linediff = 16
      footerdiff = linediff / 2
      cnum = @__columnlist.length
      dheight = titleheight + (cnum * (descheight + inputheight + linediff)) + linediff

      linewidth = dwidth - 24
      if (dheight > @__rootview.frame.size.height * 0.8)
        # adjust scrollbar
        dheight = (@__rootview.frame.size.height * 0.8) - 32
        linewidth = dwidth - 32

      left = Math.floor((@__rootview.frame.size.width - dwidth) / 2)
      top = Math.floor((@__rootview.frame.size.height - dheight) / 2)

      body = document.getElementsByTagName("body")[0]

      @__dialog = document.createElement("div")
      @__dialog.setAttribute("id", @UniqueID+'_dialog')
      @__dialog.style.zIndex = 1
      @__dialog.style.position = "absolute"
      @__dialog.style.left = "#{left}px"
      @__dialog.style.top = "#{top}px"
      @__dialog.style.width = "#{dwidth}px"
      @__dialog.style.height = "#{dheight}px"
      @__dialog.style.backgroundColor = CSSRGBA(@backgroundColor)
      @__dialog.style.boxShadow = "2px 2px 16px rgba(255, 255, 255, 0.6)"
      @__dialog.style.fontSize = "10pt"
      @__dialog.style.fontWeghit = "bold"
      @__dialog.style.color = CSSRGBA(FWColor(255, 255, 255, 1.0))
      @__dialog.style.borderRadius = "4px"
      @__dialog.style.overflow = "hidden"
      @__dialog.style.user-select = "none"
      @__dialog.style["-webkit-touch-callout"] = "none"
      @__dialog.style["-webkit-user-select"] = "none"
      @__dialog.style["-moz-user-select"] = "none"
      @__dialog.style["-ms-user-select"] = "none"
      @__dialog.style["-khtml-user-select"] = "none"
      @__dialog.style["-o-user-select"] = "none"

      $(@__dialog).on "tap", (event) =>
        event.stopPropagation()
      $(@__coverview.__viewSelector).append(@__dialog)
      body.appendChild(@__dialog)

      @__form = document.createElement("form")
      @__form.setAttribute("id", @UniqueID+"_form")
      @__form.setAttribute("method", "post")
      @__form.style.position = "absolute"
      @__form.style.left = "0px"
      @__form.style.top = "0px"
      @__form.style.width = "#{dwidth}px"
      @__form.style.height = "#{dheight}px"
      @__form.style.overflow = "auto"
      @__form.style.user-select = "none"
      @__form.style["-webkit-touch-callout"] = "none"
      @__form.style["-webkit-user-select"] = "none"
      @__form.style["-moz-user-select"] = "none"
      @__form.style["-ms-user-select"] = "none"
      @__form.style["-khtml-user-select"] = "none"
      @__form.style["-o-user-select"] = "none"

      @__dialog.appendChild(@__form)

      color = CSSRGBA(@param.color || FWColor(255, 255, 255, 1.0))
      bgcolor = @param.titleColor || {start: @backgroundColor, end: @backgroundColor}
      start = CSSRGBA(bgcolor.start)
      end = CSSRGBA(bgcolor.end)
      @__title = document.createElement("div")
      @__title.setAttribute("id", @UniqueID+'_title')
      @__title.style.zIndex = 2
      @__title.style.position = "relative"
      @__title.style.left = "#{left+1}px"
      @__title.style.top = "#{top}px"
      @__title.style.width = "#{titlewidth}px"
      @__title.style.height = "#{titleheight}px"
      @__title.style.fontSize = "14pt"
      @__title.style.textAlign = "center"
      @__title.style.display = "table-cell"
      @__title.style.verticalAlign = "middle"
      @__title.style.borderRadius = "4px"
      @__title.style.backgroundColor = CSSRGBA(FWColor(0, 0, 0, 0.8))
      @__title.style.color = color
      @__title.style.padding = "0px"
      @__title.style.user-select = "none"
      @__title.style["-webkit-touch-callout"] = "none"
      @__title.style["-webkit-user-select"] = "none"
      @__title.style["-moz-user-select"] = "none"
      @__title.style["-ms-user-select"] = "none"
      @__title.style["-khtml-user-select"] = "none"
      @__title.style["-o-user-select"] = "none"

      @__title.style.backgroundColor = bgcolor
      @__title.textContent = @param.title

      body.appendChild(@__title)

      if (@__columnlist.length > 0)
        tabindex = 1
        inputx = 8
        inputy = titleheight
        descriptioncolor = @param.descriptionColor || CSSRGBA(FWColor(255, 255, 255, 0.8))
        for item in @__columnlist
          key = item.name || "column_#{idx}"
          desc = item.description || "description #{idx}"
          type = item.type || "input"
          defaultvalue = item.default || ""

          switch type
            when "input", "password", "passwd"
              column_desc = document.createElement("div")
              column_desc.setAttribute("id", @UniqueID+"_title_"+key)
              column_desc.style.zIndex = 2
              column_desc.style.position = "absolute"
              column_desc.style.left = "#{inputx}px"
              column_desc.style.top = "#{inputy}px"
              column_desc.style.width = "#{linewidth}px"
              column_desc.style.height = "#{descheight}px"
              column_desc.style.fontSize = "12pt"
              column_desc.style.color = descriptioncolor
              column_desc.style.textAlign = "left"
              column_desc.style.fontWeight = "normal"
              column_desc.style.padding = "0px"
              column_desc.style.user-select = "none"
              column_desc.style["-webkit-touch-callout"] = "none"
              column_desc.style["-webkit-user-select"] = "none"
              column_desc.style["-moz-user-select"] = "none"
              column_desc.style["-ms-user-select"] = "none"
              column_desc.style["-khtml-user-select"] = "none"
              column_desc.style["-o-user-select"] = "none"

              column_desc.textContent = desc
              @__form.append(column_desc)
              inputy += descheight

              column_input = document.createElement("input")
              column_input.setAttribute("id", @UniqueID+"_input_"+key)
              if (type == "passwd" || type == "password")
                column_input.setAttribute("type", "password")
              else
                column_input.setAttribute("type", "text")
              column_input.setAttribute("tabindex", tabindex)
              column_input.style.zIndex = 2
              column_input.style.position = "absolute"
              column_input.style.left = "#{inputx}px"
              column_input.style.top = "#{inputy}px"
              column_input.style.width = "#{linewidth-8}px"
              column_input.style.height = "#{inputheight}px"
              column_input.style.fontSize = "12pt"
              column_input.style.color = CSSRGBA(FWColor(250, 250, 250, 1.0))
              column_input.style.backgroundColor = CSSRGBA(FWColor(250, 250, 250, 0.4))
              column_input.style.textAlign = "left"
              column_input.style.fontWeight = "normal"
              column_input.style.padding = "4px"
              column_input.style.borderRadius = "6px"
              column_input.style.boxShadow = "2px 2px 8px rgba(64, 64, 64, 0.6)"
              column_input.setAttribute("value", defaultvalue)
              column_input.setSelectionRange(-1, -1)
              @__form.appendChild(column_input)

              if (tabindex == 1)
                $(@__viewSelector+"_input_"+key).focus()
              inputy += (inputheight+linediff)
              tabindex++

      footer = document.createElement("div")
      footer.setAttribute("id", @UniqueID+"_dummy")
      footer.style.position = "absolute"
      footer.style.left = "0px"
      footer.style.top = "#{inputy}px"
      footer.style.width = "#{linewidth}px"
      footer.style.height = "#{footerdiff}px"
      @__form.appendChild(footer)
      inputy += footerdiff

      buttonwidth = Math.floor(dwidth / 4) - 8
      buttonheight = titleheight + 10

      @submit_left = left + dwidth - buttonwidth - 8
      @submit_top = top + dheight + 8
      @submit = document.createElement("button")
      @submit.setAttribute("id", @UniqueID+'_submit')
      @submit.style.zIndex = 2
      @submit.style.position = "absolute"
      @submit.style.left = @submit_left+"px"
      @submit.style.top = @submit_top+"px"
      @submit.style.width = buttonwidth+"px"
      @submit.style.height = buttonheight+"px"
      @submit.style.fontSize = "10pt"
      @submit.style.color = CSSRGBA(@submitFontColor)
      @submit.style.fontWeight = "bold"
      @submit.style.backgroundColor = CSSRGBA(@submitColor)
      @submit.style.border = "1px #ffffff solid"
      @submit.style.borderRadius = "4px"
      @submit.textContent = "OK"
      @submit.style.user-select = "none"
      @submit.style["-webkit-touch-callout"] = "none"
      @submit.style["-webkit-user-select"] = "none"
      @submit.style["-moz-user-select"] = "none"
      @submit.style["-ms-user-select"] = "none"
      @submit.style["-khtml-user-select"] = "none"
      @submit.style["-o-user-select"] = "none"

      $(@submit).unbind("touchstart mousedown")
      $(@submit).unbind("touchend mouseup")
      $(@submit).on "touchstart mousedown", (event) =>
        @submit.style.left = (@submit_left + 2)+"px"
        @submit.style.top = (@submit_top + 2)+"px"
        @submit.style.boxShadow = "0px 0px 0px"
        @__submit_flag = true
      $(@submit).on "touchend mouseup", (event) =>
        if (!@__submit_flag)
          return
        if (func?)
          func()
        inputval = {}
        for item in @__columnlist
          key = item.name || "column_#{idx}"
          val = $(@__viewSelector+"_input_"+key).val()
          inputval[key] = val
        @close =>
          @delegate.didSubmitDialog(inputval, @__dialogID) if (@delegate? && typeof(@delegate.didSubmitDialog) == 'function')
      @submit.addEventListener 'mouseenter', (event) =>
        @submit.style.backgroundColor = CSSRGBA(@tintColor)
        @submit.style.color = CSSRGBA(@tintFontColor)
      @submit.addEventListener 'mouseleave', (event) =>
        @__submit_flag = false
        @submit.style.left = (@submit_left)+"px"
        @submit.style.top = (@submit_top)+"px"
        @submit.style.boxShadow = "2px 2px 4px rgba(64, 64, 64, 0.6)"
        @submit.style.backgroundColor = CSSRGBA(@submitColor)
        @submit.style.color = CSSRGBA(@submitFontColor)
      body.appendChild(@submit)

      tabindex++

      if (@cancel)
        @cancel_left = @submit_left - buttonwidth - 16
        @cancel_top = @submit_top
        @__cancel = document.createElement("button")
        @__cancel.setAttribute("id", @UniqueID+'_cancel')
        @__cancel.style.zIndex = 2
        @__cancel.style.position = "absolute"
        @__cancel.style.left = @cancel_left+"px"
        @__cancel.style.top = @cancel_top+"px"
        @__cancel.style.width = buttonwidth+"px"
        @__cancel.style.height = buttonheight+"px"
        @__cancel.style.fontSize = "10pt"
        @__cancel.style.color = CSSRGBA(@cancelFontColor)
        @__cancel.style.fontWeight = "bold"
        @__cancel.style.backgroundColor = CSSRGBA(@cancelColor)
        @__cancel.style.borderRadius = "4px"
        @__cancel.textContent = "Cancel"
        @__cancel.style.user-select = "none"
        @__cancel.style["-webkit-touch-callout"] = "none"
        @__cancel.style["-webkit-user-select"] = "none"
        @__cancel.style["-moz-user-select"] = "none"
        @__cancel.style["-ms-user-select"] = "none"
        @__cancel.style["-khtml-user-select"] = "none"
        @__cancel.style["-o-user-select"] = "none"

        $(@__cancel).unbind("touchstart mousedown")
        $(@__cancel).unbind("touchend mouseup")
        $(@__cancel).on "touchstart mousedown", (event) =>
          @__cancel.style.left = (@cancel_left + 2)+"px"
          @__cancel.style.top = (@cancel_top + 2)+"px"
          @__cancel.style.boxShadow = "0px 0px 0px"
          @__cancel_flag = true
        $(@__cancel).on "touchend mouseup", (event) =>
          if (!@__cancel_flag)
            return
          @close()
        @__cancel.addEventListener 'mouseenter', (event) =>
          @__cancel.style.backgroundColor = CSSRGBA(@tintColor)
          @__cancel.style.color = CSSRGBA(@tintFontColor)
        @__cancel.addEventListener 'mouseleave', (event) =>
          @__cancel.style.left = (@cancel_left)+"px"
          @__cancel.style.top = (@cancel_top)+"px"
          @__cancel.style.boxShadow = "2px 2px 4px rgba(64, 64, 64, 0.6)"
          @__cancel.style.backgroundColor = CSSRGBA(@cancelColor)
          @__cancel.style.color = CSSRGBA(@cancelFontColor)
          @__cancel_flag = false
        body.appendChild(@__cancel)

      body.onkeydown = (event) =>
        switch (event.keyCode)
          when 13 # リターンキー
            @__submit_flag = true
            if (document.createEvent)
              evt = document.createEvent("HTMLEvents")
              evt.initEvent("mouseup", true, true )
              return @submit.dispatchEvent(evt)
            else
              evt = document.createEventObject()
              return @submit.fireEvent("onmouseup", evt)
          when 27 # ESCキー
            @close()

  close:(func = undefined)->
    @__dialog.parentNode.removeChild(@__dialog) if (@__dialog?)
    @__dialog = undefined
    @__title.parentNode.removeChild(@__title) if (@__title?)
    @__title = undefined
    @submit.parentNode.removeChild(@submit) if (@submit?)
    @submit = undefined
    @__cancel.parentNode.removeChild(@__cancel) if (@__cancel?)
    @__cancel = undefined
    @__coverview.animateWithDuration 0.3,
      backgroundColor: FWColor(0, 0, 0, 0.0)
    , =>
      @__coverview.hidden = true
      @self.removeFromSuperview()
      if (func?)
        func()

###
---model_start---
class [classname] extends UIDialogView
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
