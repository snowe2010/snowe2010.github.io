// Sets all root variables to solarized dark versions
function setDark() {
  console.log('set dark')
  root.style.setProperty('--base-color', 'var(--so-base3)');
  root.style.setProperty('--base-lighten-color', 'var(--so-base2)');
  root.style.setProperty('--background-color', 'var(--so-base03)');
  root.style.setProperty('--background-over-color', 'var(--so-base02)');
  root.style.setProperty('--text-color', 'var(--so-base0)');
  root.style.setProperty('--link-color', 'var(--so-violet)');
  root.style.setProperty('--code-color', 'var(--so-base0)');
  root.style.setProperty('--code-background-color', 'var(--so-base02)');
  root.style.setProperty('--table-border-color', 'var(--so-base01)');
  root.style.setProperty('--table-background-color', 'var(--so-base02)');
  root.style.setProperty('--divider-color', 'var(--so-base02)');
}

// Sets all root variables to solarized light versions
function setLight() {
  console.log('set light')
  root.style.setProperty('--base-color', 'var(--so-base01)');
  root.style.setProperty('--base-lighten-color', 'var(--so-base02)');
  root.style.setProperty('--background-color', 'var(--so-base3)');
  root.style.setProperty('--background-over-color', 'var(--so-base2)');
  root.style.setProperty('--text-color', 'var(--so-base00)');
  root.style.setProperty('--link-color', 'var(--so-violet)');
  root.style.setProperty('--code-color', 'var(--so-base02)');
  root.style.setProperty('--code-background-color', 'var(--so-base2)');
  root.style.setProperty('--table-border-color', 'var(--so-base1)');
  root.style.setProperty('--table-background-color', 'var(--so-base2)');
  root.style.setProperty('--divider-color', 'var(--so-base2)');
}

// run as soon as loaded (early as possible to avoid page flickering)
let root = document.documentElement;
var store = window.localStorage;
var night = store.getItem('nightMode');
if (!night) {
  night = 'light'; // default to light 
}
night === 'light' ? setLight() : setDark();

window.onload = function () {
  let root = document.documentElement;
  var store = window.localStorage;
  var night = store.getItem('nightMode');
  if (!night) {
    night = 'light'; // default to light 
  }
  // run a second time after page loaded to set the toggle to the correct value
  if (night === 'light') {
    setLight();
    document.getElementById("toggle--daynight").checked = true;
  } else {
    setDark();
    document.getElementById("toggle--daynight").checked = false;
  }

  // run on each click. 
  document.getElementById("toggle--daynight").onclick = function toggle() {
    let night = store.getItem('nightMode');
    if (night === 'light') {
      setDark();
      store.setItem('nightMode', 'dark');
    } else {
      setLight();
      store.setItem('nightMode', 'light');
    }
  }
}