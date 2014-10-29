'use strict'
# #(@) $Id: Gruntfile.coffee 540 2014-10-29 23:27:18Z knoppix $
module.exports = (grunt)->

  # load all grunt tasks
  (require 'matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  _ = grunt.util._
  path = require 'path'

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    clean: ['tmp/', '*.user.*' ]
    coffeelint:
      gruntfile: src: '<%= [ coffee.gruntfile.src ] %>', cwd: './'
      bg:        src: '<%= [ coffee.bg.src ]%>'
      demo:      src: '<%= [ coffee.demo.src ]%>'
      drq:       src: '<%= [ coffee.drq.src ]%>'
      api:       src: '<%= [ coffee.api.src ]%>'
      dream:     src: '<%= [ coffee.dream.src ]%>'
      script:    src: '<%= [ coffee.script.src ]%>'
      lib:       src: '<%= watch.lib.files %>'
      test:      src: '<%= watch.test.files %>'
      options:
        no_trailing_whitespace:
          level: 'error'
        max_line_length:
          level: 'ignore'
    coffee:
      gruntfile: cwd:  './', src: [ 'Gruntfile.coffee' ], dest: './Gruntfile.js', ext:  '.js'
      bg:        cwd:  './', src: [ 'src/bg.coffee' ],    dest: './tmp/bg.js',    ext:  '.js'
      demo:      cwd:  './', src: [ 'src/demo.coffee' ],  dest: './tmp/demo.js',  ext:  '.js'
      dream:     cwd:  './', src: [ 'src/dream.coffee' ], dest: './tmp/dream.js', ext:  '.js'
      drq:       cwd:  './', src: [ 'src/drq.coffee' ],   dest: './tmp/drq.js',   ext:  '.js'
      api:       cwd:  './', src: [ 'src/api.coffee' ],   dest: './tmp/api.js',   ext:  '.js'
      script:    cwd:  './', src: [ 'src/script.coffee' ],dest: './tmp/script.js',ext:  '.js'
      lib:       cwd: './src',src:['lib/**/*.coffee'],    dest: './tmp',          ext:  '.js', expand: true
      test:      cwd: './src',src:['test/**/*.coffee'],   dest: './tmp',          ext:  '.js', expand: true
    simplemocha:
      all:
        src: [ 'node_modules/should/should.js', 'tmp/test/**/*.js' ]
        options:
          globals: ['should']
          timeout: 3000
          ignoreLeaks: false
          ui: 'bdd'
          reporter: 'spec'
    copy:
      bg:   src: ['tmp/bg.js'],   dest: './bg.user.js'
      demo: src: ['tmp/demo.js'], dest: './demo.user.js'
    browserifying:
      dream:
        options: watch: false, debug: true
        files: './dream.user.js': './tmp/dream.js'
      drq:
        options: watch: false, debug: true
        files: './drq.user.js': './tmp/drq.js'
      api:
        options: watch: false, debug: true
        files: './api.user.js': './tmp/api.js'
      script:
        options: watch: false, debug: true
        files: './script.user.js': './tmp/script.js'
    watch:
      options:
        spawn: false
      gruntfile:
        files: [ 'Gruntfile.coffee' ]
        tasks: [ 'coffeelint:gruntfile', 'coffee:gruntfile', 'default']
      bg:
        files: [ 'src/bg.coffee' ]
        tasks: [ 'coffeelint:bg', 'coffee:bg', 'copy:bg']
      demo:
        files: [ 'src/demo.coffee' ]
        tasks: [ 'coffeelint:demo', 'coffee:demo', 'copy:demo']
      dream:
        files: [ 'src/dream.coffee' ]
        tasks: [ 'coffeelint:dream', 'coffee:dream', 'browserifying:dream']
      drq:
        files: [ 'src/drq.coffee' ]
        tasks: [ 'coffeelint:drq', 'coffee:drq', 'browserifying:drq']
      api:
        files: [ 'src/api.coffee' ]
        tasks: [ 'coffeelint:api', 'coffee:api', 'browserifying:api']
      script:
        files: [ 'src/script.coffee' ]
        tasks: [ 'coffeelint:script', 'coffee:script', 'browserifying:script']
      lib:
        files: [ 'src/lib/**/*.coffee']
        tasks: [ 'coffeelint:lib', 'coffee:lib', 'simplemocha']
      test:
        files: [ 'src/test/**/*.coffee']
        tasks: [ 'coffeelint:test', 'coffee:test', 'simplemocha']

  grunt.event.on 'watch', (action, files, target)->
    grunt.log.writeln "target #{target}: #{files} has #{action}"

    # coffeelint
    grunt.config ['coffeelint', target], src: files

    # coffee
    if grunt.config.coffee?
      coffeeData = grunt.config ['coffee', target]
      coffeeData.cwd ?= "./"
      grunt.log.writeln "cwd: #{coffeeData.cwd}"

      files = if _.isString files then files.split(",") else files.map (file)-> path.relative cwd, file
      coffeeData.src = files
      grunt.config ['coffee', target], coffeeData

  # if grunt.config.watchify?.target?
  #   grung.config.watchify.files = files
  #   grunt.config [ 'watchify', target], browserifying[target]

  # tasks.

  grunt.registerTask 'compile', [ 'coffeelint', 'coffee', 'copy' ]
  grunt.registerTask 'browserify', ['browserifying:dream', 'browserifying:drq', 'browserifying:api', 'browserifying:script']
  grunt.registerTask 'test', [ 'simplemocha' ]

  grunt.registerTask 'default', [ 'clean', 'compile', 'browserify', 'copy', 'test', 'watch' ]

# vim: se ts=2 expandtab:
