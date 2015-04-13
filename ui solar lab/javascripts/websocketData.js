// Generated by CoffeeScript 1.8.0
(function() {
  var WebsocketData,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WebsocketData = (function() {
    WebsocketData.prototype.wsData = null;

    WebsocketData.prototype.URLWS = "ws://62.204.201.214:8081";

    WebsocketData.prototype.firstTimeBattery = true;

    WebsocketData.prototype.wsDataIsReady = false;

    WebsocketData.prototype.role = "observer";

    WebsocketData.prototype.battery = null;

    WebsocketData.prototype.token = null;

    function WebsocketData(token) {
      this.token = token;
      this.onmessage = __bind(this.onmessage, this);
      this.onclose = __bind(this.onclose, this);
      this.onopen = __bind(this.onopen, this);
      this.wsDataIsReady = false;
      this.firstTimeBattery = true;
      this.role = "observer";
      this.wsData = new WebSocket(this.URLWS);
      this.wsData.onopen = this.onopen;
      this.wsData.onmessage = this.onmessage;
      this.wsData.onclose = this.onclose;
      this.wsData.onerror = this.onerror;
    }

    WebsocketData.prototype.onopen = function() {
      console.log("ws data llamada");
      return this.getSensorData("ESDval", "observer");
    };

    WebsocketData.prototype.onclose = function(event) {
      console.log("me he cerrado");
      switch (event.code) {
        case 1000:
          myApp.hidePleaseWait();
          return myApp.showError("Time expire", "The connection was close because your time to use the laboratory was expire.");
        case 1001:
          myApp.hidePleaseWait();
          return myApp.showError("Server go to maintenance", "Sorry the connection was close because the server go to maintenance. Please try later");
        case 1002 && 1003:
          myApp.hidePleaseWait();
          return myApp.showError("Something's not right", "Sorry a error happened.");
        case 1006:
          myApp.hidePleaseWait();
          return myApp.showError("Something's not right", "Sorry impossible to conect to the server. If it's the first time reload the web, it isn't maybe the server is down. Please try later.");
      }
    };

    WebsocketData.prototype.onmessage = function(event) {
      var data, eve, msg;
      data = event.data + "";
      console.log(data);
      msg = JSON.parse(data);
      console.log(msg);
      if (msg.method === "sendActuatorData") {
        if (msg.responseMessages !== void 0 && msg.responseMessages.code === 409) {
          alert("You can't controller the laboratory. Other user is used it");
          console.log("codigo 409");
          eve = document.createEvent('CustomEvent');
          eve.initCustomEvent('selectInterface', true, false, {
            'role': this.role,
            'battery': this.battery
          });
          document.dispatchEvent(eve);
          if (this.battery < 90) {
            this.getSensorData("Light", "observer");
            this.getSensorData("PanelRot", "observer");
            this.getSensorData("PanelTilt", "observer");
          } else {
            if (!this.wsDataIsReady) {
              this.wsDataIsReady = true;
              eve = document.createEvent('Event');
              eve.initEvent('allWsAreReady', true, false);
              document.dispatchEvent(eve);
            }
          }
          return;
        }
        if (msg.payload.actuatorId === "SolarLab" && msg.payload.responseData.data[0] === "1") {
          eve = document.createEvent('CustomEvent');
          eve.initCustomEvent('switchLab', true, false, null);
          document.dispatchEvent(eve);
          if (!this.wsDataIsReady) {
            this.role = "controller";
            eve = document.createEvent('CustomEvent');
            eve.initCustomEvent('selectInterface', true, false, {
              'role': this.role,
              'battery': this.battery
            });
            document.dispatchEvent(eve);
            this.wsDataIsReady = true;
            eve = document.createEvent('Event');
            eve.initEvent('allWsAreReady', true, false);
            document.dispatchEvent(eve);
          }
          return;
        }
        if (msg.payload.actuatorId === "CraneLab" && msg.payload.responseData.data[0] === "1") {
          eve = document.createEvent('CustomEvent');
          eve.initCustomEvent('switchLab', true, false, null);
          document.dispatchEvent(eve);
          if (!this.wsDataIsReady) {
            this.role = "controller";
            eve = document.createEvent('CustomEvent');
            eve.initCustomEvent('selectInterface', true, false, {
              'role': this.role,
              'battery': this.battery
            });
            document.dispatchEvent(eve);
            this.wsDataIsReady = true;
            eve = document.createEvent('Event');
            eve.initEvent('allWsAreReady', true, false);
            document.dispatchEvent(eve);
          }
          return;
        }
      }
      if (msg.method === "sendActuatorData" && msg.payload.actuatorId === "ESD") {
        if (msg.payload.responseData.data[0] === "1") {
          eve = document.createEvent('Event');
          eve.initEvent('ESDOn', true, false);
          document.dispatchEvent(eve);
          this.getSensorData("ESDval", "controller");
          $("#stop").removeAttr('disabled');
          $("#reset").removeAttr('disabled');
          return;
        }
      }
      if (msg.method === "sendActuatorData" && msg.payload.actuatorId === "Panelrot") {
        eve = document.createEvent('CustomEvent');
        eve.initCustomEvent('reciveData', true, false, {
          'actuatorId': msg.payload.actuatorId,
          'value': msg.payload.responseData.data[0]
        });
        document.dispatchEvent(eve);
        return;
      }
      if (msg.method === "sendActuatorData" && msg.payload.actuatorId === "Paneltilt") {
        eve = document.createEvent('CustomEvent');
        eve.initCustomEvent('reciveData', true, false, {
          'actuatorId': msg.payload.actuatorId,
          'value': msg.payload.responseData.data[0]
        });
        document.dispatchEvent(eve);
        return;
      }
      if (msg.method === "sendActuatorData" && msg.payload.actuatorId === "Sun") {
        eve = document.createEvent('CustomEvent');
        eve.initCustomEvent('reciveData', true, false, {
          'actuatorId': msg.payload.actuatorId,
          'value': msg.payload.responseData.data[0]
        });
        document.dispatchEvent(eve);
        return;
      }
      if (msg.method === "sendActuatorData" && (msg.payload.actuatorId === "Elapsed" || msg.payload.actuatorId === 'TOuseJ' || msg.payload.actuatorId === 'TOgetJ' || msg.payload.actuatorId === 'WeightTrip')) {
        eve = document.createEvent('CustomEvent');
        eve.initCustomEvent('finishExperiment', true, false, null);
        document.dispatchEvent(eve);
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "ESDval") {
        if (msg.responseData.valueNames.length === 7) {
          this.battery = msg.responseData.data[6];
          varInit.changeNumbers(msg.responseData.data[1], msg.responseData.data[0], this.battery);
        }
        if (this.firstTimeBattery) {
          this.firstTimeBattery = false;
          this.battery = msg.responseData.data[0];
          if (this.battery < 90) {
            this.sendActuatorChange('SolarLab', "1");
          } else {
            this.sendActuatorChange('CraneLab', "1");
          }
        }
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "Light") {
        $(".slider-lumens").val(parseInt(msg.responseData.data[0]));
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "PanelRot") {
        $(".slider-horizontal-axis").val(parseInt(msg.responseData.data[0]));
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "PanelTilt") {
        $(".slider-vertical-axis").val(parseInt(msg.responseData.data[0]));
        if (!this.wsDataIsReady) {
          this.wsDataIsReady = true;
          eve = document.createEvent('Event');
          eve.initEvent('allWsAreReady', true, false);
          document.dispatchEvent(eve);
        }
      }
    };

    WebsocketData.prototype.sendActuatorChange = function(actuatorId, data) {
      var actuatorRequest, jsonRequest;
      actuatorRequest = {
        'method': 'sendActuatorData',
        'authToken': this.token.toString(),
        'accessRole': 'controller',
        'actuatorId': actuatorId,
        'valueNames': '',
        'data': data
      };
      jsonRequest = JSON.stringify(actuatorRequest);
      return this.wsData.send(jsonRequest);
    };

    WebsocketData.prototype.getSensorData = function(sensorId, accessRole) {
      var jsonRequest, sensorRequest;
      sensorRequest = {
        'method': 'getSensorData',
        'authToken': this.token.toString(),
        'accessRole': accessRole,
        'updateFrequency': '1',
        'sensorId': sensorId
      };
      jsonRequest = JSON.stringify(sensorRequest);
      return this.wsData.send(jsonRequest);

      /*
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
       */
    };

    return WebsocketData;

  })();


  /*
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
   */

  window.WebsocketData = WebsocketData;

}).call(this);
