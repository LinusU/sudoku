
game.on 'completed', ->
  setTimeout ->
    alert 'Puzzle solved!'
    showList()
  , 1

window.pauseGame = ->
  game.close()
  showList()

window.provideHint = ->
  game.provideHint()

window.loadGame = (id) ->
  game.load id
  document.getElementById('main').style.display = 'block'
  document.getElementById('list').style.display = 'none'

window.newGame = ->
  document.getElementById('levels').style.display = 'block'
  document.getElementById('list').style.display = 'none'

window.loadNewGame = (level) ->
  document.getElementById('levels').style.display = 'none'
  game.new level, ->
    document.getElementById('main').style.display = 'block'

window.showList = ->

  while (c = document.getElementById('games').firstChild)
    document.getElementById('games').removeChild c

  list = game.list()

  list.forEach (data) ->
    el = document.createElement 'div'
    el.className = 'game'
    thumb = document.createElement 'div'
    thumb.className = 'thumb'
    diff = document.createElement 'div'
    diff.className = 'diff'
    diff.innerHTML = do (d = data.game.difficulty) ->
      if d is 1 then return '<i></i><b></b><b></b><b></b>'
      if d is 2 then return '<i></i><i></i><b></b><b></b>'
      if d is 3 then return '<i></i><i></i><i></i><b></b>'
      if d is 4 then return '<i></i><i></i><i></i><i></i>'
      return '<b></b><b></b><b></b><b></b>'
    s = new Sudoku thumb
    s.load data.game
    el.appendChild thumb
    el.appendChild diff
    el.addEventListener 'click', (e) ->
      loadGame data.id
    document.getElementById('games').appendChild el

  document.getElementById('main').style.display = 'none'
  document.getElementById('list').style.display = 'block'

showList()
