class WebsocketData
    wsData: null
    URLWS: "ws://62.204.201.214:8081"
    firstTimeBattery: true
    wsDataIsReady: false
    role: "observer"
    battery: null
    token: null

    constructor: (@token) ->
        @wsDataIsReady = false
        @firstTimeBattery = true
        @role = "observer"

        @wsData = new WebSocket @URLWS

        @wsData.onopen = @onopen
        @wsData.onmessage = @onmessage
        @wsData.onclose = @onclose
        @wsData.onerror = @onerror

    onopen: =>
        console.log "ws data llamada"
        @getSensorData("ESDval", "observer")
        #sendActuatorChange 'SolarLab', "1"
        #sendActuatorChange 'CraneLab', "1"

    onclose: (event) =>
        console.log "me he cerrado"
        switch event.code
            when 1000
                myApp.hidePleaseWait()
                myApp.showError "Time expire", "The connection was close because your time to use the laboratory was expire."
            when 1001
                myApp.hidePleaseWait()
                myApp.showError "Server go to maintenance", "Sorry the connection was close because the server go to maintenance. Please try later"
            when 1002 and 1003
                myApp.hidePleaseWait()
                myApp.showError "Something's not right", "Sorry a error happened."
            when 1006 
                myApp.hidePleaseWait()
                myApp.showError "Something's not right", "Sorry impossible to conect to the server. If it's the first time reload the web, it isn't maybe the server is down. Please try later."

    onmessage: (event) =>
        data = event.data+""
        console.log data
        msg = JSON.parse data
        console.log msg

        ##improve this with case
        if msg.method == "sendActuatorData"
            if msg.responseMessages isnt undefined && msg.responseMessages.code == 409
                alert "You can't controller the laboratory. Other user is used it"
                console.log "codigo 409"
                #getSensorData("ESDval", "observer")
                eve = document.createEvent 'CustomEvent'
                eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery}
                document.dispatchEvent eve
                if @battery <= 90
                    @getSensorData("Light", "observer")
                    @getSensorData("PanelRot", "observer")
                    @getSensorData("PanelTilt", "observer")
                return

            if msg.payload.actuatorId is "SolarLab" and msg.payload.responseData.data[0] is "1"
                console.log "dentro del solarlab"
                if not @wsDataIsReady 
                    @role  = "controller"
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery}
                    document.dispatchEvent eve
                    @wsDataIsReady = true
                    eve = document.createEvent 'Event'
                    eve.initEvent 'allWsAreReady', true, false
                    document.dispatchEvent eve
                    #getSensorData("ESDval", "controller")
                return

            if msg.payload.actuatorId is "CraneLab" and msg.payload.responseData.data[0] is "1"
                console.log "centro del crane"
                if not @wsDataIsReady
                    @role  = "controller" 
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery}
                    document.dispatchEvent eve
                    @wsDataIsReady = true
                    eve = document.createEvent 'Event'
                    eve.initEvent 'allWsAreReady', true, false
                    document.dispatchEvent eve
                    #getSensorData("ESDval", "controller")
                return

        if msg.method == "sendActuatorData" && msg.payload.actuatorId == "ESD"
            if msg.payload.responseData.data[0] == "1"
                @getSensorData("ESDval", "controller")
                $("#stop").removeAttr('disabled')
                $("#reset").removeAttr('disabled')
                return

        if (msg.method == "sendActuatorData" && msg.payload.actuatorId == "Panelrot")
            horizontalAxis = reciveData(parseInt(msg.payload.responseData.data[0]), horizontalAxis, ".slider-horizontal-axis", "Panelrot")
            $(".slider-horizontal-axis").val( horizontalAxis)
            myApp.hidePleaseWait()
            return

        if msg.method == "sendActuatorData" && msg.payload.actuatorId == "Paneltilt"
            verticalAxis = reciveData(parseInt(msg.payload.responseData.data[0]), verticalAxis, ".slider-vertical-axis", "Paneltilt")
            $(".slider-vertical-axis").val(verticalAxis)
            myApp.hidePleaseWait()
            return

        if msg.method == "sendActuatorData" && msg.payload.actuatorId == "Sun"
            lumens = reciveData(parseInt(msg.payload.responseData.data[0]), lumens, ".slider-lumens", "Sun")
            $(".slider-lumens").val(lumens)
            myApp.hidePleaseWait()
            return

        if msg.method == "getSensorData" && msg.sensorId == "ESDval"
            if (msg.responseData.valueNames.length == 7)
                #fix this
                varInit.changeNumbers(msg.responseData.data[1], msg.responseData.data[0], msg.responseData.data[6])
            if @firstTimeBattery 
                #fix this
                actualBattery = msg.responseData.data[0]
                @firstTimeBattery = false
                @battery = msg.responseData.data[0]
                if @battery <= 90
                    @sendActuatorChange 'SolarLab', "1"
                else
                    @sendActuatorChange 'CraneLab', "1"
            return
            #finishInitLoading(msg.responseData.data[0])

        if msg.method == "getSensorData" && msg.sensorId == "Light"
            $(".slider-lumens").val(parseInt(msg.responseData.data[0]))
            return
        
        if msg.method == "getSensorData" && msg.sensorId == "PanelRot"
          $(".slider-horizontal-axis").val(parseInt(msg.responseData.data[0]))
          return

        if msg.method == "getSensorData" && msg.sensorId == "PanelTilt"
            $(".slider-vertical-axis").val(parseInt(msg.responseData.data[0]))
            if not @wsDataIsReady 
                @wsDataIsReady = true
                eve = document.createEvent 'Event'
                eve.initEvent 'allWsAreReady', true, false
                document.dispatchEvent eve
            return

    sendActuatorChange: (actuatorId, data) -> 
        actuatorRequest = 
            'method': 'sendActuatorData'
            'authToken': @token.toString()
            'accessRole': 'controller'
            'actuatorId': actuatorId
            'valueNames': ''
            'data': data
        
        jsonRequest = JSON.stringify actuatorRequest
        @wsData.send jsonRequest
    
    getSensorData: (sensorId, accessRole) ->
        sensorRequest = 
            'method': 'getSensorData'
            'authToken': @token.toString()
            'accessRole': accessRole
            'updateFrequency': '1' 
            'sensorId': sensorId

        jsonRequest = JSON.stringify sensorRequest
        @wsData.send jsonRequest


        # put recive message jouls and time
        ###
        "{"method":"sendActuatorData","accessRole":"controller","payload":{"actuatorId":"ESD","responseData":{"valueNames":["State"],"data":[1],"lastMeasured":["13022015T095315"]}}}"


        "{"method":"getSensorData","sensorId":"ESDval","accessRole":"","responseData":{"valueNames":["input voltage","input current","input wattage","worktodo"],"data":[1.7309999465942383,0,0,4],"lastMeasured":["12022015T151255","12022015T151255","12022015T151255","12022015T151255"]}}"

        "{
         "method": "sendActuatorData",
         "responseMessages" :{
            "code": 409,
            "message": "AccesRole controller already assigned."
        }
        }"
        if (msg.method == "getSensorMetadata") {
          document.querySelector('#sensorInfo').value = msg.sensors[0].description; // display description of the 1st sensor
          document.querySelector('#SensorMeta').value = JSON.stringify(msg);//msg.sensors[0].description; // display description of the 1st sensor
          }
        else 
        if (msg.method == "getActuatorMetadata") {
          document.querySelector('#ActuatorInfo').value = msg.actuators[0].description; // display description of the 1st sensor
          document.querySelector('#ActuatorMeta').value = JSON.stringify(msg);//msg.sensors[0].description; // display description of the 1st sensor
          }
        else{

          if (msg.responseData) {
            document.querySelector('#sensorVal').value = msg.responseData.data[0];
          }
          else
            document.querySelector('#sensorVal').value ="err: " +msg.responseMessages.code + " " +msg.responseMessages.message  ;
            
            }
         
        //  console.log("received: [", data, "]");
        ###
###
    sendActuatorChange: (actuatorId, data) ->
        console.log("llamada")

        actuatorRequest = {
        method: 'sendActuatorData',
        authToken: 'skfjs343kjKJ',
        accessRole: 'controller',
        actuatorId: actuatorId,
        valueNames: "",
        data: data  
        }

        jsonRequest = JSON.stringify(actuatorRequest)
        @wsData.send(jsonRequest)
        console.log(varInit)
        console.log(varInit.wsData)

    getSensorData: (sensorId, accessRole) ->
        jsonRequest = JSON.stringify({"method":"getSensorData", "accessRole": accessRole, "updateFrequency":"1", "sensorId":sensorId})
        @wsData.send(jsonRequest)
###

window.WebsocketData = WebsocketData