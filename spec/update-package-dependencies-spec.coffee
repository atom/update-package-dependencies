childProccess = require 'child_process'
{WorkspaceView} = require 'atom'
UpdatePackageDependencies = require '../lib/update-package-dependencies'

describe "Update Package Dependencies", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.packages.activatePackage('update-package-dependencies', immediate: true)

  it "calls apm update", ->
    spyOn(childProccess, 'spawn').andReturn {on: ->}
    atom.workspaceView.trigger "update-package-dependencies:update"
    expect(childProccess.spawn).toHaveBeenCalled()
