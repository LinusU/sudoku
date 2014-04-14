
var express = require('express');

var app = express();
var env = (process.env.NODE_ENV || 'production');
var port = (process.env.PORT || 3200);

app.use(express.static(__dirname + '/build'));

var cacheDate = (function () {
  if (env === 'development') {
    return function () { return Date.now(); }
  } else {
    date = Date.now();
    return function () { return date; }
  }
}());

app.get('/cache.mf', function (req, res) {
  res.send(200, [
    'CACHE MANIFEST',
    '# ' + cacheDate(),
    '',
    'CACHE:',
    '# App',
    '/iphone.js',
    '/iphone.css',
    '/iphone.html',
    '/worker.js',
    '# SVG',
    '/skull.svg',
    '/circle.svg',
    '# Background',
    '/background.jpg',
    ''
  ].join('\n'));
});

app.get('/', function (req, res) {
  if (req.get('user-agent').match(/i(Phone|Pod|Pad)/i)) {
    res.redirect('/iphone.html');
  } else {
    res.redirect('/app.html');
  }
});

app.listen(port);

if (env === 'development') {
  console.log('http://localhost:' + port);
}
