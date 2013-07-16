
document.body.addEventListener 'touchmove', (e) ->
  e.preventDefault()

game.on 'completed', ->
  setTimeout ->
    document.getElementById('main').classList.add 'hide'
    document.getElementById('solved').classList.remove 'hide'
  , 1

showScene = (scene) ->
  document.getElementById('menu').classList.add 'hide'
  document.getElementById('main').classList.add 'hide'
  document.getElementById('load').classList.add 'hide'
  document.getElementById('levels').classList.add 'hide'
  document.getElementById('solved').classList.add 'hide'
  document.getElementById('generating').classList.add 'hide'
  if scene is 'generating'
    document.getElementById(scene).classList.remove 'hide'
    document.getElementById('generating').classList.add 'reset'
    setTimeout ->
      document.getElementById('generating').classList.remove 'reset'
  else
    setTimeout ->
      document.getElementById(scene).classList.remove 'hide'

window.undoMove = ->
  game.undo()

window.pauseGame = ->
  game.close()
  mainMenu()

window.provideHint = ->
  game.provideHint()

window.mainMenu = ->
  load = document.querySelector('#menu .load')
  switch game.list().length
    when 0
      load.style.display = 'none'
    when 1
      load.innerText = 'Continue game'
      load.style.display = 'block'
    else
      load.innerText = 'Load game'
      load.style.display = 'block'
  showScene 'menu'

window.loadGame = ->
  games = game.list()
  if games.length is 1
    game.load games[0].id
    showScene 'main'
  else
    window.carousel.update()
    showScene 'load'

window.loadSelectedGame = ->
  game.load window.carousel.selectedId()
  showScene 'main'

window.newGame = ->
  showScene 'levels'

window.loadNewGame = (level) ->
  showScene 'generating'
  game.new level, ->
    showScene 'main'

mainMenu()
