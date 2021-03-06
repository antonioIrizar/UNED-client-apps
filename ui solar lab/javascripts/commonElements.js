// Generated by CoffeeScript 1.8.0
(function() {
  var CommonElements,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  CommonElements = (function(_super) {
    __extends(CommonElements, _super);

    CommonElements.prototype.timeText = null;

    CommonElements.prototype.batteryText = null;

    CommonElements.prototype.time = 0;

    CommonElements.prototype.isSolar = true;

    function CommonElements(wsData, isSolar) {
      this.wsData = wsData;
      this.isSolar = isSolar;
      this.selectModalText = __bind(this.selectModalText, this);
      CommonElements.__super__.constructor.apply(this, arguments);
      this.selectNameVar();
      this.battery();
      this.time();
      this.buttons();
      document.addEventListener('ESDOn', (function(_this) {
        return function() {
          if (_this.time !== 0) {
            $('#countdown').timeTo({
              seconds: _this.time,
              start: true
            });
            return _this.time = 0;
          }
        };
      })(this), false);
    }

    CommonElements.prototype.battery = function() {
      var a, battery, bigElementBattery, div, divSlider, imgBattery, p, parent, span, strong;
      p = new Item("p", ["id", "class"], ["textBattery", "text-center"], "10%", false, null);
      imgBattery = new Item("img", ["src", "class", "alt"], ["images/battery1.png", "img-responsive", "battery"], null, false, null);
      strong = new Item("strong", ["id"], ["batteryText"], this.batteryText, false, null);
      span = new Item("span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null);
      a = new Item("a", ['href', 'onclick'], ['#', 'varInit.common.selectModalText(\'time\')'], null, true, [span]);
      divSlider = new Item("div", ["id", "class"], ["slider-battery", "slider slider-battery"], null, false, null);
      div = new Item("div", ["class"], ["slidera"], null, true, [divSlider]);
      bigElementBattery = new Item("div", ["class"], ["form-group"], null, true, [strong, a, div]);
      battery = new Element();
      battery.specialElement([p, imgBattery], [bigElementBattery]);
      parent = document.getElementById("elementsCommons");
      parent.appendChild(battery.div);
      new Slider('slider-battery', 0, 1, [0], [100], 11, 2, '%');
      return this.batteryCorrectValues();
    };

    CommonElements.prototype.time = function() {
      var a, bigElementTime, div, divSlider, maxTime, middle, minTime, parent, smallElementTime, span, strong, time, values;
      smallElementTime = new Item("div", ["id"], ["countdown"], null, false, null);
      strong = new Item("strong", ["id"], ["timeText"], this.timeText, false, null);
      span = new Item("span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null);
      a = new Item("a", ["href", 'onclick'], ["#", 'varInit.common.selectModalText(\'time\')'], null, true, [span]);
      divSlider = new Item("div", ["id", "class"], ["slider-time", "slider slider-time"], null, false, null);
      div = new Item("div", ["class"], ["slidera"], null, true, [divSlider]);
      bigElementTime = new Item("div", ["class"], ["form-group"], null, true, [strong, a, div]);
      time = new Element();
      time.specialElement([smallElementTime], [bigElementTime]);
      parent = document.getElementById("elementsCommons");
      parent.appendChild(time.div);
      if (!this.isSolar) {
        minTime = [0, 10];
        maxTime = [90];
        middle = 10;
        values = [0, 10, 30, 60, 90];
      } else {
        minTime = [0, 300];
        maxTime = [1200];
        middle = 300;
        values = [0, 300, 600, 900, 1200];
      }
      this.espacialSlider('slider-time', 0, minTime, middle, maxTime, values, 3, '\'\'');
      return $('#countdown').timeTo({
        seconds: 1,
        fontSize: 14
      });
    };

    CommonElements.prototype.selectModalText = function(type) {
      if (this.isSolar) {
        if (type === 'time') {
          this.modalText('Decide for how long you want to charge the battery', 'The battery will charge for the selected lapse of time. If you select both (charge and lapse of time), it will charge till it reaches the first of both; or you click on the stop button.');
        }
        if (type === 'battery') {
          this.modalText('Decide the charge you want in the battery', 'The battery will start charging till it reaches the selected value. If you select both (charge and lapse of time), it will charge till it reaches the first of both; or you click on the stop button.');
        }
      } else {
        if (type === 'time') {
          this.modalText('Decide for how long you want to discharge the battery', 'The battery will start discharging for the selected lapse of time. If you select both (charge and lapse of time), it will discharge till it reaches the first of both; or you click on the stop button.');
          this.modalText('Decide the discharge you want in the battery', 'The battery will start discharging till it reaches the selected. If you select both (discharge and lapse of time), it will discharge till it reaches the first of both; or you click on the stop button.');
        }
      }
      return $(this.INFOMODAL).modal('show');
    };

    CommonElements.prototype.buttons = function() {
      var button, buttonReset, buttonStart, buttonStop, div1, div2, form, parent;
      div1 = new Item("div", ["id"], ["adaptToHeight"], null, false, null);
      buttonStart = new Item("button", ["id", "class", "type", "onclick"], ["startExperiment", "btn btn-success", "button", "varInit.startExperiments()"], "Start", false, null);
      buttonStop = new Item("button", ["id", "class", "type", "style", "onclick"], ["stop", "btn btn-primary", "button", "margin-left: 4px", "varInit.stopExperiment()"], "Stop", false, null);
      buttonReset = new Item("button", ["id", "class", "type", "style", "onclick"], ["reset", "btn btn-danger", "button", "margin-left: 4px", "varInit.resetExperiment()"], "Reset", false, null);
      form = new Item("form", ["class", "role", "autocomplete"], ["form", "form", "off"], null, true, [buttonStart, buttonStop, buttonReset]);
      div2 = new Item("div", ["class"], ["center-block text-center"], null, true, [form]);
      button = new Element();
      button.standardElement([div1, div2]);
      parent = document.getElementById("elementsCommons");
      return parent.appendChild(button.div);
    };

    CommonElements.prototype.selectNameVar = function() {
      if (this.isSolar) {
        this.timeText = "Time charging ";
        return this.batteryText = "How much charge do you want? ";
      } else {
        this.timeText = "Time discharging ";
        return this.batteryText = "How much discharge do you want? ";
      }
    };

    CommonElements.prototype.mySwitch = function(isSolar) {
      var maxTime, middle, minTime, values;
      this.isSolar = isSolar;
      this.selectNameVar();
      if (!this.isSolar) {
        minTime = [0, 10];
        maxTime = [90];
        middle = 10;
        values = [0, 10, 30, 60, 90];
      } else {
        minTime = [0, 300];
        maxTime = [1200];
        middle = 300;
        values = [0, 300, 600, 900, 1200];
      }
      this.espacialSlider('slider-time', 0, minTime, middle, maxTime, values, 3, '\'\'');
      $('.slider-time').val(0);
      document.getElementById("timeText").innerHTML = this.timeText;
      return document.getElementById("batteryText").innerHTML = this.batteryText;
    };

    CommonElements.prototype.sendTime = function() {
      this.time = parseInt($('.slider-time').val());
      if (this.time !== 0) {
        $('#countdown').timeTo({
          seconds: this.time,
          start: false
        });
        return this.wsData.sendActuatorChange('Elapsed', this.time.toString());
      }
    };

    CommonElements.prototype.sendJouls = function() {
      var jouls;
      jouls = parseInt($('.slider-battery').val() - parseInt(this.wsData.battery));
      if (jouls !== 0) {
        return this.wsData.sendActuatorChange('TOgetJ', jouls.toString());
      } else {
        if (this.time === 0) {
          return this.wsData.sendActuatorChange('TOgetJ', '0');
        }
      }
    };

    CommonElements.prototype.sendJoulsToUse = function() {
      var jouls;
      jouls = parseInt(this.wsData.battery - parseInt($('.slider-battery').val()));
      if (jouls !== 0) {
        console.log("bateriaaaaaaa");
        return this.wsData.sendActuatorChange('TOuseJ', jouls.toString());
      }
    };

    CommonElements.prototype.espacialSlider = function(name, start, min, middle, max, values, density, postfix) {
      $('.' + name).noUiSlider({
        'start': start,
        'connect': 'lower',
        'range': {
          'min': min,
          '10%': middle,
          'max': max
        }
      }, true);
      $('.' + name).noUiSlider_pips({
        'mode': 'values',
        'density': density,
        'stepped': true,
        'values': values,
        'format': wNumb({
          'postfix': postfix
        })
      });
      return $("." + name).Link('lower').to("-inline-<div class=\"tooltipe\"></div>", function(value) {
        return $(this).html("<span>" + Math.floor(value) + "</span>");
      });
    };

    CommonElements.prototype.resetTimer = function() {
      return $('#countdown').timeTo({
        seconds: 1,
        fontSize: 14
      });
    };

    CommonElements.prototype.enableStart = function() {
      return $('#startExperiment').removeAttr('disabled');
    };

    CommonElements.prototype.disableStart = function() {
      return $('#startExperiment').attr('disabled', 'disabled');
    };

    CommonElements.prototype.enableStop = function() {
      return $('#stop').removeAttr('disabled');
    };

    CommonElements.prototype.disableStop = function() {
      return $('#stop').attr('disabled', 'disabled');
    };

    CommonElements.prototype.enableReset = function() {
      return $('#reset').removeAttr('disabled');
    };

    CommonElements.prototype.disableReset = function() {
      return $('#reset').attr('disabled', 'disabled');
    };

    CommonElements.prototype.enableSliders = function() {
      $('.slider-battery').removeAttr('disabled');
      return $('.slider-time').removeAttr('disabled');
    };

    CommonElements.prototype.disableSliders = function() {
      $('.slider-battery').attr('disabled', 'disabled');
      return $('.slider-time').attr('disabled', 'disabled');
    };

    CommonElements.prototype.disable = function() {
      this.disableStart();
      this.disableStop();
      this.disableReset();
      return this.disableSliders();
    };

    CommonElements.prototype.batteryCorrectValues = function() {
      return $('.slider-battery').on('change', (function(_this) {
        return function(event) {
          var a;
          a = parseInt($('.slider-battery').val());
          if (a === 100) {
            a = 100;
          }
          if (_this.isSolar) {
            if (a < _this.wsData.battery) {
              $('.slider-battery').val(_this.wsData.battery);
            }
            if (a > 98) {
              return $('.slider-battery').val(98);
            }
          } else {
            if (a > _this.wsData.battery) {
              $('.slider-battery').val(_this.wsData.battery);
            }
            if (a < 10) {
              return $('.slider-battery').val(10);
            }
          }
        };
      })(this));
    };

    return CommonElements;

  })(Part);

  window.CommonElements = CommonElements;

}).call(this);
