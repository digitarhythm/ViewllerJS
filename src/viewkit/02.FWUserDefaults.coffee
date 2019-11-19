#=============================================================================
#
# UserDefault Class
#
#=============================================================================

class FWUserDefaults extends FWObject
  constructor:->
    super()
    if (window.localStorage != null)
      @localstorage = window.localStorage
    else if (localStorage != null)
      @localstorage = localStorage
    else
      @localstorage = undefined

  setObject:(value, key)->
    if (!@localstorage?)
      return undefined
    valuetmp = @localstorage.getItem("userdefaults")
    if (valuetmp == null)
      valuelist = {}
    else
      valuelist = JSON.parse(valuetmp)
    if (typeof(value) == 'object')
      value2 = JSON.stringify(value)
    else
      value2 = value
    valuelist[key] = value2
    @localstorage.setItem("userdefaults", JSON.stringify(valuelist))

  objectForKey:(key)->
    if (!@localstorage?)
      return undefined
    valuetmp = @localstorage.getItem("userdefaults")
    if (valuetmp == null)
      valuelist = {}
    else
      valuelist = JSON.parse(valuetmp)
    value = valuelist[key] || undefined
    try
      value2 = JSON.parse(value)
    catch e
      value2 = value
    return value2

  removeForKey:(key)->
    if (!@localstorage?)
      return undefined
    valuetmp = @localstorage.getItem("userdefaults")
    if (valuetmp == null)
      return
    else
      valuelist = JSON.parse(valuetmp)
    try
      delete valuelist[key]
    @localstorage.setItem("userdefaults", JSON.stringify(valuelist))

