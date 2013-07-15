
express = require 'express'
assets = require './assets'

app = express()

app.use assets.middleware
app.get '/cache.mf', assets.manifest

app.get '/', (req, res) ->
  res.redirect '/app.html'

module.exports = exports = (port) ->
  app.listen port
  console.log 'Listening on port', port
