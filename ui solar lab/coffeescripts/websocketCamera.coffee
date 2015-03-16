class WebSocketCamera
  wsCamera: null
  URLWS: "ws://62.204.201.214:8081"

  constructor: ->
    wsCameraIsReady = false
    @wsCamera = new WebSocket @URLWS
    @wsCamera.binaryType = 'arraybuffer'

    @wsCamera.onopen = @onopen
    @wsCamera.onmessage  = @onmessage

    @wsCamera.onclose = @onclose

  onopen: =>
    console.log "ws camera inciado"
    jsonRequest = JSON.stringify {"method":"getSensorData", "accessRole": 'observer',  "updateFrequency":"1", "sensorId":"video"}
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
    if !wsCameraIsReady
      wsCameraIsReady = true
      if wsIsReady
        myApp.hidePleaseWait()
   
  onclose: (code) ->
    console.log code

window.WebSocketCamera = WebSocketCamera



