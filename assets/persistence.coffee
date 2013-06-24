
class Persistence
  constructor: ->

  _get: (key) ->
    JSON.parse localStorage.getItem key
  _set: (key, val) ->
    localStorage.setItem key, JSON.stringify val
  _rem: (key) ->
    localStorage.removeItem key
  _id: ->
    last = @_get 'last-id'
    next = (last || 0) + 1
    @_set 'last-id', next
    return next

  addGame: (game) ->
    id = @_id()
    @_set 'game-' + id, game
    return id

  getGame: (id) ->
    @_get 'game-' + id

  listGames: ->
    list = []
    for id in [@_get('last-id')..1] by -1
      game = @_get 'game-' + id
      if game isnt null
        list.push { id: id, game: game }
    return list

  updateGame: (id, game) ->
    @_set 'game-' + id, game

  removeGame: (id) ->
    @_rem 'game-' + id

window.Persistence = Persistence
