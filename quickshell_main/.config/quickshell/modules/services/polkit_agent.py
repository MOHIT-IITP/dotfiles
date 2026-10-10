#!/usr/bin/env python3
import os
import sys
import json
import threading
import signal
import gi

gi.require_version("PolkitAgent", "1.0")
gi.require_version("Polkit", "1.0")
from gi.repository import GLib, Polkit, PolkitAgent, Gio

class CustomAgentListener(PolkitAgent.Listener):
    def __init__(self):
        super().__init__()
        self.active_session = None
        self.active_task = None
        self.active_cookie = None

    def do_initiate_authentication(self, action_id, message, icon_name, details, cookie, identities, cancellable, callback, user_data):
        user_name = os.environ.get("USER", "root")
        ident = None
        if identities and len(identities) > 0:
            ident = identities[0]
            if isinstance(ident, Polkit.UnixUser):
                user_name = ident.get_name()
            else:
                user_name = str(ident)
        else:
            ident = Polkit.UnixUser.new_for_name(user_name)

        task = Gio.Task.new(self, cancellable, callback, user_data)
        self.active_task = task
        self.active_cookie = cookie

        session = PolkitAgent.Session.new(ident, cookie)
        self.active_session = session

        def on_request(s, request, echo):
            out = {
                "event": "request",
                "action_id": action_id,
                "message": message or "Authentication is required to perform this action",
                "user": user_name,
                "cookie": cookie,
                "prompt": request or "Password: ",
                "echo": bool(echo)
            }
            print(json.dumps(out), flush=True)

        def on_show_error(s, text):
            out = {
                "event": "error",
                "message": text or "Authentication failed"
            }
            print(json.dumps(out), flush=True)

        def on_show_info(s, text):
            out = {
                "event": "info",
                "message": text
            }
            print(json.dumps(out), flush=True)

        def on_completed(s, gained_authorization):
            out = {
                "event": "completed",
                "gained_authorization": bool(gained_authorization)
            }
            print(json.dumps(out), flush=True)
            self.active_session = None
            self.active_cookie = None
            if self.active_task:
                t = self.active_task
                self.active_task = None
                t.return_boolean(bool(gained_authorization))

        session.connect("request", on_request)
        session.connect("show-error", on_show_error)
        session.connect("show-info", on_show_info)
        session.connect("completed", on_completed)

        session.initiate()

    def do_initiate_authentication_finish(self, res):
        return res.propagate_boolean()

    def do_cancel_authentication(self, cookie):
        if self.active_session:
            self.active_session.cancel()
            self.active_session = None
            self.active_cookie = None
        if self.active_task:
            t = self.active_task
            self.active_task = None
            t.return_boolean(False)
        out = {"event": "cancelled"}
        print(json.dumps(out), flush=True)
        return True

def main():
    loop = GLib.MainLoop()
    listener = CustomAgentListener()

    subject = Polkit.UnixSession.new_for_process_sync(os.getpid(), None)
    handle = listener.register(
        PolkitAgent.RegisterFlags.NONE,
        subject,
        "/org/freedesktop/PolicyKit1/AuthenticationAgent",
        None
    )

    print(json.dumps({"event": "ready", "handle": str(handle)}), flush=True)

    def handle_ipc(msg):
        action = msg.get("action", "")
        if action == "response":
            pw = msg.get("password", "")
            if listener.active_session:
                listener.active_session.response(pw)
        elif action == "cancel":
            if listener.active_session:
                listener.active_session.cancel()
                listener.active_session = None
                listener.active_cookie = None
            if listener.active_task:
                t = listener.active_task
                listener.active_task = None
                t.return_boolean(False)
        elif action == "ping":
            print(json.dumps({"event": "pong"}), flush=True)

    def stdin_thread():
        while True:
            try:
                line = sys.stdin.readline()
                if not line:
                    break
                line = line.strip()
                if not line:
                    continue
                data = json.loads(line)
                GLib.idle_add(handle_ipc, data)
            except Exception as e:
                pass
        GLib.idle_add(loop.quit)

    t = threading.Thread(target=stdin_thread, daemon=True)
    t.start()

    def sig_handler(sig, frame):
        GLib.idle_add(loop.quit)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    try:
        loop.run()
    finally:
        try:
            listener.unregister(handle)
        except Exception:
            pass

if __name__ == "__main__":
    main()
