const os = require('os')
const path = require('path')

const {it, fit, ffit, afterEach, beforeEach} = require('./async-spec-helpers') // eslint-disable-line no-unused-vars

describe('Update Package Dependencies', () => {
  let [workspaceElement, mainModule, projectPath] = []

  beforeEach(async () => {
    projectPath = __dirname
    workspaceElement = atom.views.getView(atom.workspace)
    atom.project.setPaths([projectPath])

    const pack = await atom.packages.activatePackage('update-package-dependencies')
    mainModule = pack.mainModule
  })

  describe('the update-package-dependencies:update command', () => {
    beforeEach(() => spyOn(mainModule, 'runBufferedProcess'))

    it('updates package dependencies', () => {
      atom.commands.dispatch(workspaceElement, 'update-package-dependencies:update')

      expect(mainModule.runBufferedProcess).toHaveBeenCalled()
      const [{command, args, options}] = mainModule.runBufferedProcess.argsForCall[0]
      if (process.platform !== 'win32') {
        expect(command).toMatch(/\/apm$/)
      } else {
        expect(command).toMatch(/\\apm.cmd$/)
      }
      expect(args).toEqual(['install'])
      expect(options.cwd).toEqual(projectPath)
    })

    it('displays a progress modal', () => {
      atom.commands.dispatch(workspaceElement, 'update-package-dependencies:update')

      const [modal] = atom.workspace.getModalPanels()
      expect(modal.getItem().element.querySelector('.loading')).not.toBeNull()
      expect(modal.getItem().element.textContent).toMatch(/Updating package dependencies/)
    })

    describe('when there are multiple project paths', () => {
      beforeEach(() => atom.project.setPaths([os.tmpdir(), projectPath]))

      it('uses the currently active one', async () => {
        await atom.workspace.open(path.join(projectPath, 'package.json'))

        atom.commands.dispatch(workspaceElement, 'update-package-dependencies:update')
        const [{options}] = mainModule.runBufferedProcess.argsForCall[0]
        expect(options.cwd).toEqual(projectPath)
      })
    })

    describe('when the update succeeds', () => {
      beforeEach(() => {
        atom.commands.dispatch(workspaceElement, 'update-package-dependencies:update')
        const [{exit}] = mainModule.runBufferedProcess.argsForCall[0]
        exit(0)
      })

      it('shows a success notification message', () => {
        const [notification] = atom.notifications.getNotifications()
        expect(atom.workspace.getModalPanels().length).toEqual(0)
        expect(notification.getType()).toEqual('success')
        expect(notification.getMessage()).toEqual('Success!')
      })
    })

    describe('when the update fails', () => {
      beforeEach(() => {
        atom.commands.dispatch(workspaceElement, 'update-package-dependencies:update')
        const [{exit}] = mainModule.runBufferedProcess.argsForCall[0]
        exit(127)
      })

      it('shows a failure notification', () => {
        const [notification] = atom.notifications.getNotifications()
        expect(atom.workspace.getModalPanels().length).toEqual(0)
        expect(notification.getType()).toEqual('error')
        expect(notification.getMessage()).toEqual('Error!')
      })
    })
  })
})
