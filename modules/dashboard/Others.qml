import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.controls
import qs.services
import qs.config

Item {
    id: root

    implicitWidth: Math.max(900, content.implicitWidth)
    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: Appearance.spacing.small / 2

                StyledText {
                    text: qsTr("Others")
                    font.pointSize: Appearance.font.size.extraLarge
                    font.weight: 600
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    text: qsTr("Environment variants and keyboard notification toggles.")
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledRect {
                radius: Appearance.rounding.full
                color: Colours.tPalette.m3surfaceContainerHigh
                implicitWidth: activeRow.implicitWidth + Appearance.padding.large * 2
                implicitHeight: activeRow.implicitHeight + Appearance.padding.normal * 2

                RowLayout {
                    id: activeRow

                    anchors.centerIn: parent
                    spacing: Appearance.spacing.small

                    MaterialIcon {
                        text: Environments.switching ? "sync" : "check_circle"
                        color: Environments.switching ? Colours.palette.m3tertiary : Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.normal
                        animate: Environments.switching
                    }

                    StyledText {
                        text: Environments.switching ? qsTr("Applying %1").arg((Environments.list.find(option => option.id === Environments.pendingId) ?? Environments.current).name) : qsTr("Active: %1").arg(Environments.current.name)
                        color: Colours.palette.m3onSurface
                        font.weight: 500
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Appearance.spacing.normal

            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 470
                radius: Appearance.rounding.large
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large
                    spacing: Appearance.spacing.normal

                    ColumnLayout {
                        spacing: Appearance.spacing.small / 2

                        StyledText {
                            text: qsTr("Environment Variants")
                            font.pointSize: Appearance.font.size.large
                            font.weight: 600
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: qsTr("Same variants as the donor dotfiles: Default, KVM and Nvidia.")
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }

                    Repeater {
                        model: ScriptModel {
                            values: Environments.list
                        }

                        delegate: EnvironmentCard {
                            environment: modelData
                        }
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 380
                radius: Appearance.rounding.large
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large
                    spacing: Appearance.spacing.normal

                    ColumnLayout {
                        spacing: Appearance.spacing.small / 2

                        StyledText {
                            text: qsTr("Keyboard Toasts")
                            font.pointSize: Appearance.font.size.large
                            font.weight: 600
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: qsTr("Choose which keyboard state changes should show notifications.")
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }

                    ToastToggleCard {
                        iconName: "keyboard"
                        title: qsTr("Layout changes")
                        description: qsTr("Notify when the active keyboard layout changes.")
                        checked: Config.utilities.toasts.kbLayoutChanged
                        onToggled: checked => {
                            Config.utilities.toasts.kbLayoutChanged = checked;
                            Config.save();
                        }
                    }

                    ToastToggleCard {
                        iconName: "keyboard_capslock"
                        title: qsTr("Caps Lock")
                        description: qsTr("Notify when Caps Lock is enabled or disabled.")
                        checked: Config.utilities.toasts.capsLockChanged
                        onToggled: checked => {
                            Config.utilities.toasts.capsLockChanged = checked;
                            Config.save();
                        }
                    }

                    ToastToggleCard {
                        iconName: "looks_one"
                        title: qsTr("Num Lock")
                        description: qsTr("Notify when Num Lock is enabled or disabled.")
                        checked: Config.utilities.toasts.numLockChanged
                        onToggled: checked => {
                            Config.utilities.toasts.numLockChanged = checked;
                            Config.save();
                        }
                    }
                }
            }
        }
    }

    component EnvironmentCard: StyledRect {
        id: environmentCard

        required property var environment

        readonly property bool selected: Environments.currentId === environment.id
        readonly property bool pending: Environments.pendingId === environment.id

        Layout.fillWidth: true
        implicitHeight: cardRow.implicitHeight + Appearance.padding.large * 2
        radius: Appearance.rounding.normal
        color: selected ? Colours.tPalette.m3primaryContainer : Colours.tPalette.m3surfaceContainerHigh
        border.width: selected ? 1 : 0
        border.color: selected ? Colours.palette.m3primary : "transparent"

        RowLayout {
            id: cardRow

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            StyledRect {
                Layout.alignment: Qt.AlignTop
                implicitWidth: Appearance.font.size.extraLarge * 2
                implicitHeight: implicitWidth
                radius: Appearance.rounding.normal
                color: selected ? Qt.alpha(Colours.palette.m3primary, 0.18) : Colours.tPalette.m3surfaceContainerHighest

                MaterialIcon {
                    anchors.centerIn: parent
                    text: environment.icon
                    color: selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small / 2

                StyledText {
                    text: environment.name
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: environment.description
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            StyledRect {
                Layout.alignment: Qt.AlignVCenter
                radius: Appearance.rounding.full
                color: selected ? Qt.alpha(Colours.palette.m3primary, 0.18) : Colours.tPalette.m3surfaceContainerHighest
                implicitWidth: statusRow.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: statusRow.implicitHeight + Appearance.padding.small

                RowLayout {
                    id: statusRow

                    anchors.centerIn: parent
                    spacing: Appearance.spacing.small / 2

                    MaterialIcon {
                        text: pending ? "sync" : (selected ? "check" : "arrow_forward")
                        color: selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.normal
                        animate: pending
                    }

                    StyledText {
                        text: pending ? qsTr("Applying") : (selected ? qsTr("Active") : qsTr("Use"))
                        color: selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        font.weight: 500
                    }
                }
            }
        }

        StateLayer {
            disabled: Environments.switching
            color: selected ? Colours.palette.m3primary : Colours.palette.m3onSurface
            onClicked: Environments.setCurrent(environment.id)
        }
    }

    component ToastToggleCard: StyledRect {
        id: toggleCard

        required property string iconName
        required property string title
        required property string description
        required property bool checked
        property var onToggled: function (checked) {}

        Layout.fillWidth: true
        implicitHeight: toggleRow.implicitHeight + Appearance.padding.large * 2
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainerHigh

        RowLayout {
            id: toggleRow

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            StyledRect {
                Layout.alignment: Qt.AlignTop
                implicitWidth: Appearance.font.size.extraLarge * 2
                implicitHeight: implicitWidth
                radius: Appearance.rounding.normal
                color: Qt.alpha(Colours.palette.m3tertiary, 0.16)

                MaterialIcon {
                    anchors.centerIn: parent
                    text: toggleCard.iconName
                    color: Colours.palette.m3tertiary
                    font.pointSize: Appearance.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small / 2

                StyledText {
                    text: toggleCard.title
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: toggleCard.description
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            StyledSwitch {
                Layout.alignment: Qt.AlignVCenter
                checked: toggleCard.checked
                onToggled: toggleCard.onToggled(checked) // qmllint disable use-proper-function
            }
        }
    }
}
