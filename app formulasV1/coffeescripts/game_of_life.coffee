class GameOfLife
    currentCellGeneration: null
    cellSize: 30
    numberOfRows: 20
    numberOfColumns: 20
    seedProbability: 0.5
    tickLength: 1000
    canvas: null
    drawingContext: null
    eventTime: null
    eventTimeIsOn: false
    canStart: false

    constructor: (@canvas)->
        @resizeCanvas()
        @createDrawingContext()
        @drawGrid()

    createCanvas: ->
        @canvas = document.createElement 'canvas'

    resizeCanvas: ->
        @canvas.height = @cellSize * @numberOfRows
        @canvas.width = @cellSize * @numberOfColumns

    createDrawingContext: ->
        @drawingContext = @canvas.getContext '2d'
        @currentCellGeneration = []
        for row in [0...@numberOfRows]
            @currentCellGeneration[row] = []

            for column in [0...@numberOfColumns]
                seedCell = @createInitialCell row, column, false
                @currentCellGeneration[row][column] = seedCell
        @canStart = false        

    #deprecated
    myStart: ->
        @seed()
        @drawGrid()
        @tick()

    myStop: ->
        clearInterval(@eventTime)
        @eventTimeIsOn = false

    seed: =>
        for row in [0...@numberOfRows]
            for column in [0...@numberOfColumns]
                seedCell = @currentCellGeneration[row][column]
                seedCell.isAlive = Math.random() < @seedProbability
        @canStart = true

    createInitialCell: (row, column,isAlive) ->   
        isAlive: isAlive
        row: row
        column: column
    
    #deprecated  
    createSeedCell: (row, column) ->
        isAlive: Math.random() < @seedProbability
        row: row
        column: column

    tick: =>
        @drawGrid()
        @evolveCellGeneration()
        @eventTime = setTimeout(@tick, @tickLength)
        @eventTimeIsOn = true

    drawGrid: ->
        for row in [0...@numberOfRows]
            for column in [0...@numberOfColumns]
                @drawCell(@currentCellGeneration[row][column])

    drawPosition: (event) ->
        column = new Number
        row = new Number

        if event.x != undefined && event.y != undefined
            colum = event.x
            row = event.y

        else # Firefox method to get the position
            colum = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
            row = event.clientY + document.body.scrollTop + document.documentElement.scrollTop

        colum -= canvas.offsetLeft 
        row -= canvas.offsetTop
        colum = Math.floor(colum/@cellSize)
        row = Math.floor(row/@cellSize)

        cell = @currentCellGeneration[row][colum]
        cell.isAlive = not cell.isAlive
        @drawCell cell
        @canStart = true

    drawCell: (cell) ->
        x = cell.column * @cellSize
        y = cell.row * @cellSize

        if cell.isAlive
            fillStyle = 'rgb(242, 198, 65)'
        else
            fillStyle = 'rgb(38, 38, 38)'

        #rgba, why isn't rgba working correctly?
        @drawingContext.strokeStyle = 'rgb(198, 198, 198)'
        @drawingContext.strokeRect(x, y, @cellSize, @cellSize)

        @drawingContext.fillStyle = fillStyle
        @drawingContext.fillRect(x, y, @cellSize-1, @cellSize-1)

    evolveCellGeneration: ->
        newCellGeneration = []

        for row in [0...@numberOfRows]
            newCellGeneration[row] = []

            for column in [0...@numberOfColumns]
                evolvedCell = @evolveCell(@currentCellGeneration[row][column])
                newCellGeneration[row][column] = evolvedCell

        @currentCellGeneration = newCellGeneration

    evolveCell: (cell) ->
        evolvedCell =
            row: cell.row
            column: cell.column
            isAlive: cell.isAlive

        numberOfAliveNeighbors = @countAliveNeighbors cell

        if cell.isAlive or numberOfAliveNeighbors is 3
            evolvedCell.isAlive = 1 < numberOfAliveNeighbors < 4

        evolvedCell

    countAliveNeighbors: (cell) ->
        lowerRowBound = Math.max cell.row - 1, 0
        upperRowBound = Math.min cell.row + 1, @numberOfRows - 1
        lowerColumnBound = Math.max cell.column - 1, 0
        upperColumnBound = Math.min cell.column + 1, @numberOfColumns - 1
        numberOfAliveNeighbors = 0

        for row in [lowerRowBound..upperRowBound]
            for column in [lowerColumnBound..upperColumnBound]
                continue if row is cell.row and column is cell.column

                if @currentCellGeneration[row][column].isAlive
                    numberOfAliveNeighbors++

        numberOfAliveNeighbors

    window.GameOfLife = GameOfLife
