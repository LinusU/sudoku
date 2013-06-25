
express = require 'express'
assets = require './assets'
Warehouse = require './warehouse'

games = new Warehouse [1,2,3,4], 4
app = express()

app.use assets

app.get '/', (req, res) ->
  res.redirect '/app.html'

app.get '/sudoku/:diff', (req, res) ->
  productId = parseInt req.params.diff
  if games.isValidProductId productId
    games.demand productId, (product) ->
      res.send 200, product
  else
    res.send 400, 'Bad Request'

module.exports = exports = (worker, port) ->

  app.listen port
  console.log 'Listening on port', port

  needMoreGames = true
  isFetching = true
  fetchMoreGames = ->
    needMoreGames = false
    isFetching = true
    worker.send { msg: 'generate' }

  worker.on 'message', (product) ->
    productId = do (d = product.difficulty) ->
      if d < 1 then return 1
      if d < 2 then return 2
      if d < 4 then return 3
      if d < 8 then return 4
      throw new Error 'Unknown difficulty'
    console.log 'New sudoku with rating', productId
    games.restock productId, product
    isFetching = false
    if needMoreGames
      fetchMoreGames()
    else if games.isSufficentlyStocked() is false
      fetchMoreGames()
  games.on 'low', ->
    needMoreGames = true
    if isFetching is false
      fetchMoreGames()
  fetchMoreGames()
