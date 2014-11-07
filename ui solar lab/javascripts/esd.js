// Generated by CoffeeScript 1.8.0
(function() {
  var Esd;

  Esd = (function() {
    Esd.prototype.canvas = null;

    Esd.prototype.img = null;

    Esd.prototype.width = null;

    Esd.prototype.height = null;

    function Esd(idCanvas, img, lumens) {
      var a;
      this.canvas = document.getElementById(idCanvas);
      this.img = document.getElementById(img);
      this.canvas.width = this.img.width;
      this.canvas.height = this.img.height;
      a = document.getElementById(lumens);
      if (this.img.complete) {
        this.drawImageInCanvas();
      } else {
        this.img.onload = (function(_this) {
          return function() {
            return _this.drawImageInCanvas();
          };
        })(this);
      }
    }

    Esd.prototype.drawImageInCanvas = function() {
      var ctx;
      this.width = this.canvas.width = this.img.width;
      this.height = this.canvas.height = this.img.height;
      ctx = this.canvas.getContext("2d");
      console.log(this.width);
      console.log(Math.floor(this.width * 0.044248));
      ctx.font = Math.floor(this.width * 0.044248) + "px monospace";
      ctx.fillText("Amps", this.width / 8, 5 * (this.height / 25));
      ctx.fillText("Volts", this.width / 8, 7 * (this.height / 25));
      ctx.fillText("Joules", this.width / 8, 9 * (this.height / 25));
      ctx.fillText("Charging", 2.5 * (this.width / 8), 3.5 * (this.height / 25));
      return ctx.fillText("Discharging", 4.5 * (this.width / 8), 3.5 * (this.height / 25));
    };

    return Esd;

  })();

  window.Esd = Esd;

}).call(this);
