
document.body.addEventListener 'touchmove', (e) ->
  e.preventDefault()

game.on 'completed', ->
  setTimeout ->
    alert 'Puzzle solved!'
    mainMenu()
  , 1

window.pauseGame = ->
  game.close()
  mainMenu()

window.provideHint = ->
  game.provideHint()

window.loadGame = (id) ->
  game.load id
  document.getElementById('main').classList.remove 'hide'
  document.getElementById('menu').classList.add 'hide'

window.newGame = ->
  document.getElementById('levels').classList.remove 'hide'
  document.getElementById('menu').classList.add 'hide'

window.loadNewGame = (level) ->
  document.getElementById('levels').classList.add 'hide'
  game.new level, ->
    document.getElementById('main').classList.remove 'hide'

carousel = null
window.mainMenu = ->

  if carousel
    carousel.destroy()
    document.querySelector('#slider').innerHTML = ''

  document.getElementById('main').classList.add 'hide'
  document.getElementById('levels').classList.add 'hide'
  document.getElementById('menu').classList.remove 'hide'

  list = game.list()
  carousel = new SwipeView '#slider', { numberOfPages: list.length, loop: false }

  document.querySelector('#indicator').innerHTML = (new Array(list.length + 1).join('<b></b>'))
  document.querySelector('#indicator b').className = 'active'

  for i in [0..2]
    do ->
      page = (if i is 0 then list.length else i) - 1
      data = list[page % list.length]

      el = document.createElement 'div'
      el.classList.add 'game'
      el.setAttribute 'data-id', data.id
      thumb = document.createElement 'div'
      thumb.className = 'thumb'
      diff = document.createElement 'div'
      diff.className = 'diff'
      diff.innerHTML = do (d = data.game.difficulty) ->
        if d < 1 then return '<i></i><b></b><b></b><b></b>'
        if d < 2 then return '<i></i><i></i><b></b><b></b>'
        if d < 4 then return '<i></i><i></i><i></i><b></b>'
        if d < 8 then return '<i></i><i></i><i></i><i></i>'
        throw new Error 'Unknown difficulty'
      el.sudokuInstance = new Sudoku thumb
      el.sudokuInstance.load data.game
      el.appendChild thumb
      el.appendChild diff
      el.addEventListener 'click', (e) ->
        loadGame el.getAttribute('data-id')
      carousel.masterPages[i].appendChild el

  carousel.onFlip ->
    for i in [0..2]
      document.querySelector('#indicator .active').className = ''
      document.querySelectorAll('#indicator b')[carousel.pageIndex].className = 'active'
      upcoming = carousel.masterPages[i].dataset.upcomingPageIndex
      data = list[upcoming % list.length]
      if upcoming isnt carousel.masterPages[i].dataset.pageIndex
        el = carousel.masterPages[i].querySelector('.game')
        el.setAttribute 'data-id', data.id
        el.sudokuInstance.load data.game
        diff = el.querySelector '.diff'
        diff.innerHTML = do (d = data.game.difficulty) ->
          if d < 1 then return '<i></i><b></b><b></b><b></b>'
          if d < 2 then return '<i></i><i></i><b></b><b></b>'
          if d < 4 then return '<i></i><i></i><i></i><b></b>'
          if d < 8 then return '<i></i><i></i><i></i><i></i>'
          throw new Error 'Unknown difficulty'

mainMenu()
