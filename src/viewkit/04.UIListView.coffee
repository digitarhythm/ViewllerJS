#============================================================================
# UIListView - list data display class
#============================================================================

class UIListView extends UIView
  constructor:(param)->
    super(param)
    # set style parameter
    @rootview = GLOBAL['rootview']

    @backgroundColor = FWColor(240, 240, 240, 1.0)
    @clipToBounds = true
    @scrolling = true
    @borderWidth = 0.0
    @borderColor = FWColor(0, 0, 0, 0.4)

    # public member
    @delegate = @self
    @highlight = {backgroundColor: FWColor(  0, 127, 255, 0.8), font: {color: FWColor(0, 0, 0, 0.8), size: 12}}
    @normal =    {backgroundColor: FWColor(255, 255, 255, 0.8), font: {color: FWColor(0, 0, 0, 0.8), size: 12}}
    @select =    {backgroundColor: FWColor(100, 200, 100, 0.8), font: {color: FWColor(0, 0, 0, 0.8), size: 12}}
    @withIdentifier = @UniqueID

    # add style parameter
    @__style.selectedIndex = undefined
    @__style.rowHeight = 48.0
    @__style.selectable = true
    @__style.scrollbarsize = 18

    # private member
    @__datanum = 0
    @__cellViewList = []
    @__action - undefined
    @__parentelement = @viewelement

    @setObserve(@__style, @)

  #============================================================================
  # private method
  #============================================================================

  setStyle:(key)->
    super(key)
    @viewelement.style.overflowX = "hidden"
    @viewelement.style.overflowY = "auto"
    @__highlightColumn(@selectedIndex) if (@selectedIndex?)

  #============================================================================
  # public method
  #============================================================================

  #==========================================================================
  #==========================================================================
  viewDidLoad:->
    super()
    if (@scrollbar)
      @__viewdiff = @scrollbarsize
    else
      @__viewdiff = 2

    # This is a view to correct the size of the scroll bar.
    @__baseview = new UIWindow(FWRectMake(
      0
      0
      @frame.size.width
      @frame.size.height
    ))
    @__baseview.backgroundColor = FWColor(0, 0, 0, 0)
    @addSubview(@__baseview)

    @addTapGesture =>
      @__selectColumn(-1)
      @selectedIndex = undefined
      @delegate.cancelClick() if (@delegate? && typeof(@delegate.cancelClick) == 'function')
    @reloadData()

  #==========================================================================
  #==========================================================================
  viewDidAppear:->
    super()

  #==========================================================================
  #==========================================================================
  viewWillDisappear:->
    super()
    for obj in @__cellViewList
      obj.removeFromSuperview() if (obj?)
    @__cellViewList = []

  #==========================================================================
  #==========================================================================
  didBrowserResize:->
    super(FWApplication.getBounds())

  #==========================================================================
  # display list view
  #==========================================================================
  reloadData:->
    @__datanum = if (typeof(@delegate.numberOfRowsInSection) == 'function') then @delegate.numberOfRowsInSection(@withIdentifier) else 0

    if (@__baseview?)
      @__baseview.frame.size.height = @__datanum * @rowHeight

    #-------------------------------------------------------------------------
    # すでにあるセルを削除する
    #-------------------------------------------------------------------------
    for obj in @__cellViewList
      obj.removeFromSuperview() if (obj?)
    @__cellViewList = []

    # 表示出来るセルの数
    @__dispnum = Math.ceil(@frame.size.height / @rowHeight) + 1
    if (@__dispnum >= @__datanum)
      @__dispnum = @__datanum
      # 生成するセルビューの数
      @__cellmax = @__dispnum
    else
      # 生成するセルビューの数
      @__cellmax = @__dispnum + 2

    # 必要な数のセルビューを生成する
    for idx in [0...@__cellmax]
      if (idx == @__datanum)
        break
      if (typeof(@delegate.cellForRowAtIndexPath) == 'function')
        cell = @delegate.cellForRowAtIndexPath(idx, @withIdentifier)
      else
        cell = @dequeueReusableCell()
        cell.verticalAlign = "UITextVerticalAlignmentMiddle"

      cell.__index = idx
      cell.hidden = true

    # 表示されている先頭のデータ配列番号
    @__dispstart = 0
    # 表示されている最後のデータ配列番号
    @__dispend = Math.ceil((@frame.size.height) / @rowHeight)

    #-------------------------------------------------------------------------
    # リストを表示する
    #-------------------------------------------------------------------------
    # セルビューを表示する
    for idx in [0...@__dispnum]
      if (idx == @__datanum)
        break
      cell = @__cellViewList[idx]
      cell.frame.origin.y = idx * @rowHeight
      cell.hidden = false
      if (@selectedIndex? && @selectedIndex == idx)
        @__setCell(cell, "select")
      else
        @__setCell(cell, "normal")

    #-------------------------------------------------------------------------
    # スクロールした時の処理
    #-------------------------------------------------------------------------
    @__parentelement.addEventListener "scroll", =>
      scrolltop = @__parentelement.scrollTop
      scrollbottom = scrolltop + @frame.size.height - (@margin * 2)
      dispstart = Math.floor(scrolltop / @rowHeight)
      dispstart -= (1 * (dispstart > 0))
      dispend = Math.ceil(scrollbottom / @rowHeight)
      if (dispend >= @__datanum)
        dispend = @__datanum - 1

      cellstart = dispstart % @__cellmax
      cellend = dispend % @__cellmax

      #-----------------------------------------------------------------------
      # 表示範囲に変更があった場合に、全てを更新する
      #-----------------------------------------------------------------------
      # 生成したcellの数だけ廻す
      # cellViewList: 表示用に必要数だけ生成したcell配列
      # dispdata    : 表示するデータ配列の要素番号（0〜データの要素数）
      # dispstart   : 表示するデータの開始要素番号
      # dispend     : 表示するデータの終了要素番号
      # newcell     : 画面表示用cellViewListの要素番号（0〜表示に使用する数）
      # cellstart   : 表示に使うcellviewの先頭配列要素番号
      # cellend     : 表示に使うcellviewの終了配列要素番号
      for i in [0...@__cellViewList.length]
        dispdata = dispstart + i # 表示するデータ配列の要素番号（0〜データの要素数）
        @__newcell = dispdata % @__cellmax # 画面表示用cellViewListの要素番号（0〜表示に使用する数）
        if (
          cellstart <= cellend   && (cellstart  <= @__newcell && @__newcell <= cellend) ||
          cellend   <  cellstart && (@__newcell <= cellend    || cellstart <= @__newcell)
        )
          if (@__cellViewList[@__newcell].__index != dispdata || @__cellViewList[@__newcell].hidden)
            if (typeof(@delegate.cellForRowAtIndexPath) == 'function')
              cell = @delegate.cellForRowAtIndexPath(dispdata, @withIdentifier)
            else
              cell = @dequeueReusableCell()

            cell.hidden = false

            if (@selectedIndex == dispdata)
              @__setCell(cell, "select")
            else
              @__setCell(cell, "normal")

            cell.frame.origin.y = dispdata * @rowHeight
            cell.__index = dispdata
        else
          cell = @__cellViewList[@__newcell]
          cell.hidden = true if (cell?)

  #==========================================================================
  # view create with reusable
  #==========================================================================
  dequeueReusableCell:(view = undefined) ->
    if (@__cellViewList.length < @__cellmax)
      if (!view?)
        cell = new UITextView(FWRectMake(
          0
          0
          @frame.size.width - @__viewdiff - (@margin * 2)
          @rowHeight
        ))
        cell.borderWidth = 1.0
        cell.verticalAlign = "UITextVerticalAlignmentMiddle"
        cell.borderColor = FWColor(200, 200, 200, 0.4)
      else
        cell = new view(FWRectMake(
          0
          0
          @frame.size.width - @__viewdiff - (@margin * 2)
          @rowHeight
        ))
      cell.scrolling = true
      @__setCell(cell, "normal")
      @addSubview(cell)
      @__cellViewList.push(cell)
      elm = cell.viewelement || cell.__element
      elm.addEventListener "mouseover", =>
        @__setCell(cell, "highlight")
      elm.addEventListener "mouseleave", =>
        if (cell.__index == @selectedIndex)
          @__setCell(cell, "select")
        else
          @__setCell(cell, "normal")
      cell.addTapGesture (e, pos, self) =>
        @__selectColumn(cell.__index)
    else
      cell = @__cellViewList[@__newcell]

    return cell

  #==========================================================================
  #==========================================================================
  __setCell:(cell, mode)->
    if (@selectable)
      switch mode
        when "normal"
          cell.backgroundColor = @normal.backgroundColor
          cell.font.color = @normal.font.color if (cell.font?)
          cell.font.size = @normal.font.size if (cell.font?)
        when "select"
          cell.backgroundColor = @select.backgroundColor
          cell.font.color = @select.font.color if (cell.font?)
          cell.font.size = @select.font.size if (cell.font?)
        when "highlight"
          cell.backgroundColor = @highlight.backgroundColor
          cell.font.color = @highlight.font.color if (cell.font?)
          cell.font.size = @highlight.font.size if (cell.font?)
    else
      cell.backgroundColor = @normal.backgroundColor
      cell.font.color = @normal.font.color if (cell.font?)
      cell.font.size = @normal.font.size if (cell.font?)

  #==========================================================================
  # highlight cell column
  #==========================================================================
  __highlightColumn:(num)->
    if (@selectedIndex?)
      cellnum = @selectedIndex % @__cellmax
      oldtarget = @__cellViewList[cellnum]
      if (oldtarget?)
        @__setCell(oldtarget, "normal")

    if (num?)
      scrolltop = @__parentelement.scrollTop
      scrollbottom = scrolltop + @frame.size.height - (@margin * 2)
      start = Math.floor(scrolltop / @rowHeight)
      start -= (1 * (start > 0))
      end = Math.ceil(scrollbottom / @rowHeight)
      if (end >= @__datanum)
        end = @__datanum - 1

      if (num >= 0)
        @selectedIndex = num
        if (start <= num && num <= end)
          cellnum = num % @__cellmax
          newtarget = @__cellViewList[cellnum]
          if (@selectable && newtarget?)
            @__setCell(newtarget, "select")

  #==========================================================================
  # select cell column
  #==========================================================================
  __selectColumn:(num)->
    @__highlightColumn(num)
    if (@delegate? && @userInteractionEnabled && typeof(@delegate.didSelectRowAtIndexPath) == 'function')
      @delegate.didSelectRowAtIndexPath(@selectedIndex, @withIdentifier)

###
---model_start---
class [classname] extends UIListView
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
  #didSelectRowAtIndexPath:(index, withIdentifier)->

  #==================================
  #==================================
  #cellForRowAtIndexPath:(index, withIdentifier)->
  #   cell = @dequeueReusableCell()
  #   return cell
---model_end---
###
