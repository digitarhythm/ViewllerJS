#=============================================================================
#
# Super Super Class
#
#=============================================================================

class FWObject
  constructor:->
    @UniqueID = FWApplication.UniqueID()
    @self = @
    @origin = location.origin

###
---model_start
class [classname] extends FWObject
  constructor:->
    super()

model_end---
###
