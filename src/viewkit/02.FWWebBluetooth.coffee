#=============================================================================
#
# Web Bluetooth wrap class
#
#=============================================================================

class FWWebBluetooth extends FWObject
  constructor:->
    super()
    if (!window.navigator.bluetooth?)
      alert("This browser is not supported for WebBluetooth.")
    else
      @BLUETOOTH = window.navigator.bluetooth

  activate:(options)->
    if (options.filters?)
      filters = options.filters
    else
      filters = __anyDevice()

    @BLUETOOTH.requestDevice
      filters: filters
    .then (device) =>
      echo "=== device ==="
      echo device
      return device.gatt.connect()
    .then (server) =>
      echo "=== server ==="
      echo server
      if (options.service_uuid?)
        server.getPrimaryService(options.service_uuid)
      else
        server.getPrimaryServices()
    .then (service) =>
      echo "=== service ==="
      echo service
      return service.getCharacteristic(options.characteristic_uuid)
    .then (characteristic) =>
      echo "=== characteristic ==="
      echo characteristic
      echo "notify=[%@]", characteristic.properties.notify
      characteristic.addEventListener 'characteristicvaluechanged', (data) =>
        echo data
      characteristic.startNotifications()
    .catch (error) =>
      echo error

    readBLEdata = (characteristic) =>
      characteristic.readValue().then (value) =>
        echo value
      setTimeout =>
        readBLEdata(characteristic)
      , 1000


  #==========================================================================
  # static method
  #==========================================================================
  __anyDevice = ->
    return Array.from('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ').map (c) ->
      return {namePrefix: c}
    .concat name: ''


###
---model_start
class [classname] extends FWWebBluetooth
  constructor:->
    super()

model_end---
###
