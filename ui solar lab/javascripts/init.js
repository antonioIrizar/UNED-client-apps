// Generated by CoffeeScript 1.8.0
(function() {
  var Init,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Init = (function() {
    Init.prototype.plot = null;

    Init.prototype.resizeActive = null;

    Init.prototype.esd = null;

    Init.prototype.solar = null;

    Init.prototype.crane = null;

    Init.prototype.common = null;

    Init.prototype.wsData = null;

    Init.prototype.wsCamera = null;

    Init.prototype.charge = null;

    Init.prototype.switchLab = false;

    Init.prototype.INFOMODAL = '#infoModal';

    Init.prototype.INFOMODALTITLE = '#infoModalTitle';

    Init.prototype.INFOMODALBODY = '#infoModalBody';

    function Init(idCanvas, img) {
      this.chargeStart = __bind(this.chargeStart, this);
      this.finishExperiment = __bind(this.finishExperiment, this);
      this.eventReadyAll = __bind(this.eventReadyAll, this);
      this.selectInterface = __bind(this.selectInterface, this);
      this.selectDischarge = __bind(this.selectDischarge, this);
      this.selectCharge = __bind(this.selectCharge, this);
      this.stopFalse = __bind(this.stopFalse, this);
      this.stopTrue = __bind(this.stopTrue, this);
      this.resize = __bind(this.resize, this);
      var token;
      document.addEventListener('selectInterface', this.selectInterface, false);
      document.addEventListener('allWsAreReady', this.eventReadyAll, false);
      document.addEventListener('finishExperiment', this.finishExperiment, false);
      document.addEventListener('ESDOn', (function(_this) {
        return function() {
          if (_this.charge) {
            _this.solar.startExperiment = false;
          }
          return myApp.hidePleaseWait();
        };
      })(this), false);
      document.addEventListener('switchLab', (function(_this) {
        return function() {
          if (_this.switchLab) {
            _this.switchLab = false;
            return myApp.hidePleaseWait();
          }
        };
      })(this), false);
      this.change = false;
      token = Math.random();
      this.wsData = new WebsocketData(token);
      this.wsCamera = new WebSocketCamera(token);
      this.plot = new Plot();
      this.esd = new Esd(idCanvas, img);

      /* stop working in firefox
      window.addEventListener "resize", => 
          console.log "mierda puta"
          if @resizeActive 
              clearTimeout(@resizeActive)
          @resizeActive = setTimeout( =>
              @plot.resizeEvent(@esd)
              console.log "resize"
          , 250)
       */
      window.onresize = this.resize;
    }

    Init.prototype.changeNumbers = function(inputCurrent, inputVoltage, workToDo) {
      this.esd.drawText(inputCurrent, inputVoltage, workToDo);
      this.plot.inputCurrent = inputCurrent;
      this.plot.inputVoltage = inputVoltage;
      this.plot.workToDo = workToDo;
      if (this.plot.initChart === false) {
        console.log("iniciando");
        this.plot.initChart = true;
        this.plot.init();
      }
      if (this.plot.stop) {
        return this.plot.initChart = false;
      }
    };

    Init.prototype.resize = function() {
      if (this.resizeActive) {
        clearTimeout(this.resizeActive);
      }
      return this.resizeActive = setTimeout((function(_this) {
        return function() {
          var adapt, height;
          adapt = document.getElementById("adaptToHeight");
          if (adapt !== null) {
            height = window.innerHeight - document.getElementById("panel-elements").offsetHeight;
            height = height - 20;
            adapt.setAttribute("style", "height:" + height + "px");
          }
          return _this.plot.resizeEvent(_this.esd);
        };
      })(this), 250);
    };

    Init.prototype.stopTrue = function() {
      return this.plot.stop = true;
    };

    Init.prototype.stopFalse = function() {
      return this.plot.stop = false;
    };

    Init.prototype.selectCharge = function() {
      this.switchLab = true;
      myApp.showPleaseWait();
      if (this.common === null) {
        this.common = new CommonElements(this.wsData, true);
      } else {
        this.wsData.sendActuatorChange('CraneLab', "0");
        this.crane.remove();
        delete this.crane;
        document.getElementById('dischargeButton').removeAttribute('disabled');
        this.crane = null;
        this.common.mySwitch(true);
        this.wsData.sendActuatorChange('SolarLab', "1");
      }
      this.solar = new SolarElements(this.wsData);
      this.charge = true;
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.disableReset();
      this.stopTrue();
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode charge';
      return document.getElementById('chargeButton').setAttribute('disabled', 'disabled');
    };

    Init.prototype.selectDischarge = function() {
      this.switchLab = true;
      myApp.showPleaseWait();
      if (this.common === null) {
        this.common = new CommonElements(this.wsData, false);
      } else {
        this.wsData.sendActuatorChange('SolarLab', "0");
        this.solar.remove();
        delete this.solar;
        document.getElementById('chargeButton').removeAttribute('disabled');
        this.solar = null;
        this.common.mySwitch(false);
        this.wsData.sendActuatorChange('CraneLab', "1");
      }
      this.crane = new CraneElements(this.wsData);
      this.charge = false;
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.disableReset();
      this.stopTrue();
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode discharge';
      return document.getElementById('dischargeButton').setAttribute('disabled', 'disabled');
    };

    Init.prototype.selectInterface = function(e) {
      var battery, role;
      battery = e.detail.battery;
      role = document.getElementById('yourRole');
      if (battery >= 90) {
        this.selectDischarge();
      } else {
        this.selectCharge();
      }
      if (e.detail.role === 'observer') {
        if (this.charge) {
          this.solar.disable();
        } else {
          this.crane.disable();
        }
        this.common.disable();
        document.getElementById('dischargeButton').setAttribute('disabled', 'disabled');
        document.getElementById('chargeButton').setAttribute('disabled', 'disabled');
        role.appendChild(document.createTextNode('You are mode observer'));
      } else {
        this.common.disableStop();
        this.common.disableReset();
        role.appendChild(document.createTextNode('You are mode controller'));
      }
      $(".slider-battery").val(battery);
      $("p#textBattery").text(battery + "%");
      return this.plot.resize();
    };

    Init.prototype.eventReadyAll = function(e) {
      if (this.wsData.wsDataIsReady && this.wsCamera.wsCameraIsReady) {
        return myApp.hidePleaseWait();
      }
    };

    Init.prototype.startExperiments = function() {
      if (this.charge) {
        console.log("cargarrr");
        this.chargeStart();
      } else {
        this.dischargeStart();
      }
      return this.stopFalse();
    };

    Init.prototype.stopExperiment = function() {
      this.wsData.sendActuatorChange('ESD', '0');
      this.stopTrue();
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.resetTimer();
      $('.slider-time').val(0);
      if (!this.charge) {
        return this.crane.enable();
      }
    };

    Init.prototype.resetExperiment = function() {
      var horizontalAxis, lumens, verticalAxis;
      if (this.charge) {
        lumens = null;
        $('.slider-lumens').val(0);
        horizontalAxis = null;
        $('.slider-horizontal-axis').val(0);
        verticalAxis = null;
        $('.slider-vertical-axis').val(0);
        $('.slider-time').val(0);
        this.wsData.sendActuatorChange('SolarLab', '0');
        this.wsData.sendActuatorChange('SolarLab', '1');
      } else {
        this.crane.enable();
        this.wsData.sendActuatorChange('CraneLab', '0');
        this.wsData.sendActuatorChange('CraneLab', '1');
      }
      this.common.resetTimer();
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.disableReset();
      return this.stopTrue();
    };

    Init.prototype.finishExperiment = function(e) {
      var text;
      $(this.INFOMODALTITLE).empty();
      $(this.INFOMODALBODY).empty();
      $(this.INFOMODALTITLE).append('Experiment has been finished');
      if (this.charge) {
        text = 'You get the results followings, for charging the battery with the windmill:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls won from the experiment: ' + e.detail.data[1] + ' J</li></ul>';
        $(".slider-battery").val(this.wsData.battery);
        this.common.disableStop();
        this.common.disableReset();
      } else {
        text = 'You get the results followings, for discharging the battery with the noria:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls used from the experiment: ' + e.detail.data[1] + ' J</li>' + '<li>Distance travelled by the weigth in the experiment: ' + e.detail.data[2] + ' cm</li></ul>';
        $(".slider-distance").val(0);
        $(".slider-battery").val(this.wsData.battery);
        this.crane.enable();
        this.common.disableStop();
        this.common.disableReset();
        document.getElementById('chargeButton').removeAttribute('disabled');
      }
      $(this.INFOMODALBODY).append('<p>' + text + '</p>');
      $(this.INFOMODAL).modal('show');
      this.common.enableSliders();
      this.common.enableStart();
      return this.stopTrue();
    };

    Init.prototype.chargeStart = function() {
      var modal;
      if (parseInt($(".slider-lumens").val()) === 0) {
        return $('#myModalError').modal('show');
      } else {
        modal = false;
        if (this.solar.lumens !== null && this.solar.lumens !== parseInt($(".slider-lumens").val())) {
          newForm("lumens-axis-form-confirm", "Lumens", $(".slider-lumens").val().toString(), this.solar.lumens.toString(), "lumens");
          modal = true;
        }
        if (this.solar.horizontalAxis !== null && this.solar.horizontalAxis !== parseInt($(".slider-horizontal-axis").val())) {
          newForm("horizontal-axis-form-confirm", "Horizontal axis", $(".slider-horizontal-axis").val().toString(), this.solar.horizontalAxis.toString(), "horizontalAxis");
          modal = true;
        }
        if (this.solar.verticalAxis !== null && this.solar.verticalAxis !== parseInt($(".slider-vertical-axis").val())) {
          newForm("vertical-axis-form-confirm", "Vertical axis", $(".slider-vertical-axis").val().toString(), this.solar.verticalAxis.toString(), "verticalAxis");
          modal = true;
        }
        if (modal) {
          return $('#myModalConfirm').modal('show');
        } else {
          this.solar.startExperiment = true;
          this.solar.sendLumens();
          this.solar.sendHorizontalAxis();
          this.solar.sendVerticalAxis();
          this.common.sendTime();
          this.common.sendJouls();
          this.wsData.sendActuatorChange('ESD', "1");
          this.common.disableSliders();
          this.common.disableStart();
          this.common.enableStop();
          return this.common.enableReset();
        }
      }
    };

    Init.prototype.dischargeStart = function() {
      myApp.showPleaseWait();
      this.crane.sendDistance();
      this.common.sendJoulsToUse();
      this.common.sendTime();
      this.wsData.sendActuatorChange('ESD', "1");
      document.getElementById('chargeButton').setAttribute('disabled', 'disabled');
      this.crane.disable();
      this.common.disableSliders();
      this.common.disableStart();
      this.common.enableStop();
      return this.common.enableReset();
    };

    return Init;

  })();

  window.Init = Init;

}).call(this);
