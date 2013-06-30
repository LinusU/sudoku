
assman = require 'assman'

assman.top __dirname + '/..'

assman.register 'js', 'app', [
  'assets/hint.coffee'
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

assman.register 'png', 'touch-icon-144', [ 'assets/touch-icon-144.png' ]
assman.register 'svg', 'circle', [ 'assets/circle.svg' ]

# Buy when shipping:
# http://thenounproject.com/noun/skull/#icon-No6998
assman.register 'svg', 'skull', [ 'assets/skull.svg' ]

module.exports = exports = assman.middleware
