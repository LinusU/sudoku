
cluster = require 'cluster'

if cluster.isMaster
  worker = cluster.fork()
  webServer = require './lib/web-server'
  webServer worker, 3200
else
  require './lib/game-generator'
