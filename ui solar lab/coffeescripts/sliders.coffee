window.sliders = sliders = ->

  $('.slider-lumens').noUiSlider({
    start: 0,
    step: 20,
    connect: "lower",
    range: {
      'min': [0],
      'max': [700]
    }
  })

  $('.slider-horizontal-axis').noUiSlider({
    start: 0,
    step: 1,
    connect: "lower",
    range: {
      'min': [-150],
      'max': [150]
    }
  })

  $('.slider-vertical-axis').noUiSlider({
    start: 0,
    step: 1,
    connect: "lower",
    range: {
      'min': [0],
      'max': [90]
    }
  })

  $('.slider-battery').noUiSlider({
    start: 10,
    step: 1,
    connect: "lower",
    range: {
      'min': [10],
      'max': [100]
    }
  })

  $('.slider-time').noUiSlider({
    start: 0,
    step: 1,
    connect: "lower",
    range: {
      'min': [0],
      'max': [30]
    }
  })

  $('.slider-weigth').noUiSlider({
    start: 0,
    step: 1,
    connect: "lower",
    range: {
      'min': [0],
      'max': [50]
    }
  })

  $(".slider-lumens").noUiSlider_pips({
    mode: 'count',
    values: 8,
    density: 3,
    stepped: true,
    format: wNumb({
      postfix: 'lm'
    })
  })

  $(".slider-vertical-axis").noUiSlider_pips({
    mode: 'count',
    values: 10,
    density: 3,
    stepped: true,
    format: wNumb({
      postfix: 'º'
    })
  })

  $(".slider-horizontal-axis").noUiSlider_pips({
    mode: 'count',
    values: 11,
    density: 2,
    stepped: true,
    format: wNumb({
      postfix: 'º'
    })
  })

  $(".slider-battery").noUiSlider_pips({
    mode: 'count',
    values: 10,
    density: 2,
    stepped: true,
    format: wNumb({
      postfix: '%'
    })
  })

  $(".slider-time").noUiSlider_pips({
    mode: 'count',
    values: 7,
    density: 3,
    stepped: true,
    format: wNumb({
      postfix: '\''
    })
  })

  $(".slider-weigth").noUiSlider_pips({
    mode: 'count',
    values: 6,
    density: 3,
    stepped: true,
    format: wNumb({
      postfix: 'cm'
    })
  })
  $(".slider-weigth").attr('disabled', 'disabled')
  # Tags after '-inline-' are inserted as HTML.
  # noUiSlider writes to the first element it finds.
  # The tooltip HTML is 'this', so additional
  #// markup can be inserted here.
  $(".slider").Link('lower').to("-inline-<div class=\"tooltipe\"></div>", (value) -> $(this).html "<span>" + Math.floor(value) + "</span>")
