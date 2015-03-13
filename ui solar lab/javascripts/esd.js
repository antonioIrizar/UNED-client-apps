// Generated by CoffeeScript 1.8.0
(function() {
  var Esd;

  Esd = (function() {
    Esd.prototype.canvas = null;

    Esd.prototype.img = null;

    Esd.prototype.width = null;

    Esd.prototype.height = null;

    Esd.prototype.plot = null;

    Esd.prototype.inputCurrent = "0.000";

    Esd.prototype.inputVoltage = "0.000";

    Esd.prototype.workToDo = "0.000";

    function Esd(idCanvas, img) {
      this.canvas = document.getElementById(idCanvas);
      this.img = document.getElementById(img);
      this.canvas.width = this.img.width;
      this.canvas.height = this.img.height;

      /*
      if @img.complete  #check if image was already loaded by the browser
          @drawImageInCanvas()
      else 
          @img.onload  = => 
              console.log "caa"
              @drawImageInCanvas()
              new Plot()
       */
      this.drawImageInCanvas();
    }

    Esd.prototype.drawImageInCanvas = function() {
      var ctx;
      this.width = this.canvas.width = this.img.width;
      this.height = this.canvas.height = this.img.height;
      ctx = this.canvas.getContext("2d");
      ctx.font = Math.floor(this.width * 0.05) + "px monospace";
      ctx.fillText("Amps", this.width / 11, 8 * (this.height / 20));
      ctx.fillText("Volts", this.width / 11, 11 * (this.height / 20));
      ctx.fillText("Joules", this.width / 11, 14 * (this.height / 20));
      ctx.fillText("Charging", 3.5 * (this.width / 11), 5 * (this.height / 20));
      ctx.fillText("Discharging", 6.5 * (this.width / 11), 5 * (this.height / 20));
      ctx.fillText(this.inputCurrent, 4 * (this.width / 11), 8 * (this.height / 20));
      ctx.fillText(this.inputVoltage, 4 * (this.width / 11), 11 * (this.height / 20));
      return ctx.fillText(this.workToDo, 4 * (this.width / 11), 14 * (this.height / 20));
    };

    Esd.prototype.drawText = function(inputCurrent, inputVoltage, workToDo) {
      var ctx;
      this.inputCurrent = inputCurrent;
      this.inputVoltage = inputVoltage;
      this.workToDo = workToDo;
      ctx = this.canvas.getContext("2d");
      ctx.clearRect(3.4 * (this.width / 11), 7 * (this.height / 20), this.width, this.height);
      ctx.fillText(this.inputCurrent, 4 * (this.width / 11), 8 * (this.height / 20));
      ctx.fillText(this.inputVoltage, 4 * (this.width / 11), 11 * (this.height / 20));
      return ctx.fillText(this.workToDo, 4 * (this.width / 11), 14 * (this.height / 20));
    };

    return Esd;

  })();

  window.Esd = Esd;

}).call(this);
