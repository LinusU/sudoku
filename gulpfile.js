
var gulp = require('gulp');

var nib = require('nib');

var jade = require('gulp-jade');
var gulpif = require('gulp-if');
var concat = require('gulp-concat');
var stylus = require('gulp-stylus');
var coffee = require('gulp-coffee');
var uglify = require('gulp-uglify');
var nodemon = require('gulp-nodemon');
var minifyCSS = require('gulp-minify-css');

var isDev = !!~process.argv.indexOf('--dev');

var paths = {
  images: ['assets/*.jpg', 'assets/*.svg', 'assets/*.png'],
  templates: ['assets/*.jade'],
  desktopJs: [
    'assets/sudoku.coffee',
    'assets/persistence.coffee',
    'assets/touch-ctrl.coffee',
    'assets/keyboard-ctrl.coffee',
    'assets/hls.coffee',
    'assets/game.coffee',
    'assets/app.coffee'
  ],
  desktopCss: [
    'assets/sudoku.styl',
    'assets/touch-ctrl.styl',
    'assets/app.styl'
  ],
  iphoneJs: [
    'vendor/swipeview.js',
    'assets/sudoku.coffee',
    'assets/persistence.coffee',
    'assets/touch-ctrl.coffee',
    'assets/keyboard-ctrl.coffee',
    'assets/hls.coffee',
    'assets/game.coffee',
    'assets/carousel.coffee',
    'assets/iphone.coffee',
    'assets/cache.coffee'
  ],
  iphoneCss: [
    'assets/sudoku.styl',
    'assets/touch-ctrl.styl',
    'assets/iphone.styl',
    'assets/themes.styl'
  ],
  workerJs: [
    'assets/hls.coffee',
    'assets/worker.coffee'
  ]
};

gulp.task('images', function () {
  return gulp.src(paths.images).pipe(gulp.dest('build'));
});

gulp.task('templates', function () {
  return gulp.src(paths.templates)
    .pipe(jade({ pretty: isDev }))
    .pipe(gulp.dest('build'));
});

gulp.task('desktopJs', function () {
  return gulp.src(paths.desktopJs)
    .pipe(gulpif(/\.coffee$/, coffee()))
    .pipe(concat('app.js'))
    .pipe(gulpif(!isDev, uglify()))
    .pipe(gulp.dest('build'));
});

gulp.task('desktopCss', function () {
  return gulp.src(paths.desktopCss)
    .pipe(stylus({ use: nib }))
    .pipe(concat('app.css'))
    .pipe(gulpif(!isDev, minifyCSS()))
    .pipe(gulp.dest('build'));
});

gulp.task('iphoneJs', function () {
  return gulp.src(paths.iphoneJs)
    .pipe(gulpif(/\.coffee$/, coffee()))
    .pipe(concat('iphone.js'))
    .pipe(gulpif(!isDev, uglify()))
    .pipe(gulp.dest('build'));
});

gulp.task('iphoneCss', function () {
  return gulp.src(paths.iphoneCss)
    .pipe(stylus({ use: nib }))
    .pipe(concat('iphone.css'))
    .pipe(gulpif(!isDev, minifyCSS()))
    .pipe(gulp.dest('build'));
});

gulp.task('workerJs', function () {
  return gulp.src(paths.workerJs)
    .pipe(gulpif(/\.coffee$/, coffee()))
    .pipe(concat('worker.js'))
    .pipe(gulpif(!isDev, uglify()))
    .pipe(gulp.dest('build'));
});

gulp.task('server', ['watch'], function () {
  nodemon({ script: '.', env: { 'NODE_ENV': 'development' } });
});

gulp.task('watch', ['default'], function () {
  Object.keys(paths).forEach(function (e) {
    gulp.watch(paths[e], [e]);
  });
});

gulp.task('default', Object.keys(paths));
