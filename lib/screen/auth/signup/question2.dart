import 'package:flutter/material.dart';
import 'package:gp1_7_2022/config/palette.dart';
import 'package:gp1_7_2022/model/SignUpCheckboxes.dart';



class question2 extends StatefulWidget {
  @override
  _question2State createState() => _question2State();
}



class _question2State extends State<question2> {

 // final items2 = ['item 1', 'item 2', 'item 3', 'item 4', 'item 5'];
  //String? value;

final checkboxes = [
  SignUpCheckboxes(title: 'Option 1'),
  SignUpCheckboxes(title: 'Option 2'),
  SignUpCheckboxes(title: 'Option 3'),
  SignUpCheckboxes(title: 'Option 4'),


];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: Palette.backgroundColor,
        elevation: 0,//no shadow
        automaticallyImplyLeading: false,//no arrow
      ),


    body: Column(

        children: [

          Container(
          //  margin:  const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 40),
            child:const Center(
              child: Text(
                "Question 2",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),





      ...checkboxes.map(buildSingleCheckbox).toList(),



/*next button*/
          Container(

            margin: EdgeInsets.symmetric(vertical: 70),
            alignment: Alignment.center,
            width: 350,
            height: 50.0,
            /*button colors*/
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              gradient: LinearGradient(
                  colors: [
                    Palette.buttonColor,
                    Palette.nameColor,
                  ]
              ),
            ),


            /*button*/
            child: ButtonTheme(
              height: 50.0,
              minWidth: 350,
              child: FlatButton(onPressed: (){
                /*go to sign up page*/
                Navigator.pushNamed(context, '/question3');
              },
                child: Text('Next',
                  style: TextStyle(
                    color: Palette.backgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          /*end of next button */




  ],
    ),
  );



  Widget buildSingleCheckbox(SignUpCheckboxes checkboxes) => buildCheckbox(
    checkboxes: checkboxes,
  onClicked: (){
    setState(() {
      final newValue = !checkboxes.value;
      checkboxes.value = newValue;
    });
  },
);



  Widget buildCheckbox({
required SignUpCheckboxes checkboxes,
required VoidCallback onClicked,


}) => ListTile(
    onTap: onClicked,
     leading: Checkbox(
    value: checkboxes.value,
    onChanged: (value) => onClicked(),
  ),
    title: Text(
      checkboxes.title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold
      ),

    )
  );



  }

