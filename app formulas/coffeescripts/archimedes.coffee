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
        console.log "dada"
        ev.dataTransfer.setData('text/html', ev.target.id)

    drop: (ev) =>
        console.log "drop"
        ev.preventDefault()
        img = document.createElement("img") 
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

class Variable 
    name:null #string but pass in htlm , if it need for example sub tag
    fullName:null #string to put in constant value
    description:null # small description of variable
    value:null #float

    constructor: (@name,@fullName,@description,@value) ->

window.Archimedes = Archimedes

window.Formula = Formula