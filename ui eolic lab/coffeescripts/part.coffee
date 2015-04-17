class Part
    INFOMODAL: '#infoModal'
    INFOMODALTITLE: '#infoModalTitle'
    INFOMODALBODY: '#infoModalBody'
    wsData: null

    constructor: (@wsData)->

    modalText: (title, body) ->
        $ @INFOMODALTITLE
            .empty()
        $ @INFOMODALBODY
            .empty()
        $ @INFOMODALTITLE 
            .append '<p>'+ title + '</p>'
        $ @INFOMODALBODY
            .append  '<p>'+ body + '</p>'

window.Part = Part