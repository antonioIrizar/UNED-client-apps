// Generated by CoffeeScript 1.8.0
(function() {
  var CommonElements;

  CommonElements = (function() {
    CommonElements.prototype.solar = true;

    CommonElements.prototype.timeText = null;

    CommonElements.prototype.batteryText = null;

    CommonElements.prototype.wsData = null;

    CommonElements.prototype.time = 0;

    function CommonElements(wsData, solar) {
      this.wsData = wsData;
      this.solar = solar;
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
      var a, battery, bigElementBatery, div, divSlider, p, parent, smallElementBatery, span, strong;
      p = new Item("p", ["id", "class"], ["textBattery", "text-center"], "10%", false, null);
      smallElementBatery = new Item("img", ["src", "class", "alt"], ["images/battery1.png", "img-responsive", "battery"], null, true, [p]);
      strong = new Item("strong", ["id"], ["batteryText"], this.batteryText, false, null);
      span = new Item("span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null);
      a = new Item("a", ["class", "data-container", "data-toggle", "tabindex", "data-trigger", "data-content"], ["info-pop-up", "body", "popover", "0", "focus", "And here's some amazing content. It's very engaging. Right?"], null, true, [span]);
      divSlider = new Item("div", ["id", "class"], ["slider-battery", "slider slider-battery"], null, false, null);
      div = new Item("div", ["class"], ["slidera"], null, true, [divSlider]);
      bigElementBatery = new Item("div", ["class"], ["form-group"], null, true, [strong, a, div]);
      battery = new Element();
      battery.specialElement([smallElementBatery], [bigElementBatery]);
      parent = document.getElementById("elementsCommons");
      parent.appendChild(battery.div);
      return new Slider('slider-battery', 10, 1, [10], [100], 10, 2, '%');
    };

    CommonElements.prototype.time = function() {
      var a, bigElementTime, div, divSlider, maxTime, middle, minTime, parent, smallElementTime, span, strong, time, values;
      smallElementTime = new Item("div", ["id"], ["countdown"], null, false, null);
      strong = new Item("strong", ["id"], ["timeText"], this.timeText, false, null);
      span = new Item("span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null);
      a = new Item("a", ["href", "data-toggle", "data-target"], ["#", "modal", "#myModal"], null, true, [span]);
      divSlider = new Item("div", ["id", "class"], ["slider-time", "slider slider-time"], null, false, null);
      div = new Item("div", ["class"], ["slidera"], null, true, [divSlider]);
      bigElementTime = new Item("div", ["class"], ["form-group"], null, true, [strong, a, div]);
      time = new Element();
      time.specialElement([smallElementTime], [bigElementTime]);
      parent = document.getElementById("elementsCommons");
      parent.appendChild(time.div);
      if (!this.solar) {
        minTime = [0, 10];
        maxTime = [90];
        middle = 10;
        values = [0, 10, 30, 60, 90];
      } else {
        minTime = [0, 300];
        maxTime = [1800];
        middle = 300;
        values = [0, 300, 600, 900, 1200, 1500, 1800];
      }
      this.espacialSlider('slider-time', 0, minTime, middle, maxTime, values, 3, '\'\'');
      return $('#countdown').timeTo({
        seconds: 1,
        fontSize: 14
      });
    };

    CommonElements.prototype.buttons = function() {
      var button, buttonReset, buttonStart, buttonStop, div1, div2, form, parent;
      div1 = new Item("div", ["id"], ["adaptToHeight"], null, false, null);
      buttonStart = new Item("button", ["id", "class", "type", "onclick"], ["startExperiment", "btn btn-success", "button", "varInit.startExperiments()"], "Start", false, null);
      buttonStop = new Item("button", ["id", "class", "type", "style", "onclick"], ["stop", "btn btn-primary", "button", "margin-left: 4px", "varInit.stopExperiment()"], "Stop", false, null);
      buttonReset = new Item("button", ["id", "class", "type", "style", "onclick"], ["reset", "btn btn-danger", "button", "margin-left: 4px", "resetExperiment()"], "Reset", false, null);
      form = new Item("form", ["class", "role", "autocomplete"], ["form", "form", "off"], null, true, [buttonStart, buttonStop, buttonReset]);
      div2 = new Item("div", ["class"], ["center-block text-center"], null, true, [form]);
      button = new Element();
      button.standardElement([div1, div2]);
      parent = document.getElementById("elementsCommons");
      return parent.appendChild(button.div);
    };

    CommonElements.prototype.selectNameVar = function() {
      if (this.solar) {
        this.timeText = "Time charging";
        return this.batteryText = "How much charge do you want?";
      } else {
        this.timeText = "Time discharging";
        return this.batteryText = "How much discharge do you want?";
      }
    };

    CommonElements.prototype.mySwitch = function(solar) {
      var maxTime, middle, minTime, values;
      this.solar = solar;
      this.selectNameVar();
      if (!this.solar) {
        minTime = [0, 10];
        maxTime = [90];
        middle = 10;
        values = [0, 10, 30, 60, 90];
      } else {
        minTime = [0, 300];
        maxTime = [1800];
        middle = 300;
        values = [0, 300, 600, 900, 1200, 1500, 1800];
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
      jouls = realValueToSend(this.wsData.battery, parseInt($(".slider-battery").val()));
      if (jouls !== 0) {
        return this.wsData.sendActuatorChange('TOgetJ', jouls.toString());
      }
    };

    CommonElements.prototype.sendJoulsToUse = function() {
      var jouls;
      jouls = realValueToSend(this.wsData.battery, parseInt($(".slider-battery").val()));
      if (jouls !== 0) {
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

    return CommonElements;

  })();

  window.CommonElements = CommonElements;

}).call(this);
