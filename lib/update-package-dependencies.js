const {BufferedProcess} = require('atom')
const ProgressElement = require('./progress-element')

module.exports = {
  activate () {
    atom.commands.add("atom-workspace", 'update-package-dependencies:update', () => this.update())
  },

  update () {
    const view = new ProgressElement()
    view.displayLoading()
    const panel = atom.workspace.addModalPanel({item: view})

    const command = atom.packages.getApmPath()
    const args = ['install']
    const options = {cwd: this.getActiveProjectPath()}

    const exit = code => {
      view.element.focus()

      atom.commands.add(view.element, 'core:cancel', () => panel.destroy())

      if (code === 0) {
        atom.notifications.addSuccess("Success!", {detail: "Package dependencies updated."})
        panel.destroy()
      } else {
        atom.notifications.addError("Error!", {detail: "Failed to update package dependencies."})
        panel.destroy()
      }
    }

    this.runBufferedProcess({command, args, exit, options})
  },

  runBufferedProcess (params) {
    return new BufferedProcess(params)
  },

  getActiveProjectPath () {
    const activeItem = atom.workspace.getActivePaneItem()
    if (activeItem && typeof activeItem.getPath === 'function') {
      return activeItem.getPath()
    } else {
      return atom.project.getPaths()[0]
    }
  }
}
