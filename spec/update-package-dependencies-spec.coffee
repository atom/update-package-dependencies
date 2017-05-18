os = require 'os'
path = require 'path'

describe "Update Package Dependencies", ->
  [workspaceElement, mainModule, projectPath] = []

  beforeEach ->
    projectPath = __dirname
    workspaceElement = atom.views.getView(atom.workspace)
    atom.project.setPaths([projectPath])

    waitsForPromise ->
      atom.packages.activatePackage('update-package-dependencies').then (pack) ->
        {mainModule} = pack

  describe "the update-package-dependencies:update command", ->
    beforeEach ->
      spyOn(mainModule, 'runBufferedProcess')

    it "updates package dependencies", ->
      atom.commands.dispatch(workspaceElement, "update-package-dependencies:update")

      expect(mainModule.runBufferedProcess).toHaveBeenCalled()
      [{command, args, options}] = mainModule.runBufferedProcess.argsForCall[0]
      expect(command).toMatch(/\/apm$/) unless process.platform is 'win32'
      expect(command).toMatch(/\\apm.cmd$/) if process.platform is 'win32'
      expect(args).toEqual(["install"])
      expect(options.cwd).toEqual(projectPath)

    it "displays a progress modal", ->
      atom.commands.dispatch(workspaceElement, "update-package-dependencies:update")

      [modal] = atom.workspace.getModalPanels()
      expect(modal.getItem().element.querySelector(".loading")).not.toBeNull()
      expect(modal.getItem().element.textContent).toMatch(/Updating package dependencies/)

    describe "when there are multiple project paths", ->
      beforeEach ->
        atom.project.setPaths([os.tmpDir(), projectPath])

      it "uses the currently active one", ->
        waitsForPromise ->
          atom.workspace.open(path.join(projectPath, "package.json"))

        runs ->
          atom.commands.dispatch(workspaceElement, "update-package-dependencies:update")
          [{options}] = mainModule.runBufferedProcess.argsForCall[0]
          expect(options.cwd).toEqual(projectPath)

    describe "when the update succeeds", ->
      beforeEach ->
        atom.commands.dispatch(workspaceElement, "update-package-dependencies:update")
        [{exit}] = mainModule.runBufferedProcess.argsForCall[0]
        exit(0)

      it "shows a success notification message", ->
        [notification] = atom.notifications.getNotifications()
        expect(atom.workspace.getModalPanels().length).toEqual(0)
        expect(notification.getType()).toEqual("success")
        expect(notification.getMessage()).toEqual("Success!")

    describe "when the update fails", ->
      beforeEach ->
        atom.commands.dispatch(workspaceElement, "update-package-dependencies:update")
        [{exit}] = mainModule.runBufferedProcess.argsForCall[0]
        exit(127)

      it "shows a failure notification", ->
        [notification] = atom.notifications.getNotifications()
        expect(atom.workspace.getModalPanels().length).toEqual(0)
        expect(notification.getType()).toEqual("error")
        expect(notification.getMessage()).toEqual("Error!")
