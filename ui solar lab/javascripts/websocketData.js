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

    WebsocketData.prototype.lab = null;

    WebsocketData.prototype.switchUi = false;

    WebsocketData.prototype.oneNone = false;

    WebsocketData.prototype.alwaysObserver = false;

    WebsocketData.prototype.errorWithControler = false;

    function WebsocketData(token) {
      this.token = token;
      this.solarInterfaz = __bind(this.solarInterfaz, this);
      this.craneInterfaz = __bind(this.craneInterfaz, this);
      this.onmessage = __bind(this.onmessage, this);
      this.onclose = __bind(this.onclose, this);
      this.onopen = __bind(this.onopen, this);
      this.wsDataIsReady = false;
      this.firstTimeBattery = true;
      this.role = "observer";
      this.lab = null;
      this.switchUi = false;
      this.oneNone = false;
      this.alwaysObserver = false;
      this.errorWithControler = false;
      this.wsData = new WebSocket(this.URLWS);
      this.wsData.onopen = this.onopen;
      this.wsData.onmessage = this.onmessage;
      this.wsData.onclose = this.onclose;
      this.wsData.onerror = this.onerror;
    }

    WebsocketData.prototype.onopen = function() {
      console.log("ws open");
      return this.getSensorData("ESDval", "observer");
    };

    WebsocketData.prototype.onclose = function(event) {
      console.log("close");
      switch (event.code) {
        case 1000:
          myApp.hidePleaseWait();
          return myApp.showError("Time expire", "The connection was close because your time to use the laboratory was expire.");
        case 1001:
          myApp.hidePleaseWait();
          return myApp.showError("Server go to maintenance", "Sorry the connection was close because the server go to maintenance. Please try later");
        case 1002 || 1003:
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
          console.log("code 409");
          if (msg.responseMessages.message === "AccesRole controller already assigned.") {
            myApp.showPleaseWait();
            this.alwaysObserver = true;
            this.errorWithControler = true;
            this.role = 'observer';
            this.wsDataIsReady = false;
            if (this.lab === 'none') {
              this.getSensorData("Doing", "observer");
            } else {
              this.switchUi = true;
              if (this.lab === 'solar') {
                varInit.observer();
                this.getSensorData("Light", "observer");
              } else {
                varInit.observer();
              }
            }
          }
          return;
        }
        if (msg.payload.actuatorId === "SolarLab" && msg.payload.responseData.data[0] === "1") {
          if (this.firstTimeBattery || this.lab === null) {
            this.lab = 'solar';
            this.alwaysObserver = true;
            return;
          }
          if (!this.wsDataIsReady && this.switchUi) {
            this.lab = 'solar';
            this.abort = false;
            this.solarInterfaz();
            this.getSensorData("Light", "observer");
            return;
          }
          if (!this.wsDataIsReady && this.lab !== null) {
            this.lab = 'solar';
            this.role = "controller";
            eve = document.createEvent('CustomEvent');
            eve.initCustomEvent('selectInterface', true, false, {
              'role': this.role,
              'battery': this.battery,
              'lab': 'solar'
            });
            document.dispatchEvent(eve);
            this.wsDataIsReady = true;
            eve = document.createEvent('Event');
            eve.initEvent('allWsAreReady', true, false);
            document.dispatchEvent(eve);
          } else {
            this.lab = 'solar';
            eve = document.createEvent('CustomEvent');
            eve.initCustomEvent('switchLab', true, false, {
              'modeLab': 'charge'
            });
            document.dispatchEvent(eve);
          }
          return;
        }
        if (msg.payload.actuatorId === "CraneLab" && msg.payload.responseData.data[0] === "1") {
          if (this.firstTimeBattery || this.lab === null) {
            this.lab = 'crane';
            this.alwaysObserver = true;
            return;
          }
          if (!this.wsDataIsReady && this.switchUi) {
            this.lab = 'crane';
            this.abort = true;
            this.craneInterfaz();
            return;
          }
          if (!this.wsDataIsReady) {
            this.lab = 'crane';
            this.role = "controller";
            eve = document.createEvent('CustomEvent');
            eve.initCustomEvent('selectInterface', true, false, {
              'role': this.role,
              'battery': this.battery,
              'lab': 'crane'
            });
            document.dispatchEvent(eve);
            this.wsDataIsReady = true;
            eve = document.createEvent('Event');
            eve.initEvent('allWsAreReady', true, false);
            document.dispatchEvent(eve);
          } else {
            this.lab = 'crane';
            eve = document.createEvent('CustomEvent');
            eve.initCustomEvent('switchLab', true, false, {
              'modeLab': 'discharge'
            });
            document.dispatchEvent(eve);
          }
          return;
        }
      }
      if (msg.method === "sendActuatorData" && msg.payload.actuatorId === "ESD") {
        if (msg.payload.responseData.data[0] === "1" && !this.alwaysObserver && this.wsDataIsReady) {
          eve = document.createEvent('Event');
          eve.initEvent('ESDOn', true, false);
          document.dispatchEvent(eve);
          this.getSensorData("ESDval", "controller");
          $("#stop").removeAttr('disabled');
          $("#reset").removeAttr('disabled');
        }
        return;
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
        eve.initCustomEvent('finishExperiment', true, false, msg.payload.responseData);
        document.dispatchEvent(eve);
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "ESDval") {
        if (msg.responseData.valueNames.length === 7) {
          if (this.role === 'observer') {
            varInit.stopFalse();
          }
          this.battery = msg.responseData.data[6];
          varInit.changeNumbers(msg.responseData.data[1], msg.responseData.data[0], msg.responseData.data[4], msg.responseData.data[3], this.battery);
        }
        if (this.firstTimeBattery) {
          this.firstTimeBattery = false;
          this.battery = msg.responseData.data[0];
          if (this.lab === null) {
            this.getSensorData("Doing", "observer");
          } else {
            this.switchUi = true;
            if (this.lab === 'solar') {
              this.solarInterfaz();
              this.getSensorData("Light", "observer");
            } else {
              this.craneInterfaz();
            }
          }
        }
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "Doing") {
        if (this.alwaysObserver && !this.errorWithControler) {
          this.switchUi = true;
          if (this.lab === 'solar') {
            this.solarInterfaz();
            this.getSensorData("Light", "observer");
            return;
          } else {
            this.craneInterfaz();
            return;
          }
        } else {
          if (this.errorWithControler) {
            this.switchUi = true;
            if (this.lab === 'none' && msg.responseData.data[0] === 'none') {
              if (this.battery < 90) {
                this.lab = 'solar';
                this.solarInterfaz();
                this.getSensorData("Light", "observer");
                return;
              } else {
                this.lab = 'crane';
                this.craneInterfaz();
                return;
              }
            } else {
              if (msg.responseData.data[0] === 'none') {
                if (this.lab === 'solar') {
                  this.solarInterfaz();
                  this.getSensorData("Light", "observer");
                  return;
                } else {
                  this.craneInterfaz();
                  return;
                }
              } else {
                if (msg.responseData.data[0] === 'solar') {
                  this.solarInterfaz();
                  this.getSensorData("Light", "observer");
                  return;
                } else {
                  this.craneInterfaz();
                  return;
                }
              }
            }
          } else {
            if (msg.responseData.data[0] === 'none') {
              if (this.lab === null) {
                if (this.battery < 90) {
                  this.sendActuatorChange('SolarLab', "1");
                } else {
                  this.sendActuatorChange('CraneLab', "1");
                }
                this.lab = 'none';
              }
            }
            if (msg.responseData.data[0] === 'crane') {
              this.alwaysObserver = true;
              this.lab = 'crane';
              this.switchUi = true;
              this.craneInterfaz();
              return;
            }
            if (msg.responseData.data[0] === 'solar') {
              this.alwaysObserver = true;
              this.lab = 'solar';
              this.switchUi = true;
              this.solarInterfaz();
              this.getSensorData("Light", "observer");
              return;
            }
          }
        }
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "Light") {
        if (this.abort) {
          this.abort = false;
          return;
        }
        $(".slider-lumens").val(parseInt(msg.responseData.data[0]));
        if (this.switchUi) {
          this.getSensorData("PanelRot", "observer");
        }
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "PanelRot") {
        if (this.abort) {
          this.abort = false;
          return;
        }
        $(".slider-horizontal-axis").val(parseInt(msg.responseData.data[0]));
        if (this.switchUi) {
          this.getSensorData("PanelTilt", "observer");
        }
        return;
      }
      if (msg.method === "getSensorData" && msg.sensorId === "PanelTilt") {
        if (this.abort) {
          this.abort = false;
          return;
        }
        $(".slider-vertical-axis").val(parseInt(msg.responseData.data[0]));
        if (this.switchUi) {
          this.switchUi = false;
        }
        if (!this.wsDataIsReady) {
          this.wsDataIsReady = true;
          eve = document.createEvent('Event');
          eve.initEvent('allWsAreReady', true, false);
          document.dispatchEvent(eve);
        }
      }
    };

    WebsocketData.prototype.craneInterfaz = function() {
      var eve;
      eve = document.createEvent('CustomEvent');
      eve.initCustomEvent('selectInterface', true, false, {
        'role': this.role,
        'battery': this.battery,
        'lab': 'crane'
      });
      document.dispatchEvent(eve);
      if (!this.wsDataIsReady) {
        this.wsDataIsReady = true;
        this.switchUi = false;
        eve = document.createEvent('Event');
        eve.initEvent('allWsAreReady', true, false);
        return document.dispatchEvent(eve);
      }
    };

    WebsocketData.prototype.solarInterfaz = function() {
      var eve;
      eve = document.createEvent('CustomEvent');
      eve.initCustomEvent('selectInterface', true, false, {
        'role': this.role,
        'battery': this.battery,
        'lab': 'solar'
      });
      return document.dispatchEvent(eve);
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
    };

    return WebsocketData;

  })();

  window.WebsocketData = WebsocketData;

}).call(this);
