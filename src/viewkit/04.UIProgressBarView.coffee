class UIProgressBarView extends UIView
  constructor:(param)->
    super(param)
    #================================
    # Please describe the initialization process below this.
    #================================
    @preprocess = undefined
    @postprocess = undefined

    @max = 0
    @value = 0

    #================================
    @setObserve(@__style, @)

  viewDidLoad:->
    super()
    @coverview = new UIView(FWRectMake(
      0
      0
      @parent.frame.size.width
      @parent.frame.size.height
    ))
    @coverview.backgroundColor = FWColor(0, 0, 0, 0.8)
    @parent.addSubview(@coverview)

  viewDidAppear:->
    super()

  viewWillDisappear:->
    super()

  setStyle:(param)->
    super(param)

###
---model_start---
class [classname] extends UIProgressBarView
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
