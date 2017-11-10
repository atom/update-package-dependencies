const os = require('os')
const path = require('path')
const updatePackageDependencies = require('../lib/update-package-dependencies')

const {it, fit, ffit, afterEach, beforeEach} = require('./async-spec-helpers') // eslint-disable-line no-unused-vars

describe('Update Package Dependencies', () => {
  let projectPath = null

  beforeEach(() => {
    projectPath = __dirname
    atom.project.setPaths([projectPath])
  })

  describe('updating package dependencies', () => {
    beforeEach(() => spyOn(updatePackageDependencies, 'runBufferedProcess'))

    it('runs the `apm install` command', () => {
      updatePackageDependencies.update()

      expect(updatePackageDependencies.runBufferedProcess).toHaveBeenCalled()
      const {command, args, options} = updatePackageDependencies.runBufferedProcess.argsForCall[0][0]
      if (process.platform !== 'win32') {
        expect(command.endsWith('/apm')).toBe(true)
      } else {
        expect(command.endsWith('\\apm.cmd')).toBe(true)
      }
      expect(args).toEqual(['install'])
      expect(options.cwd).toEqual(projectPath)
    })

    it('displays a progress modal', () => {
      updatePackageDependencies.update()

      const modal = atom.workspace.getModalPanels()[0]
      expect(modal.getItem().element.querySelector('.loading')).not.toBeNull()
      expect(modal.getItem().element.textContent).toMatch(/Updating package dependencies/)
    })

    describe('when there are multiple project paths', () => {
      beforeEach(() => atom.project.setPaths([os.tmpdir(), projectPath]))

      it('uses the currently active one', async () => {
        await atom.workspace.open(path.join(projectPath, 'package.json'))

        updatePackageDependencies.update()
        const {options} = updatePackageDependencies.runBufferedProcess.argsForCall[0][0]
        expect(options.cwd).toEqual(projectPath)
      })
    })

    describe('when the update succeeds', () => {
      beforeEach(() => {
        updatePackageDependencies.update()
        const {exit} = updatePackageDependencies.runBufferedProcess.argsForCall[0][0]
        exit(0)
      })

      it('shows a success notification message', () => {
        const notification = atom.notifications.getNotifications()[0]
        expect(atom.workspace.getModalPanels().length).toEqual(0)
        expect(notification.getType()).toEqual('success')
        expect(notification.getMessage()).toEqual('Success!')
      })
    })

    describe('when the update fails', () => {
      beforeEach(() => {
        updatePackageDependencies.update()
        const {exit} = updatePackageDependencies.runBufferedProcess.argsForCall[0][0]
        exit(127)
      })

      it('shows a failure notification', () => {
        const notification = atom.notifications.getNotifications()[0]
        expect(atom.workspace.getModalPanels().length).toEqual(0)
        expect(notification.getType()).toEqual('error')
        expect(notification.getMessage()).toEqual('Error!')
      })
    })
  })

  describe('the `update-package-dependencies:update` command', () => {
    beforeEach(() => spyOn(updatePackageDependencies, 'update'))

    it('activates the package and updates package dependencies', async () => {
      const activationPromise = atom.packages.activatePackage('update-package-dependencies')
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'update-package-dependencies:update')
      const {mainModule} = await activationPromise
      expect(mainModule.update).toHaveBeenCalled()
    })
  })
})
