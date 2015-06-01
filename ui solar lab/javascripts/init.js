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

    Init.prototype.interruptExperiment = false;

    Init.prototype.role = 'observer';

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
      this.changeNumbers = __bind(this.changeNumbers, this);
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
        return function(e) {
          if (_this.role === 'observer') {
            if (e.detail.modeLab === 'charge') {
              _this.createUiCharge();
            } else {
              _this.createUiDischarge();
            }
          } else {

          }
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
      window.onresize = this.resize;
    }

    Init.prototype.changeNumbers = function(inputCurrent, inputVoltage, outputCurrent, outputVoltage, workToDo) {
      if (this.charge) {
        this.esd.drawTextCharge(inputCurrent, inputVoltage, workToDo);
        this.plot.current = inputCurrent;
        this.plot.voltage = inputVoltage;
      } else {
        this.esd.drawTextDischarge(outputCurrent, outputVoltage, workToDo);
        this.plot.current = outputCurrent;
        this.plot.voltage = outputVoltage;
      }
      this.plot.workToDo = workToDo;
      $("p#textBattery").text(workToDo + "%");
      if (this.plot.initChart === false) {
        this.plot.initChart = true;
        return this.plot.init();
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
            adapt.setAttribute("style", "height: 0px");
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
      this.esd.charge = true;
      this.esd.drawTextCharge('0.0000', '0.0000', '0');
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
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode charge';
      document.getElementById('chargeButton').setAttribute('disabled', 'disabled');
      return this.resize();
    };

    Init.prototype.createUiCharge = function() {
      this.esd.charge = true;
      this.esd.drawTextCharge('0.0000', '0.0000', '0');
      this.crane.remove();
      delete this.crane;
      this.crane = null;
      this.common.mySwitch(true);
      this.common.disable();
      this.solar = new SolarElements(this.wsData);
      this.charge = true;
      this.solar.disable();
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode charge';
      return this.resize();
    };

    Init.prototype.selectDischarge = function() {
      this.switchLab = true;
      myApp.showPleaseWait();
      this.esd.charge = false;
      this.esd.drawTextDischarge('0.0000', '0.0000', '0');
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
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode discharge';
      document.getElementById('dischargeButton').setAttribute('disabled', 'disabled');
      return this.resize();
    };

    Init.prototype.createUiDischarge = function() {
      this.esd.charge = false;
      this.esd.drawTextDischarge('0.0000', '0.0000', '0');
      this.solar.remove();
      delete this.solar;
      this.solar = null;
      this.common.mySwitch(false);
      this.common.disable();
      this.crane = new CraneElements(this.wsData);
      this.charge = false;
      this.crane.disable();
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode discharge';
      return this.resize();
    };

    Init.prototype.selectInterface = function(e) {
      var battery, role;
      battery = e.detail.battery;
      this.role = e.detail.role;
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
      this.interruptExperiment = true;
      this.wsData.sendActuatorChange('ESD', '0');
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.resetTimer();
      $(".slider-battery").val(this.wsData.battery);
      $('.slider-time').val(0);
      if (!this.charge) {
        return this.crane.enable();
      }
    };

    Init.prototype.resetExperiment = function() {
      var horizontalAxis, lumens, verticalAxis;
      this.interruptExperiment = true;
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
      $(".slider-battery").val(this.wsData.battery);
      this.common.resetTimer();
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      return this.common.disableReset();
    };

    Init.prototype.finishExperiment = function(e) {
      var text, textToSend;
      $(this.INFOMODALTITLE).empty();
      $(this.INFOMODALBODY).empty();
      $(this.INFOMODALTITLE).append('Experiment has been finished');
      if (this.charge) {
        textToSend = 'You get the results followings, for charging the battery with the solar panel:\r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds\r\n\t* Jouls won from the experiment: ' + e.detail.data[1] + ' J';
        text = 'You get the results followings, for charging the battery with the solar panel:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls won from the experiment: ' + e.detail.data[1] + ' J</li></ul>';
      } else {
        textToSend = 'You get the results followings, for discharging the battery with the crane:\r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds\r\n\t* Jouls used from the experiment: ' + e.detail.data[1] + ' J\r\n\t* Distance travelled by the weigth in the experiment: ' + e.detail.data[2] + ' cm';
        text = 'You get the results followings, for discharging the battery with the crane:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls used from the experiment: ' + e.detail.data[1] + ' J</li>' + '<li>Distance travelled by the weigth in the experiment: ' + e.detail.data[2] + ' cm</li></ul>';
        if (!this.interruptExperiment && this.role === 'controller') {
          $(".slider-distance").val(0);
          this.crane.enable();
          document.getElementById('chargeButton').removeAttribute('disabled');
        }
      }
      $(this.INFOMODALBODY).append('<p>' + text + '</p>');
      $(this.INFOMODAL).modal('show');
      this.stopTrue();
      this.plot.initChart = false;
      if (!this.interruptExperiment && this.role === 'controller') {
        $(".slider-battery").val(this.wsData.battery);
        this.common.disableStop();
        this.common.disableReset();
        this.common.enableSliders();
        this.common.enableStart();
      }
      if (this.charge) {
        this.esd.drawTextCharge('0.0000', '0.0000', this.wsData.battery);
      } else {
        this.esd.drawTextDischarge('0.0000', '0.0000', this.wsData.battery);
      }
      this.interruptExperiment = false;
      return this.plot.reset(textToSend);
    };

    Init.prototype.chargeStart = function() {
      var modal;
      if (parseInt($(".slider-lumens").val()) === 0) {
        return $('#myModalError').modal('show');
      } else {
        modal = false;
        if (this.solar.lumens !== null && this.solar.lumens !== parseInt($(".slider-lumens").val())) {
          this.newForm("lumens-axis-form-confirm", "Lumens", $(".slider-lumens").val().toString(), this.solar.lumens.toString(), "lumens");
          modal = true;
        }
        if (this.solar.horizontalAxis !== null && this.solar.horizontalAxis !== parseInt($(".slider-horizontal-axis").val())) {
          this.newForm("horizontal-axis-form-confirm", "Horizontal axis", $(".slider-horizontal-axis").val().toString(), this.solar.horizontalAxis.toString(), "horizontalAxis");
          modal = true;
        }
        if (this.solar.verticalAxis !== null && this.solar.verticalAxis !== parseInt($(".slider-vertical-axis").val())) {
          this.newForm("vertical-axis-form-confirm", "Vertical axis", $(".slider-vertical-axis").val().toString(), this.solar.verticalAxis.toString(), "verticalAxis");
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

    Init.prototype.confirmAccept = function() {
      var auxHorizontalAxis, auxLumens, auxVerticalAxis;
      auxLumens = this.getValueRadius('Lumens');
      auxHorizontalAxis = this.getValueRadius('Horizontal axis');
      auxVerticalAxis = this.getValueRadius('Vertical axis');
      if (auxLumens !== null && this.solar.lumens !== auxLumens) {
        this.solar.sendLumens();
      } else {
        $('.slider-lumens').val(this.solar.lumens);
      }
      if (auxHorizontalAxis !== null && this.solar.horizontalAxis !== auxHorizontalAxis) {
        this.solar.sendHorizontalAxis();
      } else {
        $('.slider-horizontal-axis').val(this.solar.horizontalAxis);
      }
      if (auxVerticalAxis !== null && this.solar.verticalAxis !== auxVerticalAxis) {
        this.solar.sendVerticalAxis();
      } else {
        $('.slider-vertical-axis').val(this.solar.verticalAxis);
      }
      this.solar.startExperiment = true;
      this.common.sendTime();
      this.common.sendJouls();
      this.wsData.sendActuatorChange('ESD', '1');
      this.common.disableSliders();
      this.common.disableStart();
      this.common.enableStop();
      this.common.enableReset();
      return this.cleanForm();
    };

    Init.prototype.getValueRadius = function(name) {
      var i, rads;
      rads = document.getElementsByName(name);
      i = 0;
      while (i < rads.length) {
        if (rads[i].checked) {
          return rads[i].value;
        }
        i++;
      }
    };

    Init.prototype.cleanForm = function() {
      var divForm, form;
      form = document.getElementById('form-confirm-changes');
      form.removeChild(document.getElementById('div-confirm-changes'));
      divForm = document.createElement('div');
      divForm.setAttribute('id', 'div-confirm-changes');
      return form.appendChild(divForm);
    };

    Init.prototype.newForm = function(id, labelText, newValue, oldValue, name) {
      var divForm, divPrincipal, labelForm, text;
      divPrincipal = document.getElementById('div-confirm-changes');
      divForm = document.createElement('form');
      divForm.setAttribute('id', id);
      divForm.setAttribute('class', 'form-group');
      labelForm = document.createElement('label');
      text = document.createTextNode(labelText);
      labelForm.appendChild(text);
      divForm.appendChild(labelForm);
      divForm.appendChild(this.newRadio(newValue, true, " (New)", name));
      divForm.appendChild(this.newRadio(oldValue, false, " (Old)", name));
      return divPrincipal.appendChild(divForm);
    };

    Init.prototype.newRadio = function(value, checked, newOrOld, name) {
      var divRadio, input, labelRadio, text;
      divRadio = document.createElement('div');
      divRadio.setAttribute('class', 'radio');
      labelRadio = document.createElement('label');
      input = document.createElement('input');
      input.setAttribute('type', 'radio');
      input.setAttribute('name', name);
      input.setAttribute('value', value);
      if (checked) {
        input.setAttribute('checked', true);
      }
      labelRadio.appendChild(input);
      text = document.createTextNode(value + newOrOld);
      labelRadio.appendChild(text);
      divRadio.appendChild(labelRadio);
      return divRadio;
    };

    return Init;

  })();

  window.Init = Init;

}).call(this);
