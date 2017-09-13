import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    BarTextHint {
        x: 65
        y: 234
        hint_goal: "Koupit položku:"
        hint_action: "Nyní oscanuj QR kód"
    }

    BarcodeInput {
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Neznámý QR kód", "#ff4444")
                return
            }
            loadPageByAcct(acct)
        }
    }

    BarButton {
        x: 65
        y: 838
        width: 360
        text: "Nabít kredit"
        onButtonClick: {
            loadPage("ChargeCredit")
        }
    }

    BarButton {
        x: 450
        y: 838
        width: 360
        text: "Převést kredit"
        onButtonClick: {
            loadPage("Transfer")
        }
    }

    BarButton {
        id: management
        x: 855
        y: 838
        width: 360
        text: "Správa"
        onButtonClick: {
            loadPage("Management")
        }
    }

    BarButton {
        x: 65
        y: 438
        width: 1150
        text: "Pirate Space Brno"
    }
}
