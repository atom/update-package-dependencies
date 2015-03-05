os = require "os"
UpdatePackageDependencies = require '../lib/update-package-dependencies'

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
      expect(command).toMatch(/apm$/)
      expect(args).toEqual(["install"])
      expect(options.cwd).toEqual(projectPath)

    it "displays a progress modal", ->
      atom.commands.dispatch(workspaceElement, "update-package-dependencies:update")

      [modal] = atom.workspace.getModalPanels()
      expect(modal.getItem().querySelector(".loading")).not.toBeNull()
      expect(modal.getItem().textContent).toMatch(/Updating package dependencies/)

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

      it "shows a success message in the modal", ->
        [modal] = atom.workspace.getModalPanels()
        expect(modal.getItem().querySelector(".loading")).toBeNull()
        expect(modal.getItem().textContent).toMatch(/Package dependencies updated/)

      describe "triggering core:cancel", ->
        it "dismisses the modal", ->
          [modal] = atom.workspace.getModalPanels()
          atom.commands.dispatch(modal.getItem(), 'core:cancel')
          expect(atom.workspace.getModalPanels().length).toBe(0)

    describe "when the update fails", ->
      beforeEach ->
        atom.commands.dispatch(workspaceElement, "update-package-dependencies:update")
        [{exit}] = mainModule.runBufferedProcess.argsForCall[0]
        exit(127)

      it "shows a failure message in the modal", ->
        [modal] = atom.workspace.getModalPanels()
        expect(modal.getItem().querySelector(".loading")).toBeNull()
        expect(modal.getItem().textContent).toMatch(/Failed to update package depencencies/)
