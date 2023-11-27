function scrollToElement(id, container) {
  let element = document.getElementById(id);
  if (!element || !container) return;
  container.scrollTo({ top: element.offsetTop, behavior: "smooth" });
}
let Scrolling = {
  mounted() {
    this.handleEvent("scroll_to", ({ id }) => {
      scrollToElement(id, this.el);
    })
  },
}

export default Scrolling;
