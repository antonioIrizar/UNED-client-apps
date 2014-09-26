class Formula
    divFormula:null
    divFormulaWithNumbers:null
    divPanel:null
    liFormula:null
    srcImage:null

    constructor: (divPanel,liFormula,@srcImage) ->
        @liFormula = document.getElementById liFormula
        #@liFormula.setAttribute('ondragstart', a: -> @drag())
        console.log "fuera"
        ###
        @ondragstartHandler = => liFormula.addEventListener 'ondragstart' , 
            (e) ->
                console.log "dentro"
                @ondragstartHandler(e)
        ###
        @liFormula.addEventListener 'ondragstart' , 
            (e) =>
                console.log "start" 
                @drag(e)
        console.log @liFormula
        @divPanel = document.getElementById divPanel
        @divFormula = document.createElement 'div'
        @divFormula.addEventListener 'ondrop' ,  
            (e) => 
                console.log "ondrop" 
                @drop(e)
        @divFormula.addEventListener 'ondragover' , 
            (e) => 
                console.log "ondrag" 
                @allowDrop(e)
        @divFormula.height = '300 px'
        @divFormula.width = '300 px'
        text = document.createTextNode("Hello World")
        @divFormula.appendChild text
        @divFormulaWithNumbers = document.createElement 'div'
        @divPanel.appendChild @divFormula
        @divPanel.appendChild @divFormulaWithNumbers
        #@addListenerToFormula(@srcImage)

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
        ev.target.appendChild img
    

class Archimedes extends Formula
    newtowns:null
    density:null
    volume:null
    gravity:null

    constructor: (divPanel,liFormula) ->
        super(divPanel , liFormula, 'images/archimedesFormula.png')

window.Archimedes = Archimedes

window.Formula = Formula