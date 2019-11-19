#=============================================================================
#
# DataBase Class
#
#=============================================================================

class FWDataStore extends FWObject
  constructor:(table = undefined)->
    super()
    @table = table

  #=============================================================================
  # データをupsertする
  #=============================================================================
  upsert:(param) ->
    values = if (param? && param.values?) then param.values else undefined
    return new Promise (resolve, reject) =>
      $.ajax
        url: ORIGIN+"/api/upsert"
        type: "POST"
        data: JSON.stringify
          table: @table
          values: values
        contentType: "application/json"
        success: (data) =>
          resolve(data)

  #=============================================================================
  # 検索条件を指定したselect結果を返す
  #=============================================================================
  select:(param) ->
    where = if (param? && param.where?) then param.where else undefined
    return new Promise (resolve, reject) =>
      $.ajax
        url: ORIGIN+"/api/select"
        type: "POST"
        data: JSON.stringify
          table: @table
          where: where
        contentType: "application/json"
        success: (data) =>
          resolve(data.rows)

  #=============================================================================
  # 指定したレコードを削除する
  #=============================================================================
  delete:(param) ->
    where = if (param? && param.where?) then param.where else undefined
    return new Promise (resolve, reject) =>
      $.ajax
        url: ORIGIN+"/api/delete"
        type: "POST"
        data: JSON.stringify
          table: @table
          where: where
        contentType: "application/json"
        success: (data) =>
          resolve(data)

  #=============================================================================
  # 指定したレコードのデータを更新する
  #=============================================================================
  update:(param) ->
    values = if (param? && param.values?) then param.values else undefined
    where = if (param? && param.where?) then param.where else undefined
    return new Promise (resolve, reject) =>
      $.ajax
        url: ORIGIN+"/api/update"
        type: "POST"
        data: JSON.stringify
          table: @table
          values: values
          where: where
        contentType: "application/json"
        success: (data) =>
          resolve(data)

  #=============================================================================
  # AUTO INCREMENTをリセットする
  #=============================================================================
  reset_autoincrement: ->
    return new Promise (resolve, reject) =>
      $.ajax
        url: ORIGIN+"/api/reset_autoincrement"
        type: "POST"
        data: JSON.stringify
          table: @table
        contentType: "application/json"
        success: (data) =>
          resolve(data)

  #=============================================================================
  # keyvalueから値を取り出す
  #=============================================================================
  objectForKey:(param) ->
    return new Promise (resolve, reject) =>
      key = param.key
      $.ajax
        url: ORIGIN+"/api/select"
        type: "POST"
        data: JSON.stringify
          table: "keyvalue"
          where:
            key: key
        contentType: "application/json"
        success: (data) =>
          if (data.rows.length > 0)
            ret =data.rows[0].value
          else
            ret = undefined
          resolve(ret)

  #=============================================================================
  # keyvalueに書き込む
  #=============================================================================
  setObject:(param) ->
    values = param.values
    return new Promise (resolve, reject) =>
      key = values.key
      if (typeof(values.value) == 'object')
        value = JSON.stringify(values.value)
      else
        value = values.value
      $.ajax
        url: ORIGIN+"/api/upsert"
        type: "POST"
        data: JSON.stringify
          table: "keyvalue"
          values:
            key: key
            value: value
        contentType: "application/json"
        success: (data) =>
          resolve(data)

###
---model_start
class [classname] extends FWDataStore
  constructor:(param)->
    super(param)

model_end---
###
