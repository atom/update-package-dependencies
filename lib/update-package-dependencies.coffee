{$$, BufferedNodeProcess} = require 'atom'

module.exports =
  activate: ->
    atom.workspaceView.command 'update-package-dependencies:update', => @update()

  update: ->
    view = @createProgressView()
    atom.workspaceView.append(view)

    command = atom.packages.getApmPath()
    args = ['install']
    options = {cwd: atom.project.getPath()}
    exit = (code, signal) ->
      atom.workspaceView.one 'core:cancel', -> view.remove()
      view.empty().focus().on 'focusout', -> view.remove()

      success = (code == 0)
      if success
        view.append $$ ->
          @div class: 'text-success', 'Package depencencies updated.'
      else
        view.append $$ ->
          @div class: 'text-error', 'Failed to update package depencencies.'

    new BufferedNodeProcess({command, args, exit, options})

  createProgressView: ->
    $$ ->
      @div tabindex: -1, class: 'overlay from-top', =>
        @span class: 'loading loading-spinner-small inline-block'
        @span "Updating package dependencies\u2026"
