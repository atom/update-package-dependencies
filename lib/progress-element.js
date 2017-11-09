module.exports =
class ProgressElement {
  constructor () {
    this.element = document.createElement('update-package-dependencies-progress')
    this.element.tabIndex = -1
  }

  displayLoading () {
    this.element.innerHTML = `\
<span class="loading loading-spinner-small inline-block"></span>
<span>
  Updating package dependencies\u2026
</span>\
`
  }
}
