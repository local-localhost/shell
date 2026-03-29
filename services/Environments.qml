pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import qs.utils

Singleton {
    id: root

    property string currentId: "default"
    property string pendingId: ""
    property bool loaded: false

    readonly property bool switching: writeProc.running
    readonly property string configPath: `${Paths.config}/hypr-environment.conf`
    readonly property var list: [
        {
            id: "default",
            name: qsTr("Default"),
            icon: "auto_fix_high",
            description: qsTr("Base Caelestia environment variables.")
        },
        {
            id: "kvm",
            name: qsTr("KVM"),
            icon: "computer",
            description: qsTr("Software rendering tweaks for virtual machines.")
        },
        {
            id: "nvidia",
            name: qsTr("Nvidia"),
            icon: "memory",
            description: qsTr("NVIDIA-specific Wayland environment variables.")
        }
    ]
    readonly property var current: root.list.find(option => option.id === root.currentId) ?? root.list[0]

    function _sourceLine(id: string): string {
        return `source = $hl/environments/${id}.conf`;
    }

    function _escapeSingleQuotes(text: string): string {
        return text.replace(/'/g, "'\\''");
    }

    function _updateCurrent(text: string): void {
        const match = text.match(/source\s*=\s*(?:.+\/)?([A-Za-z0-9_-]+)\.conf/);
        const id = match?.[1] ?? "default";
        root.currentId = root.list.some(option => option.id === id) ? id : "default";
        root.loaded = true;
    }

    function _write(id: string, reload: bool): void {
        if (!root.list.some(option => option.id === id))
            return;

        pendingId = id;
        const line = _escapeSingleQuotes(_sourceLine(id));
        const configDir = _escapeSingleQuotes(Paths.config);
        const path = _escapeSingleQuotes(root.configPath);
        writeProc.command = ["sh", "-c", `mkdir -p '${configDir}' && printf '%s\n' '${line}' > '${path}'${reload ? " && hyprctl reload" : ""}`];
        writeProc.running = true;
    }

    function ensure(): void {
        _write(root.currentId || "default", false);
    }

    function setCurrent(id: string): void {
        if (root.switching || id === root.currentId)
            return;

        _write(id, true);
    }

    FileView {
        id: environmentView

        path: root.configPath
        watchChanges: true

        onFileChanged: reload()
        onLoaded: root._updateCurrent(text())
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.loaded = true;
                root.currentId = "default";
                root.ensure();
            } else {
                Toaster.toast(qsTr("Failed to read environment config"), FileViewError.toString(err), "settings_alert", Toast.Warning);
            }
        }
    }

    Process {
        id: writeProc

        stderr: StdioCollector {
            onStreamFinished: {
                const error = text.trim();
                if (error.length > 0)
                    console.warn("Environment switch error:", error);
            }
        }

        onRunningChanged: {
            if (running)
                return;

            environmentView.reload();
            if (typeof writeProc.exitCode !== "undefined" && writeProc.exitCode !== 0)
                Toaster.toast(qsTr("Failed to switch environment"), qsTr("Could not update Hyprland environment"), "settings_alert", Toast.Error);

            root.pendingId = "";
        }
    }
}
