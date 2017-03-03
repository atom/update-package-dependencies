module.exports =
class ProgressElement
  constructor: ->
    @element = document.createElement("update-package-dependencies-progress")
    @element.tabIndex = -1

  displayLoading: ->
    @element.innerHTML = """
      <span class="loading loading-spinner-small inline-block"></span>
      <span>
        Updating package dependencies\u2026
      </span>
    """

  displaySuccess: ->
    @element.innerHTML = """
      <span class="text-success">
        Package dependencies updated.
      </span>
    """

  displayFailure: ->
    @element.innerHTML = """
      <span class="text-error">
        Failed to update package dependencies.
      </span>
    """
