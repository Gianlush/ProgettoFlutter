import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:steam_app/graphic/AccountPage.dart';
import 'package:steam_app/model/Model.dart';
import 'package:steam_app/model/objects/Game.dart';
import 'package:steam_app/model/objects/GamePerOrder.dart';
import 'package:steam_app/model/objects/Order.dart';
import 'package:steam_app/model/objects/User.dart';
import 'package:steam_app/model/widget/AddRemoveButton.dart';
import 'package:steam_app/model/widget/GameView.dart';
import 'package:steam_app/model/widget/MyInputField.dart';

class CartPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return CartPageState();
  }
}

class CartPageState extends State<CartPage>{

  bool paying = false;
  TextEditingController textController = TextEditingController();

  static Order order = Order(
    gamePerOrder: <GamePerOrder>[],

  );

  @override
  Widget build(BuildContext context) {
    if(order.gamePerOrder.isEmpty)
      return Padding(
          padding: EdgeInsets.all(20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [Text("CART EMPTY!", style: TextStyle(fontSize: 35))]
          )
      );
    else if(paying==false)
        return Column(
          children: [
            parteSuperiore(),
            parteInferiore()
          ],
        );
    else
      return Payment();
  }

  Widget Payment() {
    GamePerOrder order = quantityExceeded();

    if(AccountPageState.user == null){
      return Padding(
          padding: EdgeInsets.all(20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("YOU MUST LOGIN FIRST!", style: TextStyle(fontSize: 35))]
          )
      );
    }
    else if(order != null){
      return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Game: ["+order.game.name+"] not available in the quantity ["+order.quantity.toString()+"]", style: TextStyle(fontSize: 35)),
                RawMaterialButton(
                  onPressed: () => refresh(paying: false),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  fillColor: Colors.deepPurple,
                  child: Text("OK", style: TextStyle(color: Colors.white),),
                )
              ]
          )
      );
    }
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              child: Container(
                  width: 600,
                  child: MyInputField(text: "Payment Method:",controller: textController, hint: "Paypal",)
              )
          ),
          RawMaterialButton(
            onPressed: () => createOrder(),
            padding: EdgeInsets.all(15),
            fillColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                Text("Confirm", style: TextStyle(color: Colors.white)),
                Icon(Icons.verified_outlined)
              ],
            ),
          ),
          RawMaterialButton(
            onPressed: () => refresh(paying: false),
            padding: EdgeInsets.all(15), fillColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                Text("Cancel", style: TextStyle(color: Colors.white)),
                Icon(Icons.cancel_outlined)
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget parteSuperiore () {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RawMaterialButton(
              onPressed: () => refresh(paying: true),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
              fillColor: Colors.deepPurple,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text("Buy Now", style: TextStyle(color: Colors.white)),
                    Icon(Icons.payment)
                  ],
                ),
              )
          )
        ],
      ),
    );
  }

  GamePerOrder quantityExceeded(){
    for(int i=0;i<order.gamePerOrder.length;i++){
      GamePerOrder x = order.gamePerOrder[i];
      if(x.quantity > x.game.quantityAvailable)
        return x;
    }
    return null;
  }

  createOrder() {
    String method = textController.text;
    if(method == "")
      return ;
    else{
      order.paymentMethod = method;
      Model.sharedInstance.createOrder(order).then( (value) {
        setState(() {
          paying = false;
          AccountPageState.user.orders.add(value);
          order.gamePerOrder.clear();
        });
      });
    }
  }

  refresh({paying: bool}){
    setState(() {
      this.paying = paying;
    });
  }

  Widget parteInferiore() {
    return Expanded(
        child: Container(
          child: ListView.builder(
            itemCount: order.gamePerOrder.length,
            itemBuilder: (context, index) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GameView(order.gamePerOrder[index].game),
                    AddRemoveButton(() => refresh(paying: false), order.gamePerOrder[index])
                  ]
              );
            },
          ),
        ),
      );
  }

  Widget Cart(){
    return Expanded(
        child: Container(
            child: ListView.builder(
                  itemCount: order.gamePerOrder.length,
                  itemBuilder: (context, index) {
                    return GameView(order.gamePerOrder[index].game);
                  },
                ),
        ),
      );
  }

}