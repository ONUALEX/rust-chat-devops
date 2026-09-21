#!/bin/bash
# Run from the project root. Makes the frontend connect to whatever address
# the site is served from (through Nginx at /api/) instead of 127.0.0.1:8000.
set -e
python3 - <<'PY'
main = "frontend/src/main.rs"
toml = "frontend/Cargo.toml"

s = open(main).read()
old = '"ws://127.0.0.1:8000".to_string()'
if "fn ws_url()" in s:
    print("main.rs: already patched")
elif old not in s:
    print("main.rs: could not find the ws://127.0.0.1:8000 line - tell Claude")
else:
    s = s.replace(old, "ws_url()")
    s += '''

// Connects through Nginx at /api/, on localhost AND on the server.
fn ws_url() -> String {
    let location = web_sys::window().expect("no window").location();
    let scheme = if location.protocol().unwrap_or_default() == "https:" { "wss" } else { "ws" };
    let host = location.host().unwrap_or_default();
    format!("{}://{}/api/", scheme, host)
}
'''
    open(main, "w").write(s)
    print("main.rs: patched")

t = open(toml).read()
old_f = 'features = ["HtmlTextAreaElement"]'
new_f = 'features = ["HtmlTextAreaElement", "Window", "Location"]'
if new_f in t:
    print("Cargo.toml: already patched")
elif old_f not in t:
    print("Cargo.toml: could not find web-sys features - tell Claude")
else:
    open(toml, "w").write(t.replace(old_f, new_f))
    print("Cargo.toml: patched")
PY
