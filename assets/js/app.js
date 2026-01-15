// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/pky"
import topbar from "../vendor/topbar"


// Hook to display Date/Time on client side using JS
let Hooks = {}

Hooks.LocalTime = {
  mounted() {
    this.updateTime()
    this.interval = setInterval(() => this.updateTime(), 1000)
  },
  destroyed() {
    clearInterval(this.interval)
  },
  updateTime() {
    const now = new Date()
    
    this.el.innerText = now.toLocaleString('en-AU', { 
      timeZone: 'Australia/Sydney',
      
      weekday: 'short',
      day: 'numeric',
      month: 'short',
      year: 'numeric',

      hour: '2-digit', 
      minute: '2-digit', 
      second: '2-digit' 
    })
  }
}

// Hook for reporting client side cursor location back to server
Hooks.CursorTracking = {
  mounted() {
    // Throttle the event to run at most once every 30ms
    this.handleMouseMove = this.throttle((e) => {
      // Calculate 0-100% relative to the element's dimensions
      const x = (e.pageX / this.el.offsetWidth) * 100;
      const y = (e.pageY / this.el.offsetHeight) * 100;

      this.pushEvent("cursor-move", { x, y });
    }, 30);

    // Add listener to the window so we track movement even outside the specific div
    window.addEventListener("mousemove", this.handleMouseMove);

    this.el.addEventListener("mousedown", (e) => {
      const x = (e.pageX / this.el.offsetWidth) * 100;
      const y = (e.pageY / this.el.offsetHeight) * 100;

      this.pushEvent("cursor-click", { x, y });
    });
  },

  destroyed() {
    window.removeEventListener("mousemove", this.handleMouseMove);
  },

  // Limit how often we send data to the server
  throttle(func, limit) {
    let lastFunc;
    let lastRan;
    return function() {
      const context = this;
      const args = arguments;
      if (!lastRan) {
        func.apply(context, args);
        lastRan = Date.now();
      } else {
        clearTimeout(lastFunc);
        lastFunc = setTimeout(function() {
          if ((Date.now() - lastRan) >= limit) {
            func.apply(context, args);
            lastRan = Date.now();
          }
        }, limit - (Date.now() - lastRan));
      }
    }
  }
}


const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, ...Hooks},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

