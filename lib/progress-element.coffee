class ProgressElement extends HTMLDivElement
  createdCallback: ->
    @tabIndex = -1

  displayLoading: ->
    @innerHTML = """
      <span class="loading loading-spinner-small inline-block"></span>
      <span>
        Updating package dependencies\u2026
      </span>
    """

  displaySuccess: ->
    @innerHTML = """
      <span class="text-success">
        Package dependencies updated.
      </span>
    """

  displayFailure: ->
    @innerHTML = """
      <span class="text-error">
        Failed to update package depencencies.
      </span>
    """

module.exports =
document.registerElement("update-package-dependencies-progress",
  prototype: ProgressElement.prototype
  extends: "div"
)
