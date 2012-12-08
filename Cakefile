{exec} = require "child_process"

call = (command, fn) ->
  exec command, (err, stdout, stderr) ->
    if err?
      console.error "Error :"
      return console.dir   err

    fn err if fn?

build = (fn) ->
  call "coffee -c -o lib/node/ src/node/*.coffee", ->
    call "rm -rf tmp && mkdir tmp && cp src/node/*.coffee src/browser/*.coffee tmp && browserify tmp/entry.coffee -o lib/browser/liquidsoap.js", ->
      call "minifyjs --engine yui --level 2 lib/browser/liquidsoap.js > lib/browser/liquidsoap.min.js", ->
        call "rm -rf tmp && mkdir tmp && cp src/node/*.coffee test/*.coffee test/browser/wrapper.coffee tmp && browserify tmp/wrapper.coffee -o test/browser/files/bundle.js", fn

task 'build', 'Compile coffee scripts into plain Javascript files', ->
  build ->
    console.log "Done!"

task 'test', 'Run the tests', (args) ->
  build ->
    exec "rm -rf tmp && mkdir tmp && cp src/node/*.coffee test/*.coffee tmp", ->
      require "./tmp/request"
