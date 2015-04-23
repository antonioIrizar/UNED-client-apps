// Generated by CoffeeScript 1.8.0
(function() {
  var EolicElements,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EolicElements = (function(_super) {
    __extends(EolicElements, _super);

    EolicElements.prototype.eolic = null;

    EolicElements.prototype.NAMEPARENT = "noCommonElements";

    EolicElements.prototype.wind = null;

    EolicElements.prototype.millRot = null;

    EolicElements.prototype.startExperiment = false;

    function EolicElements() {
      this.reciveDataEvent = __bind(this.reciveDataEvent, this);
      this.sendWind = __bind(this.sendWind, this);
      this.selectModalText = __bind(this.selectModalText, this);
      EolicElements.__super__.constructor.apply(this, arguments);
      this.wind = null;
      this.millRot = null;
      this.startExperiment = false;
      document.addEventListener('reciveData', this.reciveDataEvent, false);
      this.eolic = document.createElement("div");
      this.eolic.setAttribute("id", "eolicElements");
      document.getElementById(this.NAMEPARENT).appendChild(this.eolic);
      this.createWind();
      this.createMillRot();
    }

    EolicElements.prototype.createWind = function() {
      var a, bigElementBulb, button, div, divSlider, smallElementBulb, span, strong, wind;
      smallElementBulb = new Item("img", ["src", "class", "alt"], ["images/wind.jpg", "img-responsive", "bulb"], null, false, null);
      strong = new Item("strong", [], [], "Fan electrical power ", false, null);
      span = new Item("span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null);
      a = new Item("a", ['href', 'onclick'], ['#', 'varInit.eolic.selectModalText(\'wind\')'], null, true, [span]);
      button = new Item("button", ["onclick", "type", "class"], ["varInit.eolic.sendWind()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null);
      divSlider = new Item("div", ["id", "class"], ["slider-wind", "slider slider-wind"], null, false, null);
      div = new Item("div", ["class"], ["slidera"], null, true, [divSlider]);
      bigElementBulb = new Item("div", ["class"], ["form-group"], null, true, [strong, a, button, div]);
      wind = new Element();
      wind.specialElement([smallElementBulb], [bigElementBulb]);
      this.eolic.appendChild(wind.div);
      return new Slider('slider-wind', 0, 1, [0], [168], 8, 3, 'W');
    };

    EolicElements.prototype.createMillRot = function() {
      var a, bigElementBulb, button, div, divSlider, millRot, smallElementBulb, span, strong;
      smallElementBulb = new Item("img", ["src", "class", "alt"], ["images/mill.jpg", "img-responsive", "bulb"], null, false, null);
      strong = new Item("strong", [], [], "Windmill blades rotation ", false, null);
      span = new Item("span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null);
      a = new Item("a", ['href', 'onclick'], ['#', 'varInit.solar.selectModalText(\'millRot\')'], null, true, [span]);
      button = new Item("button", ["onclick", "type", "class"], ["varInit.eolic.sendMillRot()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null);
      divSlider = new Item("div", ["id", "class"], ["slider-eolic-rot", "slider slider-eolic-rot"], null, false, null);
      div = new Item("div", ["class"], ["slidera"], null, true, [divSlider]);
      bigElementBulb = new Item("div", ["class"], ["form-group"], null, true, [strong, a, button, div]);
      millRot = new Element();
      millRot.specialElement([smallElementBulb], [bigElementBulb]);
      this.eolic.appendChild(millRot.div);
      return new Slider('slider-eolic-rot', 0, 1, [-150], [150], 11, 2, 'º');
    };

    EolicElements.prototype.selectModalText = function(type) {
      switch (type) {
        case 'wind':
          this.modalText('Fan electrical power', 'The more electrical power, the faster the battery will charge. You can modify this value at any time.');
          break;
        case 'millRot':
          this.modalText('Windmill blades rotation', 'Allow to modify the blades position in relation to the fun, simulating the different directions of the wind in real nature.');
      }
      return $(this.INFOMODAL).modal('show');
    };

    EolicElements.prototype.remove = function() {
      return this.eolic.parentNode.removeChild(this.eolic);
    };

    EolicElements.prototype.realValueToSend = function(oldNumber, newNumber) {
      if (oldNumber === null) {
        return newNumber;
      }
      return newNumber - oldNumber;
    };

    EolicElements.prototype.sendWind = function() {
      var auxWind;
      auxWind = parseInt($('.slider-wind').val());
      if (auxWind !== 0) {
        this.wsData.sendActuatorChange('Wind', auxWind.toString());
        return myApp.showPleaseWait();
      }
    };

    EolicElements.prototype.sendMillRot = function() {
      var auxEolicRot, move, oldEolicRot;
      oldEolicRot = this.millRot;
      auxEolicRot = parseInt($('.slider-eolic-rot').val());
      move = this.realValueToSend(oldEolicRot, auxEolicRot);
      if (move !== 0) {
        this.wsData.sendActuatorChange('Millrot', move.toString());
        return myApp.showPleaseWait();
      }
    };

    EolicElements.prototype.reciveDataEvent = function(e) {
      switch (e.detail.actuatorId) {
        case 'Wind':
          this.wind = parseInt(e.detail.value);
          $('.slider-wind').val(this.wind);
          break;
        case 'Millrot':
          this.millRot = this.resultReciveData(parseInt(e.detail.value), this.millRot);
          $('.slider-eolic-rot').val(this.millRot);
      }
      if (!this.startExperiment) {
        console.log("entro en el recive");
        return myApp.hidePleaseWait();
      }
    };

    EolicElements.prototype.resultReciveData = function(dataRecive, dataActuator) {
      var result;
      if (dataActuator === null) {
        return result = dataRecive;
      } else {
        return result = dataRecive + dataActuator;
      }
    };

    EolicElements.prototype.enable = function() {
      $('.slider-wind').removeAttr('disabled');
      $('.slider-eolic-rot').removeAttr('disabled');
      return $('.button-accept').removeAttr('disabled');
    };

    EolicElements.prototype.disable = function() {
      $('.slider-wind').attr('disabled', 'disabled');
      $('.slider-eolic-rot').attr('disabled', 'disabled');
      return $('.button-accept').attr('disabled', 'disabled');
    };

    return EolicElements;

  })(Part);

  window.EolicElements = EolicElements;

}).call(this);
