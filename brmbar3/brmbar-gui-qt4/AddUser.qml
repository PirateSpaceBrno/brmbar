import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

	property string barcode: ""
    property string item_name: item_name_pad.enteredText

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
		focus: page.state == "normal"
		visible: true
        onAccepted: {
            var acct = shop.barcodeInput(text)
			barcode = text
            text = ""
			if (typeof(acct) != "undefined") {
				status_text.setStatus("Existující NFC tag: " + acct.name, "#ff4444")
                return
            }
			if (info.dbid === "") {
				status_text.setStatus("Nejdříve zmáčkni [Vytvořit]", "#ff4444")
				return
			}
			shop.addBarcode(dbid, barcode)
			status_text.setStatus("NFC tag přidán", "#ffff7c")
        }
    }

	Item {
		id: name_row
		visible: page.state == "normal" || page.state == "name_edit"
			x: 65
			y: 166
			width: 774
			height: 60

		Text {
			id: item_name_text
			x: 0
			y: 0
			width: 534
			height: 60
			color: "#ffff7c"
			text: page.item_name
			wrapMode: Text.WordWrap
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: 0.768 * 46
		}

		BarButton {
			id: item_name_edit
			x: 790
			y: 0
			width: 240
			height: 60
			fontSize: 0.768 * 46
			text: page.state == "name_edit" ? "Přiřadit" : "Upravit"
			onButtonClick: { if (page.state == "name_edit") page.state = "normal"; else page.state = "name_edit"; }
		}
	}

	BarKeyPad {
			id: item_name_pad
			x: 65
			y: 239
			visible: page.state == "name_edit"
			focus: page.state == "name_edit"
			Keys.onReturnPressed: { item_name_edit.buttonClick() }
			Keys.onEscapePressed: { cancel.buttonClick() }
	}


	BarButton {
		id: save
		x: 65
		y: 838
		width: 360
		text: "Vytvořit"
		onButtonClick: {
	        var xi = info;
	        xi["name"] = page.item_name;
			info = xi			
			
			var res;
			if (dbid == "") {
                res = shop.addUser(info)
                if (!res) {
                   status_text.setStatus("Nejdřív prosím vyplň jméno.", "#ff4444")
                   return
                }
            }
			
			
            if (dbid == "") {
                dbid = res.dbid
                xi = info; xi["dbid"] = page.dbid; info = xi
            } else {
                loadPage("AddUser")
            }
		}
    }

    BarButton {
        id: cancel
        x: 855
        y: 838
        width: 360
        text: "Hlavní obrazovka"
        onButtonClick: {
            status_text.setStatus("Vytváření uživatele zrušeno", "#ff4444")
            loadPage("MainPage")
        }
	}
}
