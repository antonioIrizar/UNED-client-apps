// Generated by CoffeeScript 1.8.0
(function() {
  var CommonElements;

  CommonElements = (function() {
    CommonElements.prototype.solar = true;

    CommonElements.prototype.timeText = null;

    CommonElements.prototype.batteryText = null;

    function CommonElements(solar) {
      this.solar = solar;
      this.selectNameVar();
      this.battery();
      this.time();
      this.buttons();
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
      $('.slider-battery').noUiSlider({
        start: 10,
        step: 1,
        connect: "lower",
        range: {
          'min': [10],
          'max': [100]
        }
      });
      $(".slider-battery").noUiSlider_pips({
        mode: 'count',
        values: 10,
        density: 2,
        stepped: true,
        format: wNumb({
          postfix: '%'
        })
      });
      return $(".slider").Link('lower').to("-inline-<div class=\"tooltipe\"></div>", function(value) {
        return $(this).html("<span>" + Math.floor(value) + "</span>");
      });
    };

    CommonElements.prototype.time = function() {
      var a, bigElementTime, div, divSlider, parent, smallElementTime, span, strong, time;
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
      $('.slider-time').noUiSlider({
        start: 0,
        step: 1,
        connect: "lower",
        range: {
          'min': [0],
          'max': [30]
        }
      });
      $(".slider-time").noUiSlider_pips({
        mode: 'count',
        values: 7,
        density: 3,
        stepped: true,
        format: wNumb({
          postfix: '\''
        })
      });
      $('#countdown').timeTo({
        seconds: 3,
        countdown: true,
        fontSize: 14
      });
      return $(".slider").Link('lower').to("-inline-<div class=\"tooltipe\"></div>", function(value) {
        return $(this).html("<span>" + Math.floor(value) + "</span>");
      });
    };

    CommonElements.prototype.buttons = function() {
      var button, buttonReset, buttonStart, buttonStop, div1, div2, form, parent;
      div1 = new Item("div", ["id"], ["adaptToHeight"], null, false, null);
      buttonStart = new Item("button", ["id", "class", "type", "onclick"], ["startExperiment", "btn btn-success", "button", "startExperiments()"], "Start", false, null);
      buttonStop = new Item("button", ["id", "class", "type", "style", "onclick"], ["stop", "btn btn-primary", "button", "margin-left: 4px", "stopExperiment()"], "Stop", false, null);
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
      this.solar = solar;
      this.selectNameVar();
      document.getElementById("timeText").innerHTML = this.timeText;
      return document.getElementById("batteryText").innerHTML = this.batteryText;
    };

    return CommonElements;

  })();

  window.CommonElements = CommonElements;

}).call(this);
