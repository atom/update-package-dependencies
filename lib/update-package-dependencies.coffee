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
    options = {cwd: @getActiveProjectPath()}

    exit = (code) ->
      view.focus()

      atom.commands.add view, 'core:cancel', ->
        panel.destroy()

      if code is 0
        atom.notifications.addSuccess("Success!", detail: "Package dependencies updated.")
        panel.destroy()
      else
        atom.notifications.addError("Error!", detail: "Failed to update package dependencies.")
        panel.destroy()

    @runBufferedProcess({command, args, exit, options})

  runBufferedProcess: (params) ->
    new BufferedProcess(params)

  getActiveProjectPath: ->
    if activeItemPath = atom.workspace.getActivePaneItem()?.getPath?()
      atom.project.relativizePath(activeItemPath)[0]
    else
      atom.project.getPaths()[0]
