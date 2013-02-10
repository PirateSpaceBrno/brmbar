#!/usr/bin/python3

import sys

from brmbar import Database

import brmbar


def help():
    print("""BrmBar v3 (c) Petr Baudis <pasky@ucw.cz> 2012

Usage: brmbar-cli.py COMMAND ARGS...

1. Commands pertaining the standard operation
	showcredit USER
	changecredit USER +-AMT
	sellitem USER ITEM +-AMT
		You can use negative AMT to undo a sale.
 	userinfo USER
	iteminfo ITEM

2. Management commands
	listusers
		List all user accounts in the system.
	listitems
		List all item accounts in the system.
	stats
		A set of various balances as shown in the Management
		screen of the GUI.
!	changestock ITEM1 +-AMT_ITEM1 ITEM2 +-AMT_ITEM2 ...
		Create a custom transaction that will change balance
		of a variety of items at once, and either deduce
		buy price (+amt) or add sell price (-amt) to the
		cash balance for all of these items. This is useful
		e.g. after events where stock is sold offline or when
		doing an inventory recount.
		If cash balance discrepancy is discovered as well
		during the inventory recounting, first do changestock,
		then compare actual and nominal cash balance again,
		then issue changecash command if necessary.
!	changecash +-AMT
		Create a custom transaction that updates nominal cash
		balance based on the actual cash balance counted
		in the cash box. If you found more money than expected,
		use +amt, if you found less money than expected,
		use -amt.

USER and ITEM may be barcodes or account ids. AMT may be
both positive and negative amount (big difference to other
user interfaces; you can e.g. undo a sale!).

For users, you can use their name as USER as their username
is also the barcode. For items, use listitems command first
to find out the item id.

Commands prefixed with ! are not implemented yet.""")
    sys.exit(1)


def load_acct(inp):
    acct = None
    if inp.isdigit():
        acct = brmbar.Account.load(db, id = inp)
    if acct is None:
        acct = brmbar.Account.load_by_barcode(db, inp)
    if acct is None:
        print("Cannot map account " + inp, file=sys.stderr)
        exit(1)
    return acct

def load_user(inp):
    acct = load_acct(inp)
    if acct.acctype != "debt":
        print("Bad account " + inp + " type " + acct.acctype, file=sys.stderr)
        exit(1)
    return acct

def load_item(inp):
    acct = load_acct(inp)
    if acct.acctype != "inventory":
        print("Bad account " + inp + " type " + acct.acctype, file=sys.stderr)
        exit(1)
    return acct


db = Database.Database("dbname=brmbar")
shop = brmbar.Shop.new_with_defaults(db)
currency = shop.currency

if len(sys.argv) <= 1:
    help()


if sys.argv[1] == "showcredit":
    acct = load_user(sys.argv[2])
    print("{}: {}".format(acct.name, acct.negbalance_str()))

elif sys.argv[1] == "changecredit":
    acct = load_user(sys.argv[2])
    amt = int(sys.argv[3])
    if amt > 0:
        shop.add_credit(credit = amt, user = acct)
    elif amt < 0:
        shop.withdraw_credit(credit = -amt, user = acct)
    print("{}: {}".format(acct.name, acct.negbalance_str()))

elif sys.argv[1] == "sellitem":
    uacct = load_user(sys.argv[2])
    iacct = load_item(sys.argv[3])
    amt = int(sys.argv[4])
    if amt > 0:
        shop.sell(item = iacct, user = uacct, amount = amt)
    elif amt < 0:
        shop.undo_sale(item = iacct, user = uacct, amount = -amt)
    print("{}: {}".format(uacct.name, uacct.negbalance_str()))
    print("{}: {}".format(iacct.name, iacct.balance_str()))

elif sys.argv[1] == "userinfo":
    acct = load_user(sys.argv[2])
    print("{} (id {}): {}".format(acct.name, acct.id, acct.negbalance_str()))

    res = db.execute_and_fetchall("SELECT barcode FROM barcodes WHERE account = %s", [acct.id])
    print("Barcodes: " + ", ".join(map((lambda r: r[0]), res)))

elif sys.argv[1] == "iteminfo":
    acct = load_item(sys.argv[2])
    print("{} (id {}): {} pcs".format(acct.name, acct.id, acct.balance()))

    (buy, sell) = acct.currency.rates(currency)
    print("Buy: " + currency.str(buy) + "  Sell: " + currency.str(sell));

    res = db.execute_and_fetchall("SELECT barcode FROM barcodes WHERE account = %s", [acct.id])
    print("Barcodes: " + ", ".join(map((lambda r: r[0]), res)))

elif sys.argv[1] == "listusers":
    for acct in shop.account_list("debt"):
        print("{}\t{}\t{}".format(acct.name, acct.id, acct.negbalance_str()))

elif sys.argv[1] == "listitems":
    for acct in shop.account_list("inventory"):
        print("{}\t{}\t{} pcs".format(acct.name, acct.id, acct.balance()))

elif sys.argv[1] == "stats":
    print("Cash: {}".format(shop.cash.balance_str()))
    print("Profit: {}".format(shop.profits.balance_str()))
    print("Credit: {}".format(shop.credit_negbalance_str()))
    print("Inventory: {}".format(shop.inventory_balance_str()))

else:
    help()