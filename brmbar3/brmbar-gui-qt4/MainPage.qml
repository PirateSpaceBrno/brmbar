// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    BarTextHint {
        x: 65
        y: 234
        hint_goal: "Buy item:"
        hint_action: "Scan barcode now"
    }

    BarcodeInput {
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            loadPageByAcct(acct)
        }
    }

    BarButton {
        id: withdraw
        x: 65
        y: 430
        width: 360
        text: "Select Item"
        fontSize: 60
	btnColor: "#666666"
    }

    BarButton {
        x: 599
        y: 430
        width: 360
        text: "Credit"
        onButtonClick: {
            loadPage("ChargeCredit")
        }
    }

    BarButton {
        id: select_item
        x: 65
        y: 582
        width: 360
        text: "Receipt"
        onButtonClick: {
            loadPage("Receipt")
        }
    }

    BarButton {
        id: management
        x: 599
        y: 582
        width: 360
        text: "Management"
        onButtonClick: {
            loadPage("Management")
        }
    }
}
