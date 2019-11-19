express = require("express")
router = express.Router()
bodyParser = require('body-parser')
fs = require("fs-extra")
multer = require("multer")
nodemailer = require("nodemailer")
echo = require("ndlog").echo
database = require("./dbmodel.min")

node_env = process.env.NODE_ENV
if (node_env == "develop")
  __jsdir = "develop"
else
  __jsdir = "production"

cwd = fs.realpathSync(process.cwd())
upload = multer({dest: "#{cwd}/apps/#{__jsdir}/public"})

#==========================================================================
#==========================================================================
#==========================================================================
#
# tools API
#
#==========================================================================
#==========================================================================
#==========================================================================

#==========================================================================
# send mail
#==========================================================================
router.post '/sendmail', (req, res)->
  from = req.body.from || "postmaster"
  to = req.body.to || undefined
  subject = req.body.subject || "no subject"
  message = req.body.message || "no message"

  if (!to?)
    res.json
      err: -1

  transporter = nodemailer.createTransport
    host: 'localhost'
    port: 25
    use_authentication: false
    tls:
      rejectUnauthorized: false

  mailOptions =
    from: from
    to: to
    subject: subject
    text: message

  transporter.sendMail mailOptions, (error, info)->
    if (error)
      console.log(error)
      process.exit(1)
    else
      console.log('Message sent: '+info.response)
      res.json
        err: 0

#==========================================================================
#==========================================================================
#==========================================================================
#
# File API
#
#==========================================================================
#==========================================================================
#==========================================================================

#==========================================================================
# file/directory copy
#==========================================================================
router.post '/copy', (req, res)->
  # file/directory copy
  return new Promise (resolve, reject)->
    fs.copy path, (err)->
      if (err)
        reject(err)
      else
        resolve(true)

#==========================================================================
# create directory
#==========================================================================
router.post '/mkdir', (req, res)->
  # create directory
  return new Promise (resolve, reject)->
    fs.mkdirs path, (err)->
      if (err)
        reject(err)
      else
        resolve(true)

#==========================================================================
# file list
#==========================================================================
router.post '/filelist', (req, res)->
  # directory file list
  readFileList = (path)->
    return new Promise (resolve, reject)->
      fs.readdir path, (err, lists)->
        if (err)
          reject(err)
        else
          resolve(lists)

	# application source file listing
  dir = req.headers.path || ""
  path = "#{cwd}/apps/#{__jsdir}/public/#{dir}"
  readFileList(path).then (filelist)->
    res.json(filelist)
  .catch (err)->
    console.error(err)
    process.exit(1)

#==========================================================================
# file upload
#==========================================================================
router.post '/file_upload', upload.any(), (req, res)->
  dir = if (req.headers.dir != "") then req.headers.dir+"/" else ""
  try
    filelist = []
    req.files.map (d) =>
      src = "#{d.path}"
      dst = "#{d.destination}/#{dir}#{d.originalname}"
      fs.moveSync(src, dst, { overwrite: true })
      filelist.push(dst)
    res.json
      err: 0
      files: filelist
  catch e
    res.json
      err: -1

#==========================================================================
# file unlink
#==========================================================================
router.post '/file_unlink', (req, res)->
  file = req.headers.path
  if (file?)
    path = "#{cwd}/apps/#{__jsdir}/public/#{file}"
    try
      fs.removeSync(path)
      res.json
        file: path
        err: 0
    catch e
      res.json
        err: -1
  else
    res.json
      file: ''
      err: -2


#==========================================================================
#==========================================================================
#==========================================================================
#
# DB API
#
#==========================================================================
#==========================================================================
#==========================================================================

#==========================================================================
# upsert
#==========================================================================
router.post '/upsert', (req, res, next)->
  param = req.body
  table = param.table || undefined
  values = param.values || undefined

  database.upsert
    table: table
    values: values
  .then (ret)->
    res.json
      err: ret
  .catch (err) =>
    res.json
      err: err

#==========================================================================
# select
#==========================================================================
router.post '/select', (req, res, next)->
  param = req.body
  table = param.table || undefined
  where = param.where || undefined
  database.select
    table: table
    where: where
  .then (ret)->
    res.json
      rows: ret
      err: 0
  .catch (err) =>
    res.json
      err: err

#==========================================================================
# delete
#==========================================================================
router.post '/delete', (req, res, next)->
  param = req.body
  table = param.table || undefined
  where = param.where || undefined
  database.delete
    table: table
    where: where
  .then (ret)->
    res.json
      rows: ret
      err: 0
  .catch (err) =>
    res.json
      err: err

#==========================================================================
# update
#==========================================================================
router.post '/update', (req, res, next)->
  param = req.body
  table = param.table || undefined
  values = param.values || undefined
  where = param.where || undefined

  database.update
    table: table
    values: values
    where: where
  .then (ret)->
    res.json
      err: ret
  .catch (err)=>
    res.json
      err: err

#==========================================================================
# reset auto increment
#==========================================================================
router.post '/reset_autoincrement', (req, res, next)->
  param = req.body
  table = param.table || undefined

  database.reset_autoincrement
    table: table
  .then (ret)->
    res.json
      err: ret
  .catch (err)=>
    res.json
      err: err

#==========================================================================
module.exports = router

