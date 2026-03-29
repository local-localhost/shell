import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.controls
import qs.services
import qs.config

SectionContainer {
    id: root

    required property var rootItem
    property bool keyboardLayoutNotifications: Config.utilities.toasts.kbLayoutChanged ?? true
    property bool capsLockNotifications: Config.utilities.toasts.capsLockChanged ?? true
    property bool numLockNotifications: Config.utilities.toasts.numLockChanged ?? true

    Layout.fillWidth: true
    alignTop: true

    function saveKeyboardToastConfig(): void {
        Config.utilities.toasts.kbLayoutChanged = root.keyboardLayoutNotifications;
        Config.utilities.toasts.capsLockChanged = root.capsLockNotifications;
        Config.utilities.toasts.numLockChanged = root.numLockNotifications;
        Config.save();
    }

    StyledText {
        text: qsTr("Others")
        font.pointSize: Appearance.font.size.normal
    }

    SplitButtonRow {
        id: environmentSelector

        function syncActiveItem(): void {
            active = Environments.currentId === "kvm" ? kvmItem : Environments.currentId === "nvidia" ? nvidiaItem : defaultItem;
        }

        Layout.fillWidth: true
        z: expanded ? 100 : 0
        label: qsTr("Environment")
        menuItems: [defaultItem, kvmItem, nvidiaItem]
        enabled: !Environments.switching

        Component.onCompleted: syncActiveItem()

        Connections {
            function onCurrentIdChanged(): void {
                environmentSelector.syncActiveItem();
            }

            target: Environments
        }

        MenuItem {
            id: defaultItem

            text: qsTr("Default")
            icon: "auto_fix_high"
            activeText: qsTr("Default")
            onClicked: Environments.setCurrent("default")
        }

        MenuItem {
            id: kvmItem

            text: qsTr("KVM")
            icon: "computer"
            activeText: qsTr("KVM")
            onClicked: Environments.setCurrent("kvm")
        }

        MenuItem {
            id: nvidiaItem

            text: qsTr("Nvidia")
            icon: "memory"
            activeText: qsTr("Nvidia")
            onClicked: Environments.setCurrent("nvidia")
        }
    }

    StyledText {
        text: Environments.switching ? qsTr("Applying %1").arg((Environments.list.find(option => option.id === Environments.pendingId) ?? Environments.current).name) : qsTr("Active: %1").arg(Environments.current.name)
        font.pointSize: Appearance.font.size.small
        color: Colours.palette.m3onSurfaceVariant
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: Appearance.spacing.normal
        rowSpacing: Appearance.spacing.normal

        SwitchRow {
            id: keyboardLayoutChanged

            Layout.fillWidth: true
            label: qsTr("Keyboard layout changes")
            checked: root.keyboardLayoutNotifications
            onToggled: checked => {
                root.keyboardLayoutNotifications = checked;
                root.saveKeyboardToastConfig();
            }
        }

        SwitchRow {
            id: capsLockChanged

            Layout.fillWidth: true
            label: qsTr("Caps lock changes")
            checked: root.capsLockNotifications
            onToggled: checked => {
                root.capsLockNotifications = checked;
                root.saveKeyboardToastConfig();
            }
        }

        SwitchRow {
            id: numLockChanged

            Layout.fillWidth: true
            label: qsTr("Num lock changes")
            checked: root.numLockNotifications
            onToggled: checked => {
                root.numLockNotifications = checked;
                root.saveKeyboardToastConfig();
            }
        }
    }
}
