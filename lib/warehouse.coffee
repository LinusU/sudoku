
{EventEmitter} = require 'events'

class Warehouse extends EventEmitter
  constructor: (@productIds, @minStock) ->
    @queues = @productIds.reduce ((p, c) -> p[c] = []; p), {}
    @inventories = @productIds.reduce ((p, c) -> p[c] = []; p), {}
  restock: (productId, product) ->
    if @queues[productId].length
      cb = @queues[productId].shift()
      cb product
      @emit 'low', productId
    else
      @inventories[productId].push product
  demand: (productId, cb) ->
    if @inventories[productId].length
      cb @inventories[productId].shift()
      if @inventories[productId].length < @minStock
        @emit 'low', productId
    else
      @queues[productId].push cb
  isValidProductId: (productId) ->
    productId in @productIds
  isSufficentlyStocked: ->
    for id in @productIds
      if @inventories[id].length < @minStock
        return false
    return true

module.exports = exports = Warehouse
