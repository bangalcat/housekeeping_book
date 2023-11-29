function scrollToElement(id, container, is_window = false) {
  let element = document.getElementById(id);
  if (!element || !container) return;
  if (is_window)
    document.getElementById("main-container").scrollTo({ top: element.offsetTop, behavior: "smooth" });
  else
    container.scrollTo({ top: element.offsetTop, behavior: "smooth" });
}
let Scrolling = {
  mounted() {
    this.handleEvent("scroll_to", ({ id, is_window }) => {
      scrollToElement(id, this.el, is_window);
    })
  },
}

export default Scrolling;
