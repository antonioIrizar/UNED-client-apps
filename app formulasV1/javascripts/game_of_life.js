// Generated by CoffeeScript 1.8.0
(function() {
  var GameOfLife,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  GameOfLife = (function() {
    GameOfLife.prototype.currentCellGeneration = null;

    GameOfLife.prototype.cellSize = 30;

    GameOfLife.prototype.numberOfRows = 20;

    GameOfLife.prototype.numberOfColumns = 20;

    GameOfLife.prototype.seedProbability = 0.5;

    GameOfLife.prototype.tickLength = 1000;

    GameOfLife.prototype.canvas = null;

    GameOfLife.prototype.drawingContext = null;

    GameOfLife.prototype.eventTime = null;

    GameOfLife.prototype.eventTimeIsOn = false;

    GameOfLife.prototype.canStart = false;

    function GameOfLife(canvas) {
      this.canvas = canvas;
      this.tick = __bind(this.tick, this);
      this.seed = __bind(this.seed, this);
      this.resizeCanvas();
      this.createDrawingContext();
      this.drawGrid();
    }

    GameOfLife.prototype.createCanvas = function() {
      return this.canvas = document.createElement('canvas');
    };

    GameOfLife.prototype.resizeCanvas = function() {
      this.canvas.height = this.cellSize * this.numberOfRows;
      return this.canvas.width = this.cellSize * this.numberOfColumns;
    };

    GameOfLife.prototype.createDrawingContext = function() {
      var column, row, seedCell, _i, _j, _ref, _ref1;
      this.drawingContext = this.canvas.getContext('2d');
      this.currentCellGeneration = [];
      for (row = _i = 0, _ref = this.numberOfRows; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        this.currentCellGeneration[row] = [];
        for (column = _j = 0, _ref1 = this.numberOfColumns; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          seedCell = this.createInitialCell(row, column, false);
          this.currentCellGeneration[row][column] = seedCell;
        }
      }
      return this.canStart = false;
    };

    GameOfLife.prototype.myStart = function() {
      this.seed();
      this.drawGrid();
      return this.tick();
    };

    GameOfLife.prototype.myStop = function() {
      clearInterval(this.eventTime);
      return this.eventTimeIsOn = false;
    };

    GameOfLife.prototype.seed = function() {
      var column, row, seedCell, _i, _j, _ref, _ref1;
      for (row = _i = 0, _ref = this.numberOfRows; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        for (column = _j = 0, _ref1 = this.numberOfColumns; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          seedCell = this.currentCellGeneration[row][column];
          seedCell.isAlive = Math.random() < this.seedProbability;
        }
      }
      return this.canStart = true;
    };

    GameOfLife.prototype.createInitialCell = function(row, column, isAlive) {
      return {
        isAlive: isAlive,
        row: row,
        column: column
      };
    };

    GameOfLife.prototype.createSeedCell = function(row, column) {
      return {
        isAlive: Math.random() < this.seedProbability,
        row: row,
        column: column
      };
    };

    GameOfLife.prototype.tick = function() {
      this.drawGrid();
      this.evolveCellGeneration();
      this.eventTime = setTimeout(this.tick, this.tickLength);
      return this.eventTimeIsOn = true;
    };

    GameOfLife.prototype.drawGrid = function() {
      var column, row, _i, _ref, _results;
      _results = [];
      for (row = _i = 0, _ref = this.numberOfRows; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (column = _j = 0, _ref1 = this.numberOfColumns; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
            _results1.push(this.drawCell(this.currentCellGeneration[row][column]));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    GameOfLife.prototype.drawPosition = function(event) {
      var cell, colum, column, row;
      column = new Number;
      row = new Number;
      if (event.x !== void 0 && event.y !== void 0) {
        colum = event.x;
        row = event.y;
      } else {
        colum = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        row = event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
      }
      colum -= canvas.offsetLeft;
      row -= canvas.offsetTop;
      colum = Math.floor(colum / this.cellSize);
      row = Math.floor(row / this.cellSize);
      cell = this.currentCellGeneration[row][colum];
      cell.isAlive = !cell.isAlive;
      this.drawCell(cell);
      return this.canStart = true;
    };

    GameOfLife.prototype.drawCell = function(cell) {
      var fillStyle, x, y;
      x = cell.column * this.cellSize;
      y = cell.row * this.cellSize;
      if (cell.isAlive) {
        fillStyle = 'rgb(242, 198, 65)';
      } else {
        fillStyle = 'rgb(38, 38, 38)';
      }
      this.drawingContext.strokeStyle = 'rgb(198, 198, 198)';
      this.drawingContext.strokeRect(x, y, this.cellSize, this.cellSize);
      this.drawingContext.fillStyle = fillStyle;
      return this.drawingContext.fillRect(x, y, this.cellSize - 1, this.cellSize - 1);
    };

    GameOfLife.prototype.evolveCellGeneration = function() {
      var column, evolvedCell, newCellGeneration, row, _i, _j, _ref, _ref1;
      newCellGeneration = [];
      for (row = _i = 0, _ref = this.numberOfRows; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        newCellGeneration[row] = [];
        for (column = _j = 0, _ref1 = this.numberOfColumns; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          evolvedCell = this.evolveCell(this.currentCellGeneration[row][column]);
          newCellGeneration[row][column] = evolvedCell;
        }
      }
      return this.currentCellGeneration = newCellGeneration;
    };

    GameOfLife.prototype.evolveCell = function(cell) {
      var evolvedCell, numberOfAliveNeighbors;
      evolvedCell = {
        row: cell.row,
        column: cell.column,
        isAlive: cell.isAlive
      };
      numberOfAliveNeighbors = this.countAliveNeighbors(cell);
      if (cell.isAlive || numberOfAliveNeighbors === 3) {
        evolvedCell.isAlive = (1 < numberOfAliveNeighbors && numberOfAliveNeighbors < 4);
      }
      return evolvedCell;
    };

    GameOfLife.prototype.countAliveNeighbors = function(cell) {
      var column, lowerColumnBound, lowerRowBound, numberOfAliveNeighbors, row, upperColumnBound, upperRowBound, _i, _j;
      lowerRowBound = Math.max(cell.row - 1, 0);
      upperRowBound = Math.min(cell.row + 1, this.numberOfRows - 1);
      lowerColumnBound = Math.max(cell.column - 1, 0);
      upperColumnBound = Math.min(cell.column + 1, this.numberOfColumns - 1);
      numberOfAliveNeighbors = 0;
      for (row = _i = lowerRowBound; lowerRowBound <= upperRowBound ? _i <= upperRowBound : _i >= upperRowBound; row = lowerRowBound <= upperRowBound ? ++_i : --_i) {
        for (column = _j = lowerColumnBound; lowerColumnBound <= upperColumnBound ? _j <= upperColumnBound : _j >= upperColumnBound; column = lowerColumnBound <= upperColumnBound ? ++_j : --_j) {
          if (row === cell.row && column === cell.column) {
            continue;
          }
          if (this.currentCellGeneration[row][column].isAlive) {
            numberOfAliveNeighbors++;
          }
        }
      }
      return numberOfAliveNeighbors;
    };

    window.GameOfLife = GameOfLife;

    return GameOfLife;

  })();

}).call(this);
