#=============================================================================
#
# WebSocket Library Class
#
#=============================================================================

class FWWebSocket extends FWObject
  constructor:(param = undefined)->
    super()
    @address = undefined

    @delegate = @

    @connect(param)

    @active = false
    @sock = undefined

  #==========================================================================
  # 接続情報登録
  #==========================================================================
  connect:(param)->
    if (!param?)
      return false
    @address = param.address || undefined
    return true

  #==========================================================================
  # 通信開始
  #==========================================================================
  start: ->
    if (!@address?)
      echo "address is undefined"
      return

    # ソケット作成
    if (@address? && !@sock?)
      @sock = new WebSocket('ws://'+@address)

    # 接続
    @sock.addEventListener 'open', (e) =>
      @active = true
      @delegate.websocket_connect() if (typeof(@delegate.websocket_connect) == "function")

    # 切断
    @sock.addEventListener 'close', (e) =>
      @active = false
      @delegate.websocket_close() if (typeof(@delegate.websocket_close) == "function")

    # エラー
    @sock.addEventListener 'error', (e) =>
      @active = false
      @delegate.websocket_error() if (typeof(@delegate.websocket_error) == "function")

    # ソケットからデータ受信
    @sock.addEventListener 'message', (e) =>
      readdata = e.data
      @delegate.websocket_receive(readdata) if (typeof(@delegate.websocket_receive) == "function" && readdata != "Connected")

  #==========================================================================
  # 通信終了
  #==========================================================================
  end: ->
    @sock.close() if (@sock?)
    @sock = undefined
    @active = false

###
---model_start
class [classname] extends FWWebSocket
  constructor:(param)->
    super(param)


  websocket_connect:->

  websocket_close:->

  websocket_error:->

  websocket_receive:(data)->
model_end---
###
