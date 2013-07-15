
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
    persistence.removeGame currentGame
    currentGame = null
    window.game.trigger 'completed'
  else
    persistence.updateGame currentGame, instance.data

generateSudoku = do ->

  w = new Worker '/worker.js'
  fn = null

  w.addEventListener 'message', (e) ->
    fn e.data
    fn = null

  return (level, cb) ->
    fn = cb
    w.postMessage { level: level }


listeners = {}

window.game =
  on: (ev, fn) ->
    (listeners[ev] ||= []).push fn
  trigger: (ev, data = null) ->
    (listeners[ev] ||= []).forEach (fn) -> fn data
  close: ->
    currentGame = null
  undo: ->
    instance.undo()
  provideHint: ->
    instance.provideHint()
  load: (id) ->
    game = persistence.getGame id
    currentGame = id
    instance.load game
  new: (level, cb) ->
    if level in [1, 2, 3]

      generateSudoku level, (game) ->
        currentGame = persistence.addGame game
        instance.load game
        cb()

    else

      req = new XMLHttpRequest

      req.onreadystatechange = ->
        if req.readyState is 4 and req.status is 200
          game = JSON.parse(req.responseText)
          currentGame = persistence.addGame game
          instance.load game
          cb()

      req.open 'GET', '/sudoku/' + level, true
      req.send()

  list: ->
    persistence.listGames()
