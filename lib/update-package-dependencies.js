const {BufferedProcess} = require('atom')
const UpdatePackageDependenciesStatusView = require('./update-package-dependencies-status-view')

module.exports = {
  activate () {
    this.subscription = atom.commands.add('atom-workspace', 'update-package-dependencies:update', () => this.update())
  },

  deactivate () {
    this.subscription.dispose()
    if (this.updatePackageDependenciesStatusView) {
      this.updatePackageDependenciesStatusView.detach()
      this.updatePackageDependenciesStatusView = null
    }
  },

  consumeStatusBar (statusBar) {
    this.updatePackageDependenciesStatusView = new UpdatePackageDependenciesStatusView(statusBar)
  },

  update () {
    if (this.updatePackageDependenciesStatusView) this.updatePackageDependenciesStatusView.attach()

    const command = atom.packages.getApmPath()
    const args = ['install']
    const options = {cwd: this.getActiveProjectPath(), env: Object.assign({}, process.env, {NODE_ENV: 'development'})}

    const exit = code => {
      if (this.updatePackageDependenciesStatusView) this.updatePackageDependenciesStatusView.detach()

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
