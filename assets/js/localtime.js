let LocalTime = {
  mounted() {
    this.updates()
  },
  updated() {
    let dt = new Date(this.el.textContent);
    this.el.textContent = dt.toLocaleDateString();
    this.el.classList.remove("invisible")
  }
}

return LocalTime;
