
assman = require 'assman'

assman.top __dirname + '/..'

assman.register 'js', 'app', [
  'assets/sudoku.coffee'
  'assets/persistence.coffee'
  'assets/touch-ctrl.coffee'
  'assets/keyboard-ctrl.coffee'
  'assets/game.coffee'
  'assets/app.coffee'
]

assman.register 'css', 'app', [
  'assets/sudoku.styl'
  'assets/touch-ctrl.styl'
  'assets/app.styl'
]

assman.register 'html', 'app', [ 'assets/app.jade' ]

assman.register 'js', 'iphone', [
  'vendor/swipeview.js'
  'assets/sudoku.coffee'
  'assets/persistence.coffee'
  'assets/touch-ctrl.coffee'
  'assets/keyboard-ctrl.coffee'
  'assets/game.coffee'
  'assets/iphone.coffee'
]

assman.register 'css', 'iphone', [
  'assets/sudoku.styl'
  'assets/touch-ctrl.styl'
  'assets/iphone.styl'
]

assman.register 'html', 'iphone', [ 'assets/iphone.jade' ]

assman.register 'png', 'touch-icon-144', [ 'assets/touch-icon-144.png' ]
assman.register 'jpg', 'background', [ 'assets/background.jpg' ]

assman.register 'svg', 'circle', [ 'assets/circle.svg' ]

# Buy when shipping:
# http://thenounproject.com/noun/skull/#icon-No6998
assman.register 'svg', 'skull', [ 'assets/skull.svg' ]

module.exports = exports =
  middleware: assman.middleware
  manifest: (req, res) ->
    res.set 'Content-Type', 'text/cache-manifest'
    res.send 200, """
      CACHE MANIFEST
      # #{Date.now()}

      CACHE:
      # App
      /iphone.js
      /iphone.css
      /iphone.html
      # SVG
      /skull.svg
      /circle.svg
      # Background
      /background.jpg

      NETWORK:
      /sudoku

    """
