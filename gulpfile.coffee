gulp = require('gulp')
plugins = require('gulp-load-plugins')()
path = require('path')
console.log plugins
paths = 
  src:
    coffee: 'src/**/*.coffee'
    html: 'src/**/*.html'
    js: 'src/**/*.js'
    less: 'src/**/*.less'
    lessfile: 'src/styles.less'
    css: 'src/**/*.css'
  compile: 'compile'
  build: 'build'

gulp.task 'clean', [], ->
  gulp.src [paths.compile, paths.build], {read: false}
    .pipe plugins.clean()

gulp.task 'src-copy', [], ->
  gulp.src [paths.src.html, paths.src.js, paths.src.css]
    .pipe plugins.connect.reload()
    .pipe gulp.dest paths.compile



gulp.task 'compile-coffee', [], ->
  gulp.src paths.src.coffee
    .pipe plugins.coffee {bare: true}
    .pipe gulp.dest paths.compile
    .pipe plugins.connect.reload()

gulp.task 'compile-less', [], ->
  gulp.src paths.src.lessfile
    .pipe plugins.less paths: [path.join(__dirname, 'src-copy', 'styles.less')]
    .pipe gulp.dest paths.compile

gulp.task 'watch', ->
  gulp.watch paths.src.coffee, ['compile-coffee']
  gulp.watch [paths.src.html, paths.src.js, paths.src.css], ['src-copy'] # consider using gulp.changed
  gulp.watch paths.src.less, ['compile-less']

gulp.task 'connect', ->
  plugins.connect.server
    root: paths.compile
    livereload: true
    port: 8000

gulp.task 'build-copy', ['src-copy', 'compile-coffee', 'compile-less'], ->
  gulp.src ['compile/styles.css', 'compile/index.html']
    .pipe gulp.dest paths.build

gulp.task 'bftest', ['src-copy', 'compile-coffee', 'compile-less'], ->
  gulp.src path.join(__dirname, paths.compile, 'index.js')
    .pipe plugins.browserify
      shim: {}
      debug: true
      insertGlobals: true
    .pipe gulp.dest paths.build

gulp.task 'build', ['build-copy', 'bftest']


gulp.task 'default', ['connect', 'watch', 'src-copy', 'compile-coffee', 'compile-less']