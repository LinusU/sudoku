
express = require 'express'
assets = require './assets'

w = null
app = express()

app.use assets

app.get '/', (req, res) ->
  res.redirect '/app.html'

app.get '/sudoku', (req, res) ->
  w.once 'message', (msg) ->
    res.send 200, msg
  w.send { msg: 'generate' }

module.exports = exports = (worker, port) ->
  w = worker
  app.listen port
