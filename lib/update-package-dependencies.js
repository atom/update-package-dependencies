const {BufferedProcess} = require('atom')
const ProgressElement = require('./progress-element')

module.exports = {
  activate () {
    this.subscription = atom.commands.add('atom-workspace', 'update-package-dependencies:update', () => this.update())
  },

  deactivate () {
    this.subscription.dispose()
    if (this.panel) this.panel.destroy()
  },

  update () {
    const view = new ProgressElement()
    view.displayLoading()
    this.panel = atom.workspace.addModalPanel({item: view})
    this.cancelSubscription = atom.commands.add('atom-workspace', 'core:cancel', () => this.panel.destroy())

    const command = atom.packages.getApmPath()
    const args = ['install']
    const options = {cwd: this.getActiveProjectPath(), env: Object.assign({}, process.env, {NODE_ENV: 'development'})}

    const exit = code => {
      this.panel.destroy()
      this.cancelSubscription.dispose()

      if (code === 0) {
        atom.notifications.addSuccess('Success!', {detail: 'Package dependencies updated.'})
      } else {
        atom.notifications.addError('Error!', {detail: 'Failed to update package dependencies.'})
      }
    }

    this.process = this.runBufferedProcess({command, args, exit, options})
  },

  // This function exists so that it can be spied on by tests
  runBufferedProcess (params) {
    return new BufferedProcess(params)
  },

  getActiveProjectPath () {
    const activeItem = atom.workspace.getActivePaneItem()
    if (activeItem && typeof activeItem.getPath === 'function') {
      return atom.project.relativizePath(activeItem.getPath())[0]
    } else {
      return atom.project.getPaths()[0]
    }
  }
}
