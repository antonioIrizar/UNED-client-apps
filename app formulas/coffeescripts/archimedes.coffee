class Formula
    divFormula:null
    divFormulaWithNumbers:null
    divPanel:null
    liFormula:null
    srcImage:null
    textFormula:null
    variables:null
    constantValue:null

    constructor: (divPanel,liFormula,constant_value,@srcImage,@variables) ->
        @liFormula = document.getElementById liFormula
        @liFormula.setAttribute 'ondragstart' , ""
        @liFormula.ondragstart = (e) => @drag(e)
        @divPanel = document.getElementById divPanel
        @divFormula = document.createElement 'div'
        @divPanel.setAttribute 'ondrop' , ""
        @divPanel.ondrop = (e) => @drop(e)
        @divPanel.setAttribute 'ondragover' , ""
        @divPanel.ondragover = (e) => @allowDrop(e)
        @divFormula.height = '300 px'
        @divFormula.width = '300 px'
        paragraph = document.createElement 'p'
        text = document.createTextNode "Please drop your formula here"
        paragraph.appendChild text
        @divPanel.appendChild paragraph
        @divFormulaWithNumbers = document.createElement 'div'
        @divPanel.appendChild @divFormula
        @divPanel.appendChild @divFormulaWithNumbers
        @addListenerToFormula(@srcImage)
        @constantValue = document.getElementById constant_value

    addListenerToFormula: (srcImage) ->
        @liFormula.addEventListener( 'dragstart' , 
            (e) =>
                img = document.createElement("img") 
                img.src = srcImage
                e.dataTransfer.setDragImage(img , 0 , 0)
        ,false)

    allowDrop: (ev) => 
        ev.preventDefault()

    drag: (ev) ->
        #ev.dataTransfer.setData('text/html', ev.target.id)

    drop: (ev) =>
        ev.preventDefault()
        img = document.createElement 'img'
        img.src = @srcImage
        @divFormula.appendChild img
        @divFormulaWithNumbers.appendChild @drawFormula()



    drawFormula: ->
        formula = document.createElement 'p'
        formula.setAttribute 'class', "formula-text"
        for id, variable of @variables
            @constantValue.appendChild @drawInput variable
            if id is "1"
                text = document.createTextNode " = " + variable.name
                formula.appendChild text
            else
                text = document.createTextNode variable.name
                formula.appendChild text
        @constantValue.appendChild @createButton()
        formula

    drawInput: (variable)->
        divInput = document.createElement 'div'
        divInput.setAttribute 'class' , "input-group"
        spanInput = document.createElement 'span'
        spanInput.setAttribute 'class' , "input-group-addon"
        text = document.createTextNode variable.name
        spanInput.appendChild text
        divInput.appendChild spanInput
        input = document.createElement 'input'
        input.setAttribute 'class' , "form-control"
        input.setAttribute 'type' , "text"
        input.setAttribute 'placeholder' , variable.fullName
        divInput.appendChild input
        divInput

    createButton:  ->
        divButton = document.createElement 'div'
        divButton.setAttribute 'class', "btn-group"
        button = document.createElement 'button'
        button.setAttribute 'type', "button"
        button.setAttribute 'class', "btn btn-primary"
        button.addEventListener 'click', => @clickButton()
        text = document.createTextNode "update values"
        button.appendChild text
        divButton.appendChild button
        divButton

    clickButton: ->
        alert "hola"

class Archimedes extends Formula

    newtowns:null
    density:null
    volume:null
    gravity:null
    text:null

    constructor: (divPanel,liFormula,constant_value) ->
        newtowns = new Variable("E" , "newtowns" , "description" , null)
        ###
        paragraph = document.createElement 'p'
        text1 = document.createTextNode "\u03C1"
        subTag = document.createElement 'sub'
        text2 = document.createTextNode "f"
        subTag.appendChild text2
        paragraph.appendChild text1
        paragraph.appendChild subTag
        console.log "aqui"
        ###
        #todo problems with sub tags
        density = new Variable("\u03C1" , "density" , "description" , null)
        gravity = new Variable("g" , "gravity" , "description" , null)
        volume = new Variable("V" , "volume" , "description" , null)
        variables = [newtowns,density,gravity,volume]
        super(divPanel , liFormula, constant_value, 'images/archimedesFormula.png',variables)
        a = new Graph()
        a.drawEquation(
            (x) -> 
                5 * Math.sin(x)
        , 'green', 3);

class Variable 
    name:null #string but pass in htlm , if it need for example sub tag
    fullName:null #string to put in constant value
    description:null # small description of variable
    value:null #float

    constructor: (@name,@fullName,@description,@value) ->

class Graph
    canvas: null
    minX: -10
    minY: -10
    maxX: 10
    maxY: 10
    unitsPerTick: 1
    axisColor:"#aaa"
    font: "8pt Calibri"
    tickSize: 20
    context: null
    rangeX: null
    rangeY: null
    unitX: null
    unitY: null
    centerX: null
    centerY: null
    iteration: null
    scaleX: null
    scaleY: null

    constructor: ->
        @canvas = document.getElementById "graph"
        @context = @canvas.getContext '2d'
        @rangeX = @maxX - @minX
        @rangeY = @maxY - @minY
        @unitX = @canvas.width / @rangeX 
        @unitY = @canvas.height / @rangeY
        @centerX = Math.round(Math.abs(@minX / @rangeX) * @canvas.width)
        @centerY = Math.round(Math.abs(@minY / @rangeY) * @canvas.height)
        @iteration = (@maxX - @minX) / 1000
        @scaleX = @canvas.width / @rangeX
        @scaleY = @canvas.height / @rangeY
        @drawXAxis()
        @drawYAxis()

    drawXAxis: ->
        context = @context
        context.save()
        context.beginPath()
        context.moveTo(0,@centerY)
        context.lineTo(@canvas.width, @centerY)
        context.strokeStyle = @axisColor
        context.lineWidth = 2
        context.stroke()

        xPosIncrement = @unitsPerTick * @unitX
        context.font = @font
        context.textAlign = 'center'
        context.textBaseline = 'top'

        xPos = @centerX - xPosIncrement
        unit = -1 * @unitsPerTick
        while xPos > 0
            context.moveTo(xPos, @centerY - @tickSize / 2)
            context.lineTo(xPos, @centerY + @tickSize / 2)
            context.stroke()
            context.fillText(unit, xPos, @centerY + @tickSize / 2 + 3)
            unit -= @unitsPerTick
            xPos = Math.round(xPos - xPosIncrement)

        xPos = @centerX + xPosIncrement
        unit = @unitsPerTick
        while xPos < this.canvas.width 
            context.moveTo(xPos, @centerY - @tickSize / 2)
            context.lineTo(xPos, @centerY + @tickSize / 2)
            context.stroke()
            context.fillText(unit, xPos, @centerY + @tickSize / 2 + 3)
            unit += @unitsPerTick
            xPos = Math.round(xPos + xPosIncrement)
        
        context.restore();

    drawYAxis: ->
        context = @context
        context.save()
        context.beginPath()
        context.moveTo(@centerX, 0)
        context.lineTo(@centerX,  @canvas.height)
        context.strokeStyle = @axisColor
        context.lineWidth = 2
        context.stroke()

        yPosIncrement = @unitsPerTick * @unitY
        context.font = @font
        context.textAlign = 'right'
        context.textBaseline = 'middle'

        yPos = @centerY - yPosIncrement
        unit = @unitsPerTick
        while yPos > 0
            context.moveTo(@centerX - @tickSize / 2, yPos)
            context.lineTo(@centerX + @tickSize / 2, yPos)
            context.stroke()
            context.fillText(unit, @centerX - @tickSize / 2 - 3, yPos)
            unit += @unitsPerTick
            yPos = Math.round(yPos - yPosIncrement)

        yPos = @centerY + yPosIncrement
        unit = -1 * @unitsPerTick
        while yPos < @canvas.height
            context.moveTo(@centerX - @tickSize / 2, yPos)
            context.lineTo(@centerX + @tickSize / 2, yPos)
            context.stroke()
            context.fillText(unit, @centerX - @tickSize / 2 - 3, yPos)
            unit -= @unitsPerTick
            yPos = Math.round(yPos + yPosIncrement)
        
        context.restore()

    drawEquation: (equation, color, thickness) ->
        context = @context
        context.save()
        context.save()
        @transformContext()

        context.beginPath()
        context.moveTo(@minX, equation(@minX))
        x = @minX + @iteration

        while x <= @maxX
            context.lineTo(x, equation(x))
            x += @iteration

        context.restore()
        context.lineJoin = 'round'
        context.lineWidth = thickness
        context.strokeStyle = color
        context.stroke()
        context.restore()

    transformContext: ->
        context = @context

        @context.translate(@centerX, @centerY);

        context.scale(@scaleX, - @scaleY);

window.Archimedes = Archimedes

window.Formula = Formula