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

module.exports =
document.registerElement("update-package-dependencies-progress",
  prototype: ProgressElement.prototype
  extends: "div"
)
