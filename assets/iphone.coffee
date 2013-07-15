
document.body.addEventListener 'touchmove', (e) ->
  e.preventDefault()

game.on 'completed', ->
  setTimeout ->
    alert 'Puzzle solved!'
    mainMenu()
  , 1

window.undoMove = ->
  game.undo()

window.pauseGame = ->
  game.close()
  mainMenu()

window.provideHint = ->
  game.provideHint()

window.mainMenu = ->
  document.querySelector('#menu .load').style.display = (if game.list().length then 'block' else 'none')
  document.getElementById('main').classList.add 'hide'
  document.getElementById('load').classList.add 'hide'
  document.getElementById('levels').classList.add 'hide'
  document.getElementById('menu').classList.remove 'hide'

window.loadGame = ->
  window.carousel.update()
  document.getElementById('menu').classList.add 'hide'
  document.getElementById('load').classList.remove 'hide'

window.loadSelectedGame = ->
  game.load window.carousel.selectedId()
  document.getElementById('load').classList.add 'hide'
  document.getElementById('main').classList.remove 'hide'

window.newGame = ->
  document.getElementById('levels').classList.remove 'hide'
  document.getElementById('menu').classList.add 'hide'

window.loadNewGame = (level) ->
  document.getElementById('levels').classList.add 'hide'
  game.new level, ->
    document.getElementById('main').classList.remove 'hide'

mainMenu()
