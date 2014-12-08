{BufferedProcess} = require 'atom'
ProgressElement = require './progress-element'

module.exports =
  activate: ->
    atom.commands.add "atom-workspace", 'update-package-dependencies:update', =>
      @update()

  update: ->
    view = new ProgressElement
    view.displayLoading()
    panel = atom.workspace.addModalPanel(item: view)

    command = atom.packages.getApmPath()
    args = ['install']
    options = {cwd: atom.project.getPaths()[0]}
    exit = (code) ->
      view.focus()

      atom.commands.add view, 'core:cancel', ->
        panel.destroy()

      if code == 0
        view.displaySuccess()
      else
        view.displayFailure()

    @runBufferedProcess({command, args, exit, options})

  runBufferedProcess: (params) ->
    new BufferedProcess(params)
