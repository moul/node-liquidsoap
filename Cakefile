{exec, spawn} = require "child_process"

call = (command, fn) ->
  exec command, (err, stdout, stderr) ->
    if err?
      console.error "Error :"
      return console.dir   err

    fn err if fn?

system = (command, args) ->
  spawn command, args, stdio: "inherit"

build = (fn) ->
  call "coffee -c -o lib/node/ src/node/*.coffee", ->
    call "coffee -c -o lib/node/api src/node/api/*.coffee", ->
      call "rm -rf tmp && mkdir -p tmp/api", ->
        call "cp src/node/*.coffee src/browser/*.coffee tmp", ->
          call "cp src/node/api/*.coffee tmp/api", ->
            call "browserify tmp/entry.coffee -o lib/browser/liquidsoap.js", ->
              call "minifyjs --engine yui --level 2 lib/browser/liquidsoap.js > lib/browser/liquidsoap.min.js", fn

task 'build', 'Compile coffee scripts into plain Javascript files', ->
  build ->
    console.log "Done!"

task 'test', 'Run the tests', (args) ->
  build ->
    exec "rm -rf tmp && mkdir tmp && cp src/node/*.coffee test/*.coffee tmp", ->
      require "./tmp/request"

task 'spec', 'Run the spec tests', ->
  system "jasmine-node", ["--coffee", "./spec"]
