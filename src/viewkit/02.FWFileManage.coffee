#=============================================================================
#
# File Manage Class
#
#=============================================================================

class FWFileManage extends FWObject
  constructor:->
    super()
    @func = undefined

  #==========================================================================
  # createDirectory
  #==========================================================================
  mkdir:(path, func)->
    $.ajax
      url: "#{ORIGIN}/api/create_directory"
      type: "post"
      processData: false
      contentType: false
      headers: {
        path: path
      }
    .done (res, status, xhr)=>
      func(res) if (typeof(func) == 'function')

  #==========================================================================
  # File unlink
  #==========================================================================
  unlink:(path, func)->
    $.ajax
      url: "#{ORIGIN}/api/file_unlink"
      type: "post"
      processData: false
      contentType: false
      headers: {
        path: path
      }
    .done (res, status, xhr)=>
      func(res) if (typeof(func) == 'function')

  #==========================================================================
  # get file lists
  #==========================================================================
  filelist:(path, func)->
    $.ajax
      url: "#{ORIGIN}/api/filelist"
      type: "post"
      processData: false
      contentType: false
      headers: {
        path: path
      }
    .done (res, status, xhr)=>
      func(res) if (typeof(func) == 'function')



###
---model_start
class [classname] extends FWFileManage
  constructor:->
    super()

model_end---
###
