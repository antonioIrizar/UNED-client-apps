// Generated by CoffeeScript 1.8.0
(function() {
  var Init,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Init = (function() {
    Init.prototype.plot = null;

    Init.prototype.resizeActive = null;

    Init.prototype.esd = null;

    Init.prototype.eolic = null;

    Init.prototype.noria = null;

    Init.prototype.common = null;

    Init.prototype.wsData = null;

    Init.prototype.wsCamera = null;

    Init.prototype.charge = null;

    Init.prototype.switchLab = false;

    Init.prototype.interruptExperiment = false;

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
            _this.eolic.startExperiment = false;
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
      token = 1001;
      this.wsData = new WebsocketData(token);
      this.wsCamera = new WebSocketCamera(token);
      this.plot = new Plot();
      this.esd = new Esd(idCanvas, img);
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
      if (this.common === null) {
        this.common = new CommonElements(this.wsData, true);
      } else {
        this.wsData.sendActuatorChange('FWheelLab', "0");
        this.noria.remove();
        delete this.noria;
        document.getElementById('dischargeButton').removeAttribute('disabled');
        this.noria = null;
        this.common.mySwitch(true);
        this.wsData.sendActuatorChange('WindLab', "1");
      }
      this.eolic = new EolicElements(this.wsData);
      this.charge = true;
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.disableReset();
      this.stopTrue();
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode charge';
      document.getElementById('chargeButton').setAttribute('disabled', 'disabled');
      return this.resize();
    };

    Init.prototype.selectDischarge = function() {
      this.switchLab = true;
      myApp.showPleaseWait();
      if (this.common === null) {
        this.common = new CommonElements(this.wsData, false);
      } else {
        this.wsData.sendActuatorChange('WindLab', "0");
        this.eolic.remove();
        delete this.eolic;
        document.getElementById('chargeButton').removeAttribute('disabled');
        this.eolic = null;
        this.common.mySwitch(false);
        this.wsData.sendActuatorChange('FWheelLab', "1");
      }
      this.noria = new NoriaElements(this.wsData);
      this.charge = false;
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.disableReset();
      this.stopTrue();
      document.getElementById("panelHeadingElements").innerHTML = 'Elements you can interact with: Mode discharge';
      document.getElementById('dischargeButton').setAttribute('disabled', 'disabled');
      return this.resize();
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
          this.eolic.disable();
        } else {
          this.noria.disable();
        }
        this.common.disable();
        document.getElementById('dischargeButton').setAttribute('disabled', 'disabled');
        document.getElementById('chargeButton').setAttribute('disabled', 'disabled');
        role.appendChild(document.createTextNode('You are an observer'));
      } else {
        this.common.disableStop();
        this.common.disableReset();
        role.appendChild(document.createTextNode('You are the controller'));
      }
      $(".slider-battery").val(battery);
      return $("p#textBattery").text(battery + "%");
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
      this.stopTrue();
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.resetTimer();
      $(".slider-battery").val(this.wsData.battery);
      $('.slider-time').val(0);
      if (!this.charge) {
        return this.noria.enable();
      }
    };

    Init.prototype.resetExperiment = function() {
      this.interruptExperiment = true;
      if (this.charge) {
        this.eolic.wind = null;
        $('.slider-wind').val(0);
        this.eolic.millRot = null;
        $('.slider-eolic-rot').val(0);
        $('.slider-time').val(0);
        this.wsData.sendActuatorChange('WindLab', '0');
        this.wsData.sendActuatorChange('WindLab', '1');
      } else {
        this.noria.enable();
        this.wsData.sendActuatorChange('FWheelLab', '0');
        this.wsData.sendActuatorChange('FWheelLab', '1');
      }
      this.common.resetTimer();
      this.common.enableSliders();
      this.common.enableStart();
      this.common.disableStop();
      this.common.disableReset();
      return this.stopTrue();
    };

    Init.prototype.finishExperiment = function(e) {
      var text, textToSend;
      $(this.INFOMODALTITLE).empty();
      $(this.INFOMODALBODY).empty();
      $(this.INFOMODALTITLE).append('Experiment has been finished');
      if (this.charge) {
        textToSend = 'You get the results followings, for charging the battery with the windmill: \r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds \r\n\t* Jouls won from the experiment: ' + e.detail.data[1] + ' J';
        text = 'You get the results followings, for charging the battery with the windmill:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls won from the experiment: ' + e.detail.data[1] + ' J</li></ul>';
      } else {
        textToSend = 'You get the results followings, for discharging the battery with the noria: \r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds \r\n\t* Jouls used from the experiment: ' + e.detail.data[1] + ' J \r\n\t* Turns given by the noria in the experiment: ' + e.detail.data[2] + ' Turns';
        text = 'You get the results followings, for discharging the battery with the noria:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls used from the experiment: ' + e.detail.data[1] + ' J</li>' + '<li>Turns given by the noria in the experiment: ' + e.detail.data[2] + ' Turns</li></ul>';
        if (!this.interruptExperiment) {
          $(".slider-turns").val(0);
          this.noria.enable();
          document.getElementById('chargeButton').removeAttribute('disabled');
        }
      }
      $(this.INFOMODALBODY).append('<p>' + text + '</p>');
      $(this.INFOMODAL).modal('show');
      if (!this.interruptExperiment) {
        $(".slider-battery").val(this.wsData.battery);
        this.common.disableStop();
        this.common.disableReset();
        this.common.enableSliders();
        this.common.enableStart();
        this.stopTrue();
      }
      this.interruptExperiment = false;
      return this.plot.reset(textToSend);
    };

    Init.prototype.chargeStart = function() {
      var modal;
      if ((this.eolic.wind !== null || this.eolic.wind === 0) && parseInt($(".slider-wind").val()) === 0) {
        return $('#myModalError').modal('show');
      } else {
        modal = false;
        if (this.eolic.wind !== null && this.eolic.wind !== parseInt($(".slider-wind").val())) {
          this.newForm("wind-form-confirm", "Wind", $(".slider-wind").val().toString(), this.eolic.wind.toString(), "wind");
          modal = true;
        }
        if (this.eolic.millRot !== null && this.eolic.millRot !== parseInt($(".slider-eolic-rot").val())) {
          this.newForm("mill-rot-form-confirm", "Mill horizontal rot", $(".slider-eolic-rot").val().toString(), this.eolic.millRot.toString(), "millRot");
          modal = true;
        }
        if (modal) {
          return $('#myModalConfirm').modal('show');
        } else {
          this.eolic.startExperiment = true;
          this.eolic.sendWind();
          this.eolic.sendMillRot();
          this.common.sendTime();
          this.common.sendJouls();
          this.wsData.sendActuatorChange('ESD', '1');
          this.common.disableSliders();
          this.common.disableStart();
          this.common.enableStop();
          return this.common.enableReset();
        }
      }
    };

    Init.prototype.dischargeStart = function() {
      myApp.showPleaseWait();
      this.noria.sendTurns();
      this.common.sendJoulsToUse();
      this.common.sendTime();
      this.wsData.sendActuatorChange('ESD', '1');
      document.getElementById('chargeButton').setAttribute('disabled', 'disabled');
      this.noria.disable();
      this.common.disableSliders();
      this.common.disableStart();
      this.common.enableStop();
      return this.common.enableReset();
    };

    Init.prototype.confirmAccept = function() {
      var auxMillRot, auxWind;
      auxWind = this.getValueRadius('Wind');
      auxMillRot = this.getValueRadius('Mill horizontal rot');
      if (auxWind !== null && this.eolic.wind !== auxWind) {
        this.eolic.sendWind();
      } else {
        $('.slider-wind').val(this.eolic.wind);
      }
      if (auxMillRot !== null && this.eolic.millRot !== auxMillRot) {
        this.eolic.sendMillRot();
      } else {
        $('.slider-eolic-rot').val(this.eolic.millRot);
      }
      this.eolic.startExperiment = true;
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
