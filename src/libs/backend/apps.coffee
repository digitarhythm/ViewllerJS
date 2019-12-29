#=============================================================================
#
# CreateviewJS - jQuery Framework
#
# 2017 Coded by Hajime Oh-yake
#
#=============================================================================

express = require("express")
app = express()
bodyParser = require('body-parser')
Promise = require("bluebird")
http = require("http").Server(app)
https = require("https")
path = require("path")
config = require("config")
fs = require("fs-extra")
echo = require("ndlog").echo
ECT = require("ect")
async = require("async")
sqlite3 = require("sqlite3").verbose()

pkgjson = require("#{process.cwd()}/package.json")
pkgname = pkgjson.name
node_env = process.env.NODE_ENV

appjson = require("#{process.cwd()}/config/application.json")

model = {}

__viewller = fs.realpathSync("#{process.cwd()}/node_modules/viewller")
__cwd = fs.realpathSync(process.cwd())

app.use(bodyParser.json())
app.use("/#{pkgname}/sysimages", express.static("#{__viewller}/libs/images"))
app.use("/#{pkgname}/sysviews", express.static("#{__viewller}/libs/frontend"))
app.use("/#{pkgname}/sysplugins", express.static("#{__viewller}/libs/plugins"))

if (node_env == "develop")
  __jsdir = "develop"
  __dbpath = "#{__cwd}/apps/develop/database"
else
  __jsdir = "production"
  __dbpath = "#{__cwd}/apps/deploy/database"

schema = require("#{__dbpath}/schema.json")

app.use("/#{pkgname}/plugins", express.static("#{__cwd}/apps/#{__jsdir}/plugins"))
app.use("/#{pkgname}/public", express.static("#{__cwd}/apps/#{__jsdir}/public"))
app.use("/#{pkgname}/library", express.static("#{__cwd}/apps/#{__jsdir}/library"))
app.use("/#{pkgname}/view", express.static("#{__cwd}/apps/#{__jsdir}/js/frontend"))

#============================================================================
# load system module
#============================================================================
global.FWREQUIRE = (module)->
  modulepath = "#{process.cwd()}/node_modules/viewller/libs/backend/#{module}.min"
  mod = require(modulepath)
  return mod

#============================================================================
# decrypt
#============================================================================
__decrypt = (str) ->
  private_path = "#{APPS_DIR}/config/private_key.pem"
  private_key = fs.readFileSync(private_path, "UTF-8")
  key = new NodeRSA(private_key, 'pkcs1-private-pem')
  decrypt_str = key.decrypt(str, 'utf8')
  return decrypt_str

#============================================================================
# directory check
#============================================================================
__isDir = (filepath) ->
  return fs.existsSync(filepath) && fs.statSync(filepath).isDirectory()

#==========================================================================
# rendering ect template
#==========================================================================
__rendering_page = (res, viewpath, page) ->
  app.set("views", viewpath)
  ectRenderer = ECT({ watch: true, root: viewpath, ext : ".ect" })
  app.engine("ect", ectRenderer.render)
  app.set("view engine", "ect")

  res.render page,
    syspluginlist: syspluginlist
    pluginlist: pluginlist
    cdnlist: cdnlist
    sourcefilelist: sourcefilelist
    stylesheet: stylesheet
    node_env:node_env
    pkgname: pkgname

#==========================================================================
# database setup
#==========================================================================
setupDatabase = ->
  return new Promise (resolve, reject) =>
    # DB設定からテーブル名一覧を配列で取得
    SCHEMA = schema
    column_names = Object.keys(SCHEMA)
    async.whilst =>
      if (!column_names? || column_names.length == 0)
        return false
      else
        return true
    , (callback) =>
      # テーブル名をひとつ取り出す
      tb = column_names.shift()
      # Sqlite3から指定したテーブルSchemaを取得する
      model['dbmodel']._get_table_schema(tb).then (ret) =>
        if (ret.length == 0)
          # 返値が空の場合はCREATE TABLEされていないのでテーブルを生成する
          model['dbmodel']._create_table(tb)
        else
          # テーブル設定が返ってきた場合は設定ファイルの内容との差異を確認する
          columns = ret[0].sql.match(/\((.*?)\)/)[1].split(/,\s*/)

          # カラムの差異をチェックする
          for key, val of SCHEMA[tb]
            flag = false
            columns.forEach (m) ->
              if (!m.match(/^_id/))
                m2 = m.split(/ /)[0]
                if (key == m2)
                  flag = true
            if (!flag)
              model['dbmodel']._add_column(tb, key, val)
      .catch (err) =>
        reject(-1)
      callback(null, 0)
    , (err, result) =>
      resolve(0)

#==========================================================================
# make directory file list
#==========================================================================
readFileList = (path) ->
  return new Promise (resolve, reject) ->
    filelists = []
    fs.readdir path, (err, lists) ->
      # ディレクトリ内にディレクトリがあったら再帰する
      async.whilst =>
        if (!lists? || lists.length == 0)
          return false
        else
          return true
      , (callback) =>
        # ファイル／ディレクトリ名をひとつ取り出す
        p = lists.shift()
        fullpath = "#{path}/#{p}"
        if (__isDir(fullpath)) # ディレクトリだった
          if (p.match(/^\..*/)) # ドットで始まっていたら処理しない
            callback(null, 0)
          else
            readFileList(fullpath).then (ret) ->
              Array.prototype.push.apply(filelists, ret)
              callback(null, 0)
        else
          if (p.match(/^\..*/)) # ドットで始まっていたら処理しない
            callback(null, 0)
          else
            filelists.push(p)
            callback(null, 0)
      , (err, result) =>
        if (err)
          reject(err)
        else
          resolve(filelists)

#==========================================================================
# application source file listing
#==========================================================================
syspluginlist = []
pluginlist = []
stylesheet = []
sourcefilelist = []
cdnlist = []

# システムAPI読み込み
api = require("./api.min")
app.use("/#{pkgname}/api", api)

# システムモジュール読み込み
readFileList("#{__viewller}/libs/backend").then (lists) ->
  for fname in lists
    if (fname.match(/^.*\.js$/) && !fname.match(/^\./))
      apiorg = path.basename(fname).replace(/\.min\.js/, "")
      model[apiorg] = require("#{__viewller}/libs/backend/#{apiorg}.min")
  return 1

# ユーザーAPI読み込み
.then (ret) ->
  readFileList("#{__cwd}/apps/#{__jsdir}/js/backend").then (lists) ->
    for fname in lists
      if (fname.match(/^.*\.js$/) && !fname.match(/^\./) && !fname.match(/^apps/))
        apiorg = path.basename(fname).match(/(.*?)\./, "$1")[1]
        try
          apifname = "#{__cwd}/apps/#{__jsdir}/js/backend/#{apiorg}"
          model[apiorg] = require(apifname)
          app.use("/#{pkgname}/api/#{apiorg}", model[apiorg])
        #catch e
        #  console.log e
    return 1
.then ->
  # DBセットアップ
  setupDatabase()

#============================================================================
# コードハイライトCSS読み込み
#============================================================================
style = appjson.style || {highlight: "darcula"}
stylesheet = ["sysplugins/.highlight_style/#{style.highlight}.css"]

#============================================================================
# ルートページレンダリング
#============================================================================
app.get "/", (req, res) ->
  # システムCSSファイル読み込み
  readFileList("#{__viewller}/libs/plugins").then (lists) ->
    stylesheet = []
    for fname in lists
      if (fname.match(/^.*\.css$/) && !fname.match(/^\./))
        stylesheet.push("sysplugins/#{fname}")
    return 1

  # ユーザーCSS読み込み
  .then (ret) ->
    readFileList("#{__cwd}/apps/#{__jsdir}/plugins").then (lists) ->
      for fname in lists
        if (fname.match(/^.*\.css$/) && !fname.match(/^\./))
          stylesheet.push("plugins/#{fname}")
      return 1

  # システムプラグイン読み込み
  .then (ret) ->
    readFileList("#{__viewller}/libs/plugins").then (lists) ->
      syspluginlist = []
      for fname in lists
        if (fname.match(/^[^_].*\.js$/) && !fname.match(/^\./))
          syspluginlist.push("sysplugins/#{fname}")
      return 1

  # ユーザープラグイン読み込み
  .then (ret) ->
    readFileList("#{__cwd}/apps/#{__jsdir}/plugins").then (lists) ->
      pluginlist = []
      for fname in lists
        if (fname.match(/.*\.js$/) && !fname.match(/^\./))
          pluginlist.push("plugins/#{fname}")
      return 1

  # CDN読み込み
  .then (ret) ->
    cdn = require("#{__cwd}/apps/config/cdn.json")
    cdnlist = []
    for uri in cdn
      cdnlist.push(cdn)
    return 1

  # ビューコード読み込み
  .then (ret) ->
    readFileList("#{__cwd}/apps/#{__jsdir}/js/frontend").then (lists) ->
      sourcefilelist = []
      for fname in lists
        if (fname.match(/^.*\.js$/) && !fname.match(/^\./))
          sourcefilelist.push("view/#{fname}")
      return 1

  .then ->
    if (node_env == "develop")
      viewpath = path.join(__viewller, "/template")
      page = "main"
      __rendering_page(res, viewpath, page)
    else
      systemdb_path = "#{__dbpath}/#{config.database.dbfile}"
      sql = "SELECT value FROM _syspref WHERE key='sorrymode';"
      SYSTEMDB = new sqlite3.Database(systemdb_path)
      SYSTEMDB.all sql, [], (err, rows) ->
        if (rows.length == 0)
          sorry = 1
        else
          sorry = rows[0].value

        if (sorry == 0)
          viewpath = path.join(__viewller, "/template")
          page = "main"
        else if (sorry == 1)
          viewpath = path.join(__cwd, "/apps/src/template")
          page = "sorrymode"

        __rendering_page(res, viewpath, page)


#============================================================================
# アプリケーションサーバー起動
#============================================================================
if (config.network? && config.network.port?)
  port = config.network.port
else
  port = if (node_env == "develop") then 5001 else 5000

switch (config.network.protocol)
  when "http"
    http.listen port, ->
      console.log("===> Develop listening on *:", port)
  when "https"
    options =
      key: fs.readFileSync(config.network.ssl_key)
      cert: fs.readFileSync(config.network.ssl_cert)
    server = https.createServer(options, app)
    server.listen(port)
    console.log("===> Develop listening on *:", port)

