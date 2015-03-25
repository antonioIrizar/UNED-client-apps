class WebSocketCamera
  wsCamera: null
  URLWS: "ws://62.204.201.214:8081"
  wsCameraIsReady: false

  constructor: ->
    @wsCameraIsReady = false
    @wsCamera = new WebSocket @URLWS
    @wsCamera.binaryType = 'arraybuffer'

    @wsCamera.onopen = @onopen
    @wsCamera.onmessage  = @onmessage

    @wsCamera.onclose = @onclose

  onopen: =>
    console.log "ws camera inciado"
    cameraRequest = 
      "method":"getSensorData"
      "accessRole": 'observer'
      "updateFrequency":"1"
      "sensorId":"video"

    jsonRequest = JSON.stringify cameraRequest
    @wsCamera.send jsonRequest

  onmessage: (msg) =>
    arrayBuffer = msg.data
    bytes = new Uint8Array arrayBuffer
    blob = new Blob [bytes.buffer]
    
    image = document.getElementById 'imgCamera'

    reader = new FileReader()
    reader.onload = (e) ->
      image.src = e.target.result

    reader.readAsDataURL blob
    if not @wsCameraIsReady 
      @wsCameraIsReady = true
      eve = document.createEvent 'Event'
      eve.initEvent 'allWsAreReady', true, false
      document.dispatchEvent eve
    ###
    if !wsCameraIsReady
      wsCameraIsReady = true
      if wsIsReady
        myApp.hidePleaseWait()
    ###

  onclose: (code) ->
    console.log "me cierro"
    console.log code

window.WebSocketCamera = WebSocketCamera



