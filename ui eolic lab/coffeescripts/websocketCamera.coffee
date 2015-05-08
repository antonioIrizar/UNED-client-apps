class WebSocketCamera
  wsCamera: null
  URLWS: "ws://62.204.201.218:8082"
  wsCameraIsReady: false
  token: null

  constructor: (@token) ->
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
      'authToken': @token.toString()
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
      #fix warning in chrome. Need say it is a image
      image.src = e.target.result[0..4] + "image/jpg" + e.target.result[5..]

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



