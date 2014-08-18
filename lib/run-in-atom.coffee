coffee = require 'coffee-script'
vm = require 'vm'

module.exports =
  configDefaults:
    openDeveloperToolsOnRun: true

  activate: ->
    atom.workspaceView.command 'run-in-atom:run-in-atom', =>
      if atom.config.get 'run-in-atom.openDeveloperToolsOnRun'
        atom.openDevTools()
      editor = atom.workspace.getActivePaneItem()
      code = editor.getSelectedText()
      if code
        scope = @matchingCursorScopeInEditor(editor)
      else
        code = editor.getText()
        scope = @scopeInEditor(editor)
      @runCodeInScope code, scope, (error, warning, result) ->
        if error
          console.error "Run in Atom Error:", error
        else if warning
          console.warn "Run in Atom Warning:", warning
        else
          console.log "Run in Atom:", result

  runCodeInScope: (code, scope, callback) ->
    switch scope
      when 'source.coffee'
        try
          result = vm.runInThisContext(coffee.compile(code, bare: true))
          callback(null, null, result)
        catch error
          callback(error)
      when 'source.js'
        try
          result = vm.runInThisContext(code)
          callback(null, null, result)
        catch error
          callback(error)
      else
        warning = "Attempted to run in scope '#{scope}', which isn't supported."
        callback(null, warning)

  matchingCursorScopeInEditor: (editor) ->
    scopes = @getScopes()
    for scope in scopes
      return scope if scope in editor.getCursorScopes()

  getScopes: ->
    ['source.coffee', 'source.js']

  scopeInEditor: (editor) ->
    editor.getGrammar()?.scopeName
