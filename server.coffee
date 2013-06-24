
cluster = require 'cluster'

if cluster.isMaster

  assman = require 'assman'
  express = require 'express'

  assman.top __dirname

  assman.register 'js', 'app', [
    'assets/sudoku.coffee'
    'assets/persistence.coffee'
    'assets/touch-ctrl.coffee'
    'assets/keyboard-ctrl.coffee'
    'assets/app.coffee'
  ]

  assman.register 'css', 'app', [
    'assets/sudoku.styl'
    'assets/touch-ctrl.styl'
    'assets/app.styl'
  ]

  assman.register 'html', 'app', [
    'assets/app.jade'
  ]

  worker = cluster.fork()

  app = express()

  app.use assman.middleware

  app.get '/', (req, res) ->
    res.redirect '/app.html'

  app.get '/touch-icon-144.png', (req, res) ->
    res.set 'Content-Type', 'image/png'
    res.sendfile __dirname + '/assets/touch-icon-144.png'

  app.get '/skull.svg', (req, res) ->
    # Buy when shipping:
    # http://thenounproject.com/noun/skull/#icon-No6998
    res.set 'Content-Type', 'image/svg+xml'
    res.sendfile __dirname + '/assets/skull.svg'

  app.get '/circle.svg', (req, res) ->
    res.set 'Content-Type', 'image/svg+xml'
    res.sendfile __dirname + '/assets/circle.svg'

  app.get '/sudoku', (req, res) ->
    worker.once 'message', (msg) ->
      res.send 200, msg
    worker.send { msg: 'generate' }

  app.listen 3200

else

  sudoku = require 'sudoku'

  format = (sudoku) ->
    chunks = (arr) ->
      r = []
      for i in [0..arr.length - 1] by 9
        r.push arr.slice i, i + 9
      return r

    chunks sudoku.map (e) ->
      if e is null then null else e + 1

  process.on 'message', (msg) ->
    puzzle = sudoku.makepuzzle()
    solution = sudoku.solvepuzzle puzzle
    difficulty = sudoku.ratepuzzle puzzle, 4
    process.send
      puzzle: format puzzle
      solution: format solution
      difficulty: difficulty
