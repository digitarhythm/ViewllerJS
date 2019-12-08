Promise = require("bluebird")
config = require("config")
sqlite3 = require("sqlite3").verbose()
fs = require("fs-extra")
ndlog = require("ndlog")
echo = ndlog.echo
sprintf = ndlog.form

__apps = fs.realpathSync(process.cwd())

class dbmodel
  constructor:->
    node_env = process.env.NODE_ENV
    if (node_env == "develop")
      __jsdir = "develop"
      dbpath = "#{__apps}/apps/develop/database"
    else
      __jsdir = "production"
      dbpath = "#{__apps}/apps/deploy/database"

    @SCHEMA = require("#{dbpath}/schema.json")
    @DB = new sqlite3.Database("#{dbpath}/#{config.database.dbfile}")

#============================================================================
# public method
#============================================================================

  #==========================================================================
  # 検索条件のデータがあれば更新し、無ければデータを挿入する
  # dbmanage.upsert
  #   table: テーブル名
  #   values: {
  #     カラム名: "データ"
  #           ・
  #           ・
  #==========================================================================
  upsert:(param) ->
    return new Promise (resolve, reject) =>
      table = param.table || undefined
      insert_data = param.values || undefined

      if (!table? || !insert_data?)
        reject(-1)

      arr = []
      column_arr = []
      for c, v of insert_data
        column_arr.push(c)
        arr.push(v)
      column_arr_str = column_arr.join(",")
      values_arr_str = ((new Array(Object.keys(insert_data).length)).fill('?')).join(",")

      sql = "REPLACE INTO #{table} (#{column_arr_str}) VALUES (#{values_arr_str})"

      @DB.all sql, arr, (err, res) =>
        if (err?)
          reject(err)
        else
          resolve(0)

  #==========================================================================
  # データ削除
  #==========================================================================
  delete:(param) ->
    return new Promise (resolve, reject) =>
      table = param.table || undefined
      where = param.where || undefined

      arr = []
      column_arr = []
      if (!where?)
        sql = "DELETE FROM #{table}"
      else
        for c, v of where
          column_arr.push("#{c} like ?")
          arr.push(v)
        where_str = column_arr.join(" AND ")
        sql = "DELETE FROM #{table} WHERE #{where_str}"

      @DB.all sql, arr, (err, rows) =>
        if (err)
          reject(err)
        else
          resolve(rows)


  #==========================================================================
  # データ検索
  #==========================================================================
  select:(param) ->
    return new Promise (resolve, reject) =>
      table = param.table || undefined
      where = param.where || undefined

      arr = []
      where_arr = []
      orderby = undefined
      sort = undefined
      limit = undefined
      sql = "SELECT * FROM #{table}"
      if (where?)
        for c, v of where
          if (c == "order_by")
            orderby = " ORDER BY #{v}"
          else if (c == "sort")
            if (v == "asc")
              sort = "ASC"
            else if (v == "desc")
              sort = "DESC"
          else if (c == "limit")
            limit = v
          else
            where_arr.push("#{c} LIKE ?")
            arr.push(v)

        if (where_arr.length > 0)
          values_str = where_arr.join(" AND ")
          sql = "SELECT * FROM #{table} WHERE #{values_str}"

      if (orderby?)
        sql += orderby
        #arr.push(orderby)
        if (sort?)
          sql += " #{sort}"

      if (limit?)
        sql += (" limit "+parseInt(limit))

      @DB.all sql, arr, (err, rows) =>
        if (err)
          reject(err)
        else
          resolve(rows)

  #==========================================================================
  # 検索条件のデータを更新する
  # dbmanage.update
  #   table: テーブル名
  #   values: {
  #     カラム名: "データ"
  #           ・
  #           ・
  #   where: {
  #     カラム名: "データ"
  #           ・
  #           ・
  #==========================================================================
  update:(param) ->
    return new Promise (resolve, reject) =>
      table = param.table || undefined
      insert_data = param.values || undefined
      where = param.where || undefined

      if (!table? || !insert_data?)
        return -1

      arr = []
      values_arr = []
      for c, v of insert_data
        values_arr.push("#{c}=?")
        arr.push(v)
      values_arr_str = values_arr.join(",")

      where_arr = []
      if (where?)
        for c, v of where
          where_arr.push("#{c} LIKE ?")
          arr.push(v)

        if (where_arr.length > 0)
          where_str = where_arr.join(" AND ")

      sql = "UPDATE #{table} SET #{values_arr}"
      if (where?)
        sql += " WHERE #{where_str}"

      @DB.all sql, arr, (err, res) =>
        if (err?)
          reject(err)
        else
          resolve(0)

  #==========================================================================
  # reset auto increment
  #==========================================================================
  reset_autoincrement:(param) ->
    return new Promise (resolve, reject) =>
      table = param.table || undefined
      sql = "delete from sqlite_sequence where name=?"
      @DB.all sql, [table], (err, res) =>
        if (err?)
          reject(err)
        else
          resolve(0)

  #==========================================================================
  # keyvalue accesor - getter
  #==========================================================================
  objectForKey:(param) ->
    return new Promise (resolve, reject) =>
      table = "keyvalue"
      key = param.key
      sql = "select * from #{table} where key=?"
      @DB.all sql, [key], (err, res) =>
        if (err?)
          reject(err)
        else
          if (res.length > 0)
            resolve(res[0].value)
          else
            resolve(undefined)

  #==========================================================================
  # keyvalue accesor - setter
  #==========================================================================
  setObject:(param) ->
    return new Promise (resolve, reject) =>
      table = "keyvalue"
      key = (Object.keys(param.values))[0]
      value = param.values[key]

      if (!table? || !key?)
        reject(-1)
      sql = "UPDATE #{table} SET value=? WHERE key=?"

      @DB.all sql, [value, key], (err, res) =>
        if (err?)
          reject(err)
        else
          resolve(0)

  #==========================================================================
  # exec SQL
  #==========================================================================
  _exec_sql:(sql, data) ->
    return new Promise (resolve, reject) =>
      @DB.all sql, data, (err, res) =>
        if (err?)
          reject(err)
        else
          resolve(res)

#============================================================================
# Private method
#============================================================================

  #==========================================================================
  # add column
  #==========================================================================
  _add_column:(table, name, type) ->
    sql = "ALTER TABLE #{table} ADD #{name} #{type};"
    try
      @DB.run(sql)
      return  0
    catch e
      return -1

  #==========================================================================
  # get table schema
  #==========================================================================
  _get_table_schema:(table)->
    return new Promise (resolve, reject) =>
      if (table == "_all_")
        sql = "SELECT * FROM sqlite_master WHERE type='table'"
        arr = []
      else
        sql = "SELECT * FROM sqlite_master WHERE type='table' AND name=?"
        arr = [table]

      @DB.all sql, arr, (err, res) =>
        if (err?)
          reject(err)
        else
          resolve(res)

  #==========================================================================
  # create table
  #==========================================================================
  _create_table:(table) ->
    schema = @SCHEMA[table]
    return new Promise (resolve, reject) =>
      if (schema == "" || !schema?)
        reject(0)
      else
        column = []
        for key, val of schema
          column.push("#{key} #{val}")
        columnstr = column.join(",")
        sql = "CREATE TABLE IF NOT EXISTS #{table} (_id INTEGER PRIMARY KEY AUTOINCREMENT,#{columnstr});"
        try
          @DB.run(sql)
          resolve(0)
        catch e
          reject(e)

  #==========================================================================
  # drop table
  #==========================================================================
  _drop_table:(table) ->
    return new Promise (resolve, reject) =>
      sql = "DROP TABLE #{table};"
      err = @DB.run(sqlstr)
      resolve(err)

module.exports = new dbmodel()

###
---model_start---
class [classname] extends dbmodel
  constructor:->
    super()
    #================================
    # Please describe the initialization process below this.
    #================================



---require_method---
---model_end---
###
