
currentGame = null
instance = new Sudoku document.getElementById 'game'
persistence = new Persistence

# For debug only
window.instance = instance
window.persistence = persistence

if ('ontouchstart' of window)
  touchCtrl = new TouchCtrl
  touchCtrl.setSudoku instance
else
  keyboardCtrl = new KeyboardCtrl
  keyboardCtrl.setSudoku instance

instance.on 'input', ->
  if currentGame is null then throw Error('No current game')
  if instance.isValid()
    setTimeout ->
      alert 'Puzzle solved!'
      persistence.removeGame currentGame
      currentGame = null
      showList()
    , 1
  else
    persistence.updateGame currentGame, instance.data

window.pauseGame = ->
  currentGame = null
  showList()

window.provideHint = ->
  # instance.provideHint()
  hint = new Hint instance.cells
  # for debug only
  window.hint = hint
  alert hint.hints().map((e) -> JSON.stringify(e)).join('\n')

window.loadGame = (id) ->
  game = persistence.getGame id
  currentGame = id
  instance.load game
  document.getElementById('main').style.display = 'block'
  document.getElementById('list').style.display = 'none'

window.newGame = ->
  document.getElementById('levels').style.display = 'block'
  document.getElementById('list').style.display = 'none'

window.loadNewGame = (level) ->

  document.getElementById('levels').style.display = 'none'
  req = new XMLHttpRequest

  req.onreadystatechange = ->
    if req.readyState is 4 and req.status is 200
      game = JSON.parse(req.responseText)
      currentGame = persistence.addGame game
      instance.load game
      document.getElementById('main').style.display = 'block'

  req.open 'GET', '/sudoku/' + level, true
  req.send()

window.showList = ->

  while (c = document.getElementById('games').firstChild)
    document.getElementById('games').removeChild c

  list = persistence.listGames()

  list.forEach (data) ->
    el = document.createElement 'div'
    el.className = 'game'
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
    s = new Sudoku thumb
    s.load data.game
    el.appendChild thumb
    el.appendChild diff
    el.addEventListener 'click', (e) ->
      loadGame data.id
    document.getElementById('games').appendChild el

  document.getElementById('main').style.display = 'none'
  document.getElementById('list').style.display = 'block'

window.addEventListener 'beforeunload', ->
  if currentGame
    persistence.updateGame currentGame, instance.data

showList()
