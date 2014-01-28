childProcess = require 'child_process'
{$$} = require 'atom'

module.exports =
  activate: ->
    atom.workspaceView.command 'update-package-dependencies:update', => @update()

  update: ->
    view = @createProgressView()
    atom.workspaceView.append(view)

    command = atom.packages.getApmPath()
    args = ['update']
    process = childProcess.spawn command, args, {cwd: atom.project.getPath()}
    process.on 'close', (code, signal) ->
      view.empty().focus().on 'focusout', -> view.remove()
      atom.workspaceView.once 'core:cancel', -> view.remove()

      success = (code == 0)
      if success
        view.append $$ ->
          @div class: 'text-success', 'Package depencencies updated.'
      else
        view.append $$ ->
          @div class: 'error-text', 'Failed to update package depencencies.'


  createProgressView: ->
    $$ ->
      @div tabindex: -1, class: 'overlay from-top', =>
        @span class: 'loading loading-spinner-small inline-block'
        @span "Updating package dependencies..."
