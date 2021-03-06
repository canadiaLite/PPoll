import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';
import 'dart:collection';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'key.dart';
import 'package:collection/collection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';

int color;

List<Color> colors = [
  Colors.pink[800],
  Colors.red[800],
  Colors.deepOrange[800],
  Colors.orange[800],
  Colors.amber[800],
  Colors.yellow[800],
  Colors.lime[800],
  Colors.lightGreen[800],
  Colors.green[800],
  Colors.teal[800],
  Colors.cyan[800],
  Colors.lightBlue[800],
  Colors.blue[800],
  Colors.indigo,
  Colors.purple,
  Colors.deepPurple,
  Colors.blueGrey,
  Colors.grey
];

SettingsInfo settings = new SettingsInfo();

CreatedInfo createdInfo = new CreatedInfo();

List<String> createdPolls;

String userId;

void main(){
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
  createdInfo.readData().then((r){
    createdPolls = r!=null?r:new List<String>();
  });
  settings.readData().then((list) async{
    if(list==null){
      Map<String,dynamic> users;
      await http.get(Uri.encodeFull(database+"/users.json?auth="+secretKey)).then((r){
        users = json.decode(r.body);
      });
      do{
        userId = "";
        Random r = new Random();
        List<String> nums = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
        for(int i = 0;i<16;i++){
          userId+=(r.nextInt(2)==0?nums[r.nextInt(36)]:nums[r.nextInt(36)].toLowerCase());
        }
      }while(users!=null&&users.keys.contains(userId));
      if(users==null){
        users = new Map<String,dynamic>();
      }
      http.put(Uri.encodeFull(database+"/users/"+userId+".json?auth="+secretKey),body:"0").then((r){
        color = 16;
        settings.writeData("16 "+userId).then((f){
          runApp(new DynamicTheme(
            themedWidgetBuilder: (context, theme){
              return new MaterialApp(
                  theme: theme,
                  debugShowCheckedModeBanner: false,
                  home: new HomePage()
              );
            },
            data: (brightness) => new ThemeData(fontFamily: "Poppins",brightness: Brightness.light, canvasColor: colors[color],buttonColor: Colors.black38),
            defaultBrightness: Brightness.light,
          ));
        });
      });
    }else{
      color = int.parse(list[0]);
      userId = list[1];
      runApp(new DynamicTheme(
        themedWidgetBuilder: (context, theme){
          return new MaterialApp(
              theme: theme,
              debugShowCheckedModeBanner: false,
              home: new HomePage()
          );
        },
        data: (brightness) => new ThemeData(fontFamily: "Poppins",brightness: Brightness.light, canvasColor: colors[color],buttonColor: Colors.black38),
        defaultBrightness: Brightness.light,
      ));
    }
  });
}


class HomePage extends StatefulWidget{
  @override
  HomePageState createState() => new HomePageState();
}

//Height: 640
//Width: 360

class HomePageState extends State<HomePage>{

  String input = "";

  FocusNode f = new FocusNode();

  bool isConnectingForVV = false;

  @override
  Widget build(BuildContext context){
    if(MediaQuery.of(context).size.width>MediaQuery.of(context).size.height){
      return new Scaffold(
          backgroundColor: Colors.white,
          body: new Container(
              child: new Center(
                // ignore: conflicting_dart_import
                  child: new Text("Please switch to portrait mode",textAlign: TextAlign.center,style:new TextStyle(fontSize:30*MediaQuery.of(context).size.width/640.0))
              )
          )
      );
    }
    if(f.hasFocus&&MediaQuery.of(context).viewInsets.bottom==0){
      f.unfocus();
    }
    return new Scaffold(
        appBar: MediaQuery.of(context).viewInsets.bottom==0?new AppBar(
            backgroundColor: Colors.transparent,
            leading: new IconButton(
                icon: new Icon(Icons.palette),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context){
                        return new Container(
                          width: MediaQuery.of(context).size.width * .7,
                          child: new BackdropFilter(filter: new ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),child: new GridView.count(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                              padding: const EdgeInsets.all(4.0),
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                              children: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17].map((i)=>new ColorSelection(i)).toList()
                          )),
                        );
                      }
                  );
                  return;
                }
            ),
            actions: [
              new IconButton(
                  icon: new Icon(Icons.search),
                  onPressed: (){
                    Navigator.push(context,new MaterialPageRoute(builder: (context) => new SearchPage(false)));
                  }
              )
            ],
            elevation: 0.0
        ):new PreferredSize(child: new Container(),preferredSize: new Size(0.0,0.0)),
        body: new Container(
            child: new Center(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MediaQuery.of(context).viewInsets.bottom==0?new Text("PPoll",style: new TextStyle(fontSize:80.0*MediaQuery.of(context).size.width/375.0,fontWeight: FontWeight.w100)):new Container(),
                      new Container(height: 75.0*MediaQuery.of(context).size.width/375.0,width:250.0*MediaQuery.of(context).size.width/375.0,child: new RaisedButton(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0*MediaQuery.of(context).size.width/360.0)),
                        child: new Text("Create a Poll",style: new TextStyle(fontSize:30.0*MediaQuery.of(context).size.width/360.0,color:Colors.white70)),
                        onPressed: (){
                          f.unfocus();
                          Navigator.push(context,new MaterialPageRoute(builder: (context) => new CreatePoll()));
                        },
                      )),
                      new Container(height: 35.0*MediaQuery.of(context).size.width/375.0,width:170.0*MediaQuery.of(context).size.width/375.0,child: new RaisedButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0*MediaQuery.of(context).size.width/360.0)),
                          child: new Text("My Created Polls",style: new TextStyle(fontSize:15.0*MediaQuery.of(context).size.width/360.0,color:Colors.white70)),
                          onPressed: (){
                            f.unfocus();
                            Navigator.push(context,new MaterialPageRoute(builder: (context) => new SearchPage(true)));
                          },
                          color: Colors.black26
                      )),
                      new Container(),new Container(),
                      new Container(width: 120.0*MediaQuery.of(context).size.width/360,child: new Center(child: new TextField(
                          style: new TextStyle(fontSize: 25.0*MediaQuery.of(context).size.width/360,color:Colors.black),
                          textAlign: TextAlign.center,
                          autocorrect: false,
                          decoration: InputDecoration(
                              hintText: 'Code',
                              filled: true,
                              fillColor: Colors.white24
                          ),
                          onChanged: (s){
                            input=s;
                          },
                          focusNode: f,
                          inputFormatters: [new UpperCaseTextFormatter()]
                      ))),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new Container(height: 50.0*MediaQuery.of(context).size.width/360,width: 100.0*MediaQuery.of(context).size.width/360,child: new RaisedButton(
                                shape:RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0*MediaQuery.of(context).size.width/360.0)),
                                child: new Text("View",style: new TextStyle(fontSize: 20.0*MediaQuery.of(context).size.width/360,color:Colors.white70)),
                                onPressed: (){
                                  if(!isConnectingForVV){
                                    isConnectingForVV = true;
                                    if(input==null||input.length<4){
                                      isConnectingForVV = false;
                                      f.unfocus();
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return new AlertDialog(
                                                title:new Text("Error"),
                                                content: new Text("Invalid code"),
                                                actions: [
                                                  new RaisedButton(
                                                      child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      color: Colors.grey
                                                  )
                                                ]
                                            );
                                          }
                                      );
                                      return;
                                    }
                                    http.get(Uri.encodeFull(database+"/data/"+input+".json?auth="+secretKey)).then((r){
                                      isConnectingForVV = false;
                                      f.unfocus();
                                      Map<String,dynamic> map = json.decode(r.body);
                                      if(r.body!="null") {
                                        Navigator.push(context,new MaterialPageRoute(builder: (context) => new ViewOrVote(input,false,map["q"],map["c"],map["b"][1]==0,map["b"][0]==0,map["a"],map["b"][2]==0,map["i"]!=null&&map["i"].contains(userId),map["b"].length==4&&map["b"][3]==1)));
                                      }else{
                                        showDialog(
                                            context: context,
                                            builder: (context){
                                              return new AlertDialog(
                                                  title:new Text("Error"),
                                                  content: new Text("Poll not found"),
                                                  actions: [
                                                    new RaisedButton(
                                                        child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                        onPressed: (){
                                                          Navigator.of(context).pop();
                                                        },
                                                        color: Colors.grey
                                                    )
                                                  ]
                                              );
                                            }
                                        );
                                      }
                                    }).catchError((o){
                                      isConnectingForVV = false;
                                      return new Future<Object>(()=>o);
                                    });
                                  }
                                }
                            )),
                            new Container(height: 50.0*MediaQuery.of(context).size.width/360, width: 100.0*MediaQuery.of(context).size.width/360,child: new RaisedButton(
                                child: new Text("Vote",style: new TextStyle(fontSize: 20.0*MediaQuery.of(context).size.width/360,color:Colors.white70)),
                                shape:RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0*MediaQuery.of(context).size.width/360.0)),
                                onPressed: (){
                                  if(!isConnectingForVV){
                                    isConnectingForVV = true;
                                    if(input==null||input.length<4){
                                      f.unfocus();
                                      isConnectingForVV = false;
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return new AlertDialog(
                                                title:new Text("Error"),
                                                content: new Text("Invalid code"),
                                                actions: [
                                                  new RaisedButton(
                                                      child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      color: Colors.grey
                                                  )
                                                ]
                                            );
                                          }
                                      );
                                      return;
                                    }
                                    http.get(Uri.encodeFull(database+"/data/"+input+".json?auth="+secretKey)).then((r){
                                      f.unfocus();
                                      isConnectingForVV = false;
                                      Map<String,dynamic> map = json.decode(r.body);
                                      if(r.body!="null") {
                                        if(map["b"][1]==0) {
                                          if (map["i"]==null||!map["i"].contains(userId)) {
                                            Navigator.push(context,new MaterialPageRoute(builder: (context) => new ViewOrVote(input,true,map["q"],map["c"],true,map["b"][0]==0,map["a"],map["b"][2]==0,map["i"]!=null&&map["i"].contains(userId),map["b"].length==4&&map["b"][3]==1)));
                                          }else {
                                            showDialog(
                                                context: context,
                                                builder: (context){
                                                  return new AlertDialog(
                                                      title:new Text("Error"),
                                                      content: new Text("You have already answered this poll."),
                                                      actions: [
                                                        new RaisedButton(
                                                            child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                            onPressed: (){
                                                              Navigator.of(context).pop();
                                                            },
                                                            color: Colors.grey
                                                        )
                                                      ]
                                                  );
                                                }
                                            );
                                          }
                                        }else{
                                          Navigator.push(context,new MaterialPageRoute(builder: (context) => new ViewOrVote(input,true,map["q"],map["c"],false,map["b"][0]==0,map["a"],map["b"][2]==0,map["i"]!=null&&map["i"].contains(userId),map["b"].length==4&&map["b"][3]==1)));
                                        }
                                      }else{
                                        showDialog(
                                            context: context,
                                            builder: (context){
                                              return new AlertDialog(
                                                  title:new Text("Error"),
                                                  content: new Text("Poll not found"),
                                                  actions: [
                                                    new RaisedButton(
                                                        child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                        onPressed: (){
                                                          Navigator.of(context).pop();
                                                        },
                                                        color: Colors.grey
                                                    )
                                                  ]
                                              );
                                            }
                                        );
                                      }
                                    }).catchError((o){
                                      isConnectingForVV = false;
                                      return new Future<Object>(()=>o);
                                    });
                                  }
                                }
                            )),
                          ]
                      ),
                      new Container(),
                      new Container()
                    ]
                )
            )
        )
    );
  }
}

class ColorSelection extends StatelessWidget{
  final int index;

  ColorSelection(this.index);

  @override
  Widget build(BuildContext context) {
    return new GridTile(
        child: new GestureDetector(
            child: new Container(
                color: new Color(colors[index].value)
            ),
            onTapUp: (t){
              color = index;
              settings.writeData(color.toString()+" "+userId);
              DynamicTheme.of(context).setThemeData(new ThemeData(fontFamily: "Poppins",brightness: Brightness.light, canvasColor: colors[color],buttonColor:Colors.black38));
              Navigator.of(context).pop();
            }
        )
    );
  }
}

class SearchPage extends StatefulWidget{

  bool onlyCreated;

  SearchPage(this.onlyCreated);

  @override
  SearchPageState createState() => new SearchPageState();
}

class SearchPageState extends State<SearchPage>{

  static Map<String, dynamic> data;
  @override
  void initState(){
    super.initState();
    sorting = widget.onlyCreated?"newest":"top";
    s.addListener((){
      if((s.hasClients&&s.position.pixels>1&&!visible)){
        visible = true;
        setState((){});
      }else if((!(s.hasClients&&s.position.pixels>1)&&visible)){
        visible = false;
        setState((){});
      }
    });
    http.get((Uri.encodeFull(database+"/data.json?auth="+secretKey))).then((r){
      setState((){data = json.decode(r.body);});
    });
  }

  String search = "";

  bool inSearch = false;

  bool hasSearched = false;

  FocusNode f = new FocusNode();

  TextEditingController c = new TextEditingController();

  ScrollController s = new ScrollController();

  bool visible = false;

  String sorting;

  @override
  Widget build(BuildContext context){
    if(MediaQuery.of(context).size.width>MediaQuery.of(context).size.height){
      return new Scaffold(
          backgroundColor: Colors.white,
          body: new Container(
              child: new Center(
                // ignore: conflicting_dart_import
                  child: new Text("Please switch to portrait mode",textAlign: TextAlign.center,style:new TextStyle(fontSize:30*MediaQuery.of(context).size.width/640.0))
              )
          )
      );
    }
    Map<String, dynamic> tempMap;
    SplayTreeMap<String, dynamic> sortedMap;
    if(data!=null){
      tempMap = new Map<String,dynamic>()..addAll(data)..removeWhere((key,value){
        return (widget.onlyCreated&&!createdPolls.contains(key))||(!(key.toUpperCase().contains(search.toUpperCase())||((value as Map<String,dynamic>)["q"] as String).toUpperCase().contains(search.toUpperCase()))||(!widget.onlyCreated&&(((value as Map<String,dynamic>)["b"])[2]==0)));
      });
      sortedMap = SplayTreeMap.from(tempMap,(o1,o2){
        if(!widget.onlyCreated){
          if((sorting=="newest"||sorting=="oldest")&&tempMap[o2]["t"]!=tempMap[o1]["t"]){
            return sorting=="newest"?tempMap[o2]["t"]-tempMap[o1]["t"]:tempMap[o1]["t"]-tempMap[o2]["t"];
          }else if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
            return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
          }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
            return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
          }
          return o1.compareTo(o2);
        }else{
          if(sorting=="newest"||sorting=="oldest"){
            return sorting=="newest"?createdPolls.indexOf(o2)-createdPolls.indexOf(o1):createdPolls.indexOf(o1)-createdPolls.indexOf(o2);
          }else{
            if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
              return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
            }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
              return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
            }
            return o1.compareTo(o2);
          }
        }
      });
    }
    return new Scaffold(
        floatingActionButton: s.hasClients&&s.position.pixels>1.0?new FloatingActionButton(
          onPressed: (){
            visible = false;
            s.jumpTo(1.0);
            s.jumpTo(0.0);
            setState((){});
          },
          child: new Icon(Icons.arrow_upward),
          backgroundColor: Colors.black38,
        ):new Container(),
        appBar: new AppBar(
            title:data==null||(!inSearch&&!hasSearched)?new Text(!widget.onlyCreated?"Search":"Created",style: new TextStyle(color:Colors.white)
            ):new TextField(
              style: new TextStyle(fontSize:20.0,color: Colors.white),
              controller: c,
              autofocus: true,
              autocorrect: false,
              decoration: new InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  hintStyle: new TextStyle(color:Colors.white30)
              ),
              focusNode: f,
              onChanged: (s){
                search = s;
              },
              onSubmitted: (s){
                search = s;
                tempMap = new Map<String,dynamic>()..addAll(data)..removeWhere((key,value){
                  return (widget.onlyCreated&&!createdPolls.contains(key))||(!(key.toUpperCase().contains(search.toUpperCase())||((value as Map<String,dynamic>)["q"] as String).toUpperCase().contains(search.toUpperCase()))||(!widget.onlyCreated&&(((value as Map<String,dynamic>)["b"])[2]==0)));
                });
                sortedMap = SplayTreeMap.from(tempMap,(o1,o2){
                  if(!widget.onlyCreated){
                    if((sorting=="newest"||sorting=="oldest")&&tempMap[o2]["t"]!=tempMap[o1]["t"]){
                      return sorting=="newest"?tempMap[o2]["t"]-tempMap[o1]["t"]:tempMap[o1]["t"]-tempMap[o2]["t"];
                    }else if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
                      return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
                    }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
                      return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
                    }
                    return o1.compareTo(o2);
                  }else{
                    if(sorting=="newest"||sorting=="oldest"){
                      return sorting=="newest"?createdPolls.indexOf(o2)-createdPolls.indexOf(o1):createdPolls.indexOf(o1)-createdPolls.indexOf(o2);
                    }else{
                      if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
                        return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
                      }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
                        return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
                      }
                      return o1.compareTo(o2);
                    }
                  }
                });
                visible = false;
                this.s.jumpTo(1.0);
                this.s.jumpTo(0.0);
                setState((){hasSearched = true;inSearch = false;});
              },
            ),
            backgroundColor: Colors.black54,
            actions: [
              hasSearched&&!f.hasFocus?new IconButton(
                icon: new Icon(Icons.close),
                onPressed: (){
                  search = "";
                  c.text = "";
                  tempMap = new Map<String,dynamic>()..addAll(data)..removeWhere((key,value){
                    return (widget.onlyCreated&&!createdPolls.contains(key))||(!(key.toUpperCase().contains(search.toUpperCase())||((value as Map<String,dynamic>)["q"] as String).toUpperCase().contains(search.toUpperCase()))||(!widget.onlyCreated&&(((value as Map<String,dynamic>)["b"])[2]==0)));
                  });
                  sortedMap = SplayTreeMap.from(tempMap,(o1,o2){
                    if(!widget.onlyCreated){
                      if((sorting=="newest"||sorting=="oldest")&&tempMap[o2]["t"]!=tempMap[o1]["t"]){
                        return sorting=="newest"?tempMap[o2]["t"]-tempMap[o1]["t"]:tempMap[o1]["t"]-tempMap[o2]["t"];
                      }else if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
                        return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
                      }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
                        return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
                      }
                      return o1.compareTo(o2);
                    }else{
                      if(sorting=="newest"||sorting=="oldest"){
                        return sorting=="newest"?createdPolls.indexOf(o2)-createdPolls.indexOf(o1):createdPolls.indexOf(o1)-createdPolls.indexOf(o2);
                      }else{
                        if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
                          return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
                        }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
                          return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
                        }
                        return o1.compareTo(o2);
                      }
                    }
                  });
                  visible = false;
                  this.s.jumpTo(1.0);
                  this.s.jumpTo(0.0);
                  setState((){hasSearched = false;});
                },
              ):inSearch||f.hasFocus?new IconButton(
                icon: new Icon(Icons.clear),
                onPressed: (){
                  search = "";
                  visible = false;
                  this.s.jumpTo(1.0);
                  this.s.jumpTo(0.0);
                  setState((){c.text = search;inSearch=true;});
                },
              ):new IconButton(
                  icon: new Icon(Icons.search),
                  onPressed: (){
                    setState((){inSearch = true;});
                  }
              ),
              new Padding(padding: EdgeInsets.only(right:3.0),child:new Container(
                  width: 35.0,
                  child: new PopupMenuButton<String>(
                      itemBuilder: (BuildContext context)=><PopupMenuItem<String>>[
                        new PopupMenuItem<String>(child: const Text("Top"), value: "top"),
                        new PopupMenuItem<String>(child: const Text("Newest"), value: "newest"),
                        new PopupMenuItem<String>(child: const Text("Oldest"), value: "oldest"),
                      ],
                      child: new Icon(Icons.sort),
                      onSelected: (s){
                        setState((){
                          sorting = s;
                        });
                        this.s.jumpTo(1.0);
                        this.s.jumpTo(0.0);
                      }
                  )
              )),
            ]
        ),
        body: new Container(
            child: new Center(
                child: new RefreshIndicator(child: data!=null?new Scrollbar(child:new ListView.builder(
                  itemBuilder: (context,i){
                    return new Padding(padding: EdgeInsets.only(top:5.0),child:new GestureDetector(onTapUp: (t){
                      Map<String,dynamic> map = sortedMap[sortedMap.keys.toList()[i]];
                      Navigator.push(context,new MaterialPageRoute(builder: (context) => new ViewOrVote(sortedMap.keys.toList()[i],false,map["q"],map["c"],map["b"][1]==0,map["b"][0]==0,map["a"],map["b"][2]==0,map["i"]!=null&&map["i"].contains(userId),map["b"].length==4&&map["b"][3]==1)));
                    },child:new Container(
                        child: new ListTile(
                            leading: new Container(
                                width:40.0,
                                child: new FittedBox(fit: BoxFit.scaleDown,alignment: Alignment.centerLeft,child: new Text(sortedMap.keys.toList()[i],style: new TextStyle(color:Colors.white)))
                            ),
                            title: new Text(sortedMap[sortedMap.keys.toList()[i]]["q"],style: new TextStyle(color:Colors.white),maxLines: 2,overflow: TextOverflow.ellipsis),
                            trailing: new Text(sortedMap[sortedMap.keys.toList()[i]]["a"].reduce((n1,n2)=>n1+n2).toString(),style: new TextStyle(color:Colors.white))
                        ),
                        color: Colors.black38
                    )));
                  },
                  itemCount: sortedMap.length,
                  controller: s,
                  physics: AlwaysScrollableScrollPhysics(),
                )):new CircularProgressIndicator(),
                    onRefresh: (){
                      Completer c = new Completer<Null>();
                      http.get((Uri.encodeFull(database+"/data.json?auth="+secretKey))).then((r){
                        data = json.decode(r.body);
                        tempMap = new Map<String,dynamic>()..addAll(data)..removeWhere((key,value){
                          return (widget.onlyCreated&&!createdPolls.contains(key))||(!(key.toUpperCase().contains(search.toUpperCase())||((value as Map<String,dynamic>)["q"] as String).toUpperCase().contains(search.toUpperCase()))||(!widget.onlyCreated&&(((value as Map<String,dynamic>)["b"])[2]==0)));
                        });
                        sortedMap = SplayTreeMap.from(tempMap,(o1,o2){
                          if(!widget.onlyCreated){
                            if((sorting=="newest"||sorting=="oldest")&&tempMap[o2]["t"]!=tempMap[o1]["t"]){
                              return sorting=="newest"?tempMap[o2]["t"]-tempMap[o1]["t"]:tempMap[o1]["t"]-tempMap[o2]["t"];
                            }else if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
                              return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
                            }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
                              return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
                            }
                            return o1.compareTo(o2);
                          }else{
                            if(sorting=="newest"||sorting=="oldest"){
                              return sorting=="newest"?createdPolls.indexOf(o2)-createdPolls.indexOf(o1):createdPolls.indexOf(o1)-createdPolls.indexOf(o2);
                            }else{
                              if(((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)!=0){
                                return ((tempMap[o2] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2)-((tempMap[o1] as Map<String,dynamic>)["a"] as List).reduce((n1,n2)=>n1+n2);
                              }else if(tempMap[o1]["q"].compareTo(tempMap[o2]["q"])!=0){
                                return tempMap[o1]["q"].compareTo(tempMap[o2]["q"]);
                              }
                              return o1.compareTo(o2);
                            }
                          }
                        });
                        setState((){c.complete();});
                      });
                      return c.future;
                    }
                )
            )
        )
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    return newValue.text.length>4?oldValue.copyWith(text: oldValue.text.toUpperCase().replaceAll(" ", "")):newValue.copyWith(text: newValue.text.toUpperCase().replaceAll(" ", ""));
  }
}

class MaxInputFormatter extends TextInputFormatter {
  int max;
  MaxInputFormatter(this.max);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    return newValue.text.length>max?oldValue.copyWith(text: oldValue.text):newValue.copyWith(text: newValue.text);
  }
}

class CreatePoll extends StatefulWidget{
  @override
  CreatePollState createState() => new CreatePollState();
}

bool removing = false;

class CreatePollState extends State<CreatePoll>{

  static int optionCount;

  static List<Widget> list = [];

  bool oneChoice = false;

  bool perm = false;

  static List<String> choices = [];

  static String question;

  int totalCount = 2;

  bool public = false;

  File pickedImage;

  double width;

  double height;

  bool imageLoading = false;

  ScrollController s = new ScrollController();

  @override
  void initState(){
    super.initState();
    removing = false;
    optionCount = 2;
    question = null;
    choices.clear();
    list.clear();
    list.add(new Option(0,new GlobalKey()));
    list.add(new Option(1,new GlobalKey()));
    choices.length = 2;
    list.add(new Container(height: 50.0,padding: EdgeInsets.only(left:24.0,right:24.0),child: new RaisedButton(
        child: new ListTile(
            leading: new Icon(Icons.add,color:Colors.white),
            title: new Text("Add",style: new TextStyle(color:Colors.white),textAlign: TextAlign.start)
        ),
        onPressed: (){
          if(!isRemoving){
            if(optionCount<20){
              list.insert(list.length-1,new Option(optionCount++,new GlobalKey()));
              if(s.position.pixels>0.0){
                s.jumpTo(s.position.pixels+50);
              }
              choices.length = optionCount;
              setState((){});
            }
          }
        }
    )));
  }

  bool hasTapped = true;

  @override
  Widget build(BuildContext context) {
    if(MediaQuery.of(context).size.width>MediaQuery.of(context).size.height){
      return new Scaffold(
          backgroundColor: Colors.white,
          body: new Container(
              child: new Center(
                // ignore: conflicting_dart_import
                  child: new Text("Please switch to portrait mode",textAlign: TextAlign.center,style:new TextStyle(fontSize:30*MediaQuery.of(context).size.width/640.0))
              )
          )
      );
    }
    return new WillPopScope(child: new Scaffold(
        appBar: new AppBar(title: new Text("Create a Poll",style: new TextStyle(color:Colors.white)),backgroundColor: Colors.black54,actions:[
          new IconButton(
              icon: new Icon(!removing?Icons.delete:Icons.check),
              onPressed: (){
                for(int i = 0; i<CreatePollState.list.length-1;i++){
                  (CreatePollState.list[i] as Option).key.currentState.setState((){});
                }
                setState((){removing = !removing;});
              }
          )
        ]),
        body: new Container(
            child: new Center(
                child: new ListView(
                    controller: s,
                    children: [
                      new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new Text(""),
                            new Padding(padding:EdgeInsets.only(bottom:8.0),child:new Container(height: 50.0,padding: EdgeInsets.only(left:20.0,right:20.0),child: new TextField(
                                decoration: new InputDecoration(
                                    hintText: 'Question',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: InputBorder.none,
                                    counterText: ""
                                ),
                                onChanged: (s){
                                  question = s;
                                },
                                inputFormatters: [new MaxInputFormatter(128)],
                            ))),
                            new Column(
                                children: list
                            ),
                            new Container(height:30.0),
                            new GestureDetector(onTapUp: (d){setState((){oneChoice = !oneChoice;});}, child:new Container(
                                padding: EdgeInsets.only(left:5.0,right:5.0),
                                child: new Container(
                                    height: 50.0,
                                    color:Colors.black12,
                                    child: new Row(
                                        children: [
                                          new Expanded(child: new Text("  Allow multiple selections",style: new TextStyle(fontSize:17.0,color:Colors.white))),
                                          new Switch(
                                              value: oneChoice,
                                              onChanged: (s){
                                                setState((){oneChoice = s;});
                                              },
                                              activeColor: Colors.black
                                          )
                                        ]
                                    )
                                )
                            )),
                            new GestureDetector(onTapUp: (d){setState((){perm = !perm;});},child:new Container(
                                padding: EdgeInsets.only(left:5.0,right:5.0,top:5.0),
                                child: new Container(
                                    height: 50.0,
                                    color:Colors.black12,
                                    child: new Row(
                                        children: [
                                          new Expanded(child: new Text("  Allow multiple submissions",style: new TextStyle(fontSize:17.0,color:Colors.white))),
                                          new Switch(
                                              value: perm,
                                              onChanged: (s){
                                                setState((){perm = s;});
                                              },
                                              activeColor: Colors.black
                                          )
                                        ]
                                    )
                                )
                            )),
                            new GestureDetector(onTapUp: (d){setState((){public = !public;});},child:new Container(
                                padding: EdgeInsets.only(left:5.0,right:5.0,top:5.0),
                                child: new Container(
                                    height: 50.0,
                                    color:Colors.black12,
                                    child: new Row(
                                        children: [
                                          new Expanded(child: new Text("  Publicly searchable",style: new TextStyle(fontSize:17.0,color:Colors.white))),
                                          new Switch(
                                              value: public,
                                              onChanged: (s){
                                                setState((){public = s;});
                                              },
                                              activeColor: Colors.black
                                          )
                                        ]
                                    )
                                )
                            )),
                            new GestureDetector(onTapUp: (d) async{
                              if(pickedImage!=null&&width!=null){
                                Navigator.push(context,new PageRouteBuilder(opaque:false,pageBuilder: (context,a1,a2)=>new ImageView(child:new Center(child:new PhotoView(imageProvider:new Image.file(pickedImage).image,minScale: min(MediaQuery.of(context).size.width/width,MediaQuery.of(context).size.height/height),maxScale:4.0*min(MediaQuery.of(context).size.width/width,MediaQuery.of(context).size.height/height))),name:"Image")));
                              }else if(!imageLoading){
                                File tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
                                if(tempImage!=null){
                                  if(tempImage!=null&&(basename(tempImage.path)==null||lookupMimeType(basename(tempImage.path))==null||!["image/png","image/jpeg"].contains(lookupMimeType(basename(tempImage.path))))){
                                    imageLoading=false;
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (context){
                                          return new AlertDialog(
                                              title:new Text("Error"),
                                              content:new Text(basename(tempImage.path)==null?"Invalid file path":"Invalid file type"),
                                              actions: [
                                                new RaisedButton(
                                                    child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                    },
                                                    color: Colors.grey
                                                )
                                              ]
                                          );
                                        }
                                    );
                                    return;
                                  }
                                  setState((){imageLoading = true;pickedImage = tempImage;});
                                  new Image.file(tempImage).image.resolve(new ImageConfiguration()).addListener((ImageInfo info, bool b){
                                    height = info.image.height*1.0;
                                    width = info.image.width*1.0;
                                    setState((){imageLoading = false;});
                                  });
                                }else{
                                  height=null;
                                  width=null;
                                  imageLoading=false;
                                  pickedImage=null;
                                }
                              }
                            },onLongPress: (){
                              if(!imageLoading){
                                setState((){
                                  pickedImage = null;
                                  height = null;
                                  width = null;
                                });
                              }
                            },child: new Container(
                                padding: EdgeInsets.only(left:5.0,right:5.0,top:5.0),
                                child: new Container(
                                    height: 50.0,
                                    color:Colors.black12,
                                    child: new Row(
                                        children: [
                                          new Expanded(child: new Text(pickedImage!=null?"  Image selected":"  No image selected",style: new TextStyle(fontSize:17.0,color:Colors.white))),
                                          pickedImage!=null?new Padding(padding:EdgeInsets.only(right:10.0),child:new SizedBox(height:40.0,width:40.0,child:!imageLoading?!removing?new Image.file(pickedImage,fit:BoxFit.cover):new IconButton(icon: new Icon(Icons.delete),onPressed:(){
                                            setState((){
                                              pickedImage = null;
                                              height = null;
                                              width = null;
                                            });
                                          }):new CircularProgressIndicator())):new Container()
                                        ]
                                    )
                                )
                            )),
                            new Container(height:25.0),
                            new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children:[
                                  new MaterialButton(
                                      height: 40.0*MediaQuery.of(context).size.width/360,minWidth: 75.0*MediaQuery.of(context).size.width/360,
                                      color: Colors.black26,
                                      onPressed: () async{
                                        if(!imageLoading){
                                          File tempImage = await ImagePicker.pickImage(source: ImageSource.camera);
                                          if(tempImage!=null){
                                            if(tempImage!=null&&(basename(tempImage.path)==null||lookupMimeType(basename(tempImage.path))==null||!["image/png","image/jpeg"].contains(lookupMimeType(basename(tempImage.path))))){
                                              imageLoading = false;
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (context){
                                                    return new AlertDialog(
                                                        title:new Text("Error"),
                                                        content:new Text(basename(tempImage.path)==null?"Invalid file path":"Invalid file type"),
                                                        actions: [
                                                          new RaisedButton(
                                                              child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                              onPressed: (){
                                                                Navigator.of(context).pop();
                                                              },
                                                              color: Colors.grey
                                                          )
                                                        ]
                                                    );
                                                  }
                                              );
                                              return;
                                            }
                                            setState((){imageLoading = true;pickedImage = tempImage;});
                                            new Image.file(tempImage).image.resolve(new ImageConfiguration()).addListener((ImageInfo info, bool b){
                                              height = info.image.height*1.0;
                                              width = info.image.width*1.0;
                                              setState((){imageLoading = false;});
                                            });
                                          }else{
                                            height=null;
                                            width=null;
                                            imageLoading=false;
                                            pickedImage=null;
                                          }
                                        }
                                      },
                                      child: new Icon(Icons.add_a_photo,color:Colors.white,size:24.0*MediaQuery.of(context).size.width/360)
                                  ),
                                  new MaterialButton(
                                      height: 40.0*MediaQuery.of(context).size.width/360,minWidth: 75.0*MediaQuery.of(context).size.width/360,
                                      color: Colors.black26,
                                      onPressed: () async{
                                        if(!imageLoading){
                                          File tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
                                          if(tempImage!=null){
                                            if(tempImage!=null&&(basename(tempImage.path)==null||lookupMimeType(basename(tempImage.path))==null||!["image/png","image/jpeg"].contains(lookupMimeType(basename(tempImage.path))))){
                                              imageLoading = false;
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (context){
                                                    return new AlertDialog(
                                                        title:new Text("Error"),
                                                        content:new Text(basename(tempImage.path)==null?"Invalid file path":"Invalid file type"),
                                                        actions: [
                                                          new RaisedButton(
                                                              child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                              onPressed: (){
                                                                Navigator.of(context).pop();
                                                              },
                                                              color: Colors.grey
                                                          )
                                                        ]
                                                    );
                                                  }
                                              );
                                              return;
                                            }
                                            setState((){imageLoading = true;pickedImage = tempImage;});
                                            new Image.file(tempImage).image.resolve(new ImageConfiguration()).addListener((ImageInfo info, bool b){
                                              height = info.image.height*1.0;
                                              width = info.image.width*1.0;
                                              setState((){imageLoading = false;});
                                            });
                                          }else{
                                            height=null;
                                            width=null;
                                            imageLoading=false;
                                            pickedImage=null;
                                          }
                                        }
                                      },
                                      child: new Icon(Icons.photo_library,color:Colors.white,size:24.0*MediaQuery.of(context).size.width/360)
                                  )
                                ]
                            ),
                            // ignore: conflicting_dart_import
                            new Container(height:30.0),
                            new Container(height:60.0*MediaQuery.of(context).size.width/360,width:200.0*MediaQuery.of(context).size.width/360,child:new RaisedButton(
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0*MediaQuery.of(context).size.width/360)),
                                child: new Text("Submit",style: new TextStyle(fontSize:25.0*MediaQuery.of(context).size.width/360,color:Colors.white)),
                                onPressed: ()  async{
                                  if(question!=null && !choices.contains(null)&&choices.toSet().length==choices.length&&question!=""&&!choices.contains("")&&(pickedImage==null||(pickedImage!=null&&((await pickedImage.length())<5000000)))){
                                    if(pickedImage!=null&&(basename(pickedImage.path)==null||lookupMimeType(basename(pickedImage.path))==null||!["image/png","image/jpeg"].contains(lookupMimeType(basename(pickedImage.path))))){
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context){
                                            return new AlertDialog(
                                                title:new Text("Error"),
                                                content:new Text(basename(pickedImage.path)==null?"Invalid file path":"Invalid file type"),
                                                actions: [
                                                  new RaisedButton(
                                                      child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      color: Colors.grey
                                                  )
                                                ]
                                            );
                                          }
                                      );
                                      return;
                                    }
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context){
                                          return new AlertDialog(
                                              title: new Text("Loading"),
                                              content: new LinearProgressIndicator()
                                          );
                                        }
                                    );
                                    String key = "";
                                    Random r = new Random();
                                    Map<String,dynamic> usedMap;
                                    await http.get((Uri.encodeFull(database+"/data.json?auth="+secretKey))).then((r){
                                      usedMap = json.decode(r.body);
                                    }).catchError((e){
                                      Navigator.of(context).pop();
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context){
                                            return new AlertDialog(
                                                title:new Text("Error"),
                                                content:new Text("Please check your internet connection"),
                                                actions: [
                                                  new RaisedButton(
                                                      child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      color: Colors.grey
                                                  )
                                                ]
                                            );
                                          }
                                      );
                                      throw e;
                                    });
                                    do{
                                      key = "";
                                      for(int i = 0; i<4;i++){
                                        List<String> nums = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
                                        key+=nums[r.nextInt(36)];
                                      }
                                    }while(usedMap!=null&&usedMap.keys.contains(key));
                                    List<int> answers = new List<int>(choices.length);
                                    answers = answers.map((i)=>0).toList();
                                    String listPrint = "";
                                    for(String s in choices){
                                      listPrint+="\""+s.replaceAll("\\","\\\\").replaceAll("\"","\\\"")+"\", ";
                                    }
                                    listPrint = listPrint.substring(0,listPrint.length-2);
                                    http.Response responseTime = await http.get(Uri.encodeFull("http://worldclockapi.com/api/json/utc/now")).catchError((e){
                                      Navigator.of(context).pop();
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context){
                                            return new AlertDialog(
                                                title:new Text("Error"),
                                                content:new Text("Please check your internet connection"),
                                                actions: [
                                                  new RaisedButton(
                                                      child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      color: Colors.grey
                                                  )
                                                ]
                                            );
                                          }
                                      );
                                      throw e;
                                    });
                                    String serverData = "{\n\t\"q\": \""+question.replaceAll("\\","\\\\").replaceAll("\"","\\\"")+"\",\n\t\"c\": "+"["+listPrint+"]"+",\n\t\"b\": "+((oneChoice?"1 ":"0 ")+(perm?"1 ":"0 ")+(public?"1 ":"0 ")+(pickedImage!=null?"1":"0")).split(" ").toString()+",\n\t\"a\": "+answers.toString()+(public?",\n\t\"t\": "+(DateTime.parse(json.decode(responseTime.body)["currentDateTime"]).add(new Duration(seconds:new DateTime.now().second)).millisecondsSinceEpoch/1000).floor().toString():"")+"\n}";
                                    if(pickedImage!=null){
                                      await http.post(Uri.encodeFull(cloudUploadDatabase+"/o?uploadType=media&name="+key),headers:{"content-type":lookupMimeType(basename(pickedImage.path))},body:await pickedImage.readAsBytes()).catchError((e){
                                        Navigator.of(context).pop();
                                        showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (context){
                                              return new AlertDialog(
                                                  title:new Text("Error"),
                                                  content:new Text("Please check your internet connection"),
                                                  actions: [
                                                    new RaisedButton(
                                                        child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                        onPressed: (){
                                                          Navigator.of(context).pop();
                                                        },
                                                        color: Colors.grey
                                                    )
                                                  ]
                                              );
                                            }
                                        );
                                        throw e;
                                      });
                                    }
                                    http.put(database+"/data/"+key+".json?auth="+secretKey,body:serverData).then((r) async{
                                      createdPolls.add(key);
                                      String write = "";
                                      for(String s in createdPolls){
                                        write+=(s+" ");
                                      }
                                      createdInfo.writeData(write.substring(0,write.length-1));
                                      Navigator.push(context,new MaterialPageRoute(builder: (context) => new WillPopScope(onWillPop:(){Navigator.of(context).pop();return new Future<bool>(()=>Navigator.of(context).pop(true));},child: new Scaffold(
                                          appBar: new AppBar(title:new Text("Success",style: new TextStyle(color:Colors.white)),backgroundColor: Colors.black54),
                                          body:new Container(
                                              child: new Center(
                                                  child: new Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        new Text("Your poll has been created with the code",style:new TextStyle(fontSize:15.0*MediaQuery.of(context).size.width/360.0,fontWeight: FontWeight.bold)),
                                                        new FittedBox(fit:BoxFit.scaleDown,child:new Text(key,style:new TextStyle(fontSize:130.0*MediaQuery.of(context).size.width/360.0)))
                                                      ]
                                                  )
                                              )
                                          )
                                      ))));
                                    }).catchError((e){
                                      Navigator.of(context).pop();
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context){
                                            return new AlertDialog(
                                                title:new Text("Error"),
                                                content:new Text("Please check your internet connection"),
                                                actions: [
                                                  new RaisedButton(
                                                      child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      color: Colors.grey
                                                  )
                                                ]
                                            );
                                          }
                                      );
                                    });
                                  }else{
                                    String s = "";
                                    if((question==null||choices.contains(null)||question==""||choices.contains(""))&&choices.toSet().length!=choices.length){
                                      s="Please complete all the fields without duplicates";
                                    }else if(question==null||choices.contains(null)||question==""||choices.contains("")){
                                      s="Please complete all the fields";
                                    }else if(choices.toSet().length!=choices.length){
                                      s="Please do not include duplicate choices";
                                    }
                                    if(pickedImage!=null&&((await pickedImage.length()>5000000))){
                                      if(s==""){
                                        s="That image is too big (max size is 5 MB)";
                                      }else{
                                        s+=" and reduce the image size to below 5 MB";
                                      }
                                    }
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (context){
                                          return new AlertDialog(
                                              title:new Text("Error"),
                                              content:new Text(s),
                                              actions: [
                                                new RaisedButton(
                                                    child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                    },
                                                    color: Colors.grey
                                                )
                                              ]
                                          );
                                        }
                                    );
                                  }
                                }
                            )),
                            new Container(height:30.0)
                          ]
                      )
                    ]
                )
            )
        )
    ),
        onWillPop: (){
          bool hasEnteredChoices = false;
          for(int i = 0; i<choices.length;i++){
            if(choices[i]!=null&&choices[i]!=""){
              hasEnteredChoices = true;
              break;
            }
          }
          if(((question!=null&&question!="")||hasEnteredChoices)||pickedImage!=null){
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context){
                  return new AlertDialog(
                      title:new Text("Are you sure?"),
                      content:new Text("Any changes will be lost"),
                      actions: [
                        new RaisedButton(
                            child: new Text("No",style:new TextStyle(color: Colors.black)),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            color: Colors.grey
                        ),
                        new RaisedButton(
                            child: new Text("Yes",style:new TextStyle(color: Colors.black)),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            color: Colors.grey
                        ),
                      ]
                  );
                }
            );
            return new Future<bool>(()=>false);
          }else{
            return new Future<bool>(()=>true);
          }
        });
  }
}

class ImageView extends StatefulWidget{
  @required Widget child;
  @required String name;
  ImageView({this.child,this.name});
  @override
  ImageViewState createState() => new ImageViewState();
}

class ImageViewState extends State<ImageView>{
  bool hasTapped = true;
  bool isAnimating = false;
  bool hasLeft = false;
  Timer t;
  Timer t2;

  @override
  Widget build(BuildContext context){
    if(hasTapped){
      if(t!=null&&t.isActive){
        t.cancel();
      }
      t = new Timer(new Duration(seconds:2),(){
        if(!isAnimating&&!hasLeft){
          setState((){isAnimating = true;});
          t2 = new Timer(new Duration(milliseconds: 200),(){
            if(!hasLeft){
              isAnimating = false;
              setState((){
                hasTapped = false;
              });
            }
          });
        }
      });
    }
    return new GestureDetector(onTap:(){
      if(!isAnimating){
        if(hasTapped){
          if(t2!=null&&t2.isActive){
            t2.cancel();
          }
          setState((){isAnimating = true;});
          t2 = new Timer(new Duration(milliseconds: 200),(){
            if(!hasLeft){
              isAnimating=false;
              setState((){hasTapped=false;});
            }
          });
        }else{
          setState((){hasTapped=true;});
        }
      }
    },child:new Scaffold(
        backgroundColor: colors[color],
        body: new Stack(
            children: hasTapped?[
              widget.child,
              new IgnorePointer(child:new AnimatedOpacity(opacity:isAnimating?0.0:1.0,duration:new Duration(milliseconds: 200),child:new Container(color:Colors.black38))),
              new Positioned(
                  right:10.0,
                  top:MediaQuery.of(context).padding.top,
                  child: new AnimatedOpacity(opacity:isAnimating?0.0:1.0,duration:new Duration(milliseconds:200),child:new IconButton(iconSize:30.0*MediaQuery.of(context).size.width/375.0,color:Colors.white,icon:new Icon(Icons.close),onPressed:(){hasLeft = true;Navigator.of(context).pop();}))
              ),
              new Positioned(
                  left:15.0,
                  top:MediaQuery.of(context).padding.top+6,
                  child: new IgnorePointer(child:new AnimatedOpacity(opacity:isAnimating?0.0:1.0,duration:new Duration(milliseconds:200),child:new Text(widget.name,style:new TextStyle(fontSize:(48.0/1.75)*MediaQuery.of(context).size.width/375.0,color:Colors.white))))
              )
              //new AnimatedOpacity(opacity:isAnimating?0.0:1.0,duration:new Duration(milliseconds:200),child:new Container(color:Colors.white70,height:MediaQuery.of(context).padding.top+kToolbarHeight,child:new AppBar(actions:[new IconButton(icon:new Icon(Icons.close),onPressed:(){hasLeft = true;Navigator.of(context).pop();})],automaticallyImplyLeading:false,centerTitle:false,title:new Text(widget.name,style:new TextStyle(color:Colors.white)),backgroundColor: Colors.transparent,elevation: 0.0)))
            ]:[
              widget.child
            ]
        )
    ));
  }
}


class ViewOrVote extends StatefulWidget{
  bool public,oneResponse,oneChoice,vote,hasVoted,hasImage;
  String question,code;
  List<dynamic> choices,scores;
  ViewOrVote(this.code,this.vote,this.question,this.choices,this.oneResponse,this.oneChoice,this.scores,this.public,this.hasVoted,this.hasImage);
  @override
  ViewOrVoteState createState() => new ViewOrVoteState();
}

class ViewOrVoteState extends State<ViewOrVote>{

  String choice;

  Map<String,bool> checked = new Map<String,bool>();

  List<String> choicesString = new List<String>();

  bool isLeaving = false;

  HttpClient client = new HttpClient();

  List<bool> changedColors;

  ScrollController s = new ScrollController();

  Map ultraTempMap;

  SplayTreeMap<String,int> sortedMap;

  PieChart chart;

  Timer timer;

  int hexToInt(String colorStr)
  {
    colorStr = "FF" + colorStr;
    colorStr = colorStr.replaceAll("#", "");
    int val = 0;
    int length = colorStr.length;
    for(int i = 0; i<length; i++){
      int hexDigit = colorStr.codeUnitAt(i);
      if(hexDigit>=48&&hexDigit<=57){
        val+=(hexDigit-48)*(1<<(4*(length-1-i)));
      }else if(hexDigit >= 65 && hexDigit <= 70){
        val+=(hexDigit-55)*(1<<(4*(length-1-i)));
      }else if(hexDigit >= 97 && hexDigit <= 102){
        val+=(hexDigit-87)*(1<<(4*(length-1-i)));
      }else{
        throw new FormatException("An error occurred when converting a color");
      }
    }
    return val;
  }

  Completer<ui.Image> completer;

  double height;

  double width;

  @override
  void initState(){
    super.initState();
    if(widget.hasImage){
      image = new Image.network(imageLink+widget.code,fit: BoxFit.fitWidth);
      completer = new Completer<ui.Image>();
      image.image.resolve(new ImageConfiguration()).addListener((ImageInfo info, bool b){
        if(!completer.isCompleted){
          completer.complete(info.image);
        }
      });
    }
    ultraTempMap = Map.fromIterables(widget.choices, widget.scores);
    sortedMap = new SplayTreeMap.from(ultraTempMap,(o1,o2)=>ultraTempMap[o2]-ultraTempMap[o1]!=0?ultraTempMap[o2]-ultraTempMap[o1]:widget.choices.indexOf(o1)-widget.choices.indexOf(o2));
    if(!widget.oneChoice){
      for(String s in widget.choices){
        checked.putIfAbsent(s, ()=>false);
      }
    }else{
      for(int i = 0; i<widget.choices.length;i++){
        choicesString.add(widget.choices[i].toString());
      }
    }
    changedColors = new List<bool>(widget.scores.length).map((b)=>false).toList();
    client.openUrl("GET", Uri.parse(database+"/data/"+widget.code+"/a.json?auth="+secretKey)).then((req){
      req.headers.set("Accept", "text/event-stream");
      req.followRedirects = true;
      req.close().then((response){
        if(response.statusCode == 200) {
          response.map((bytes) => new String.fromCharCodes(bytes)).listen((text) {
            List list = text.replaceAll("\n"," ").split(" ");
            if(list[1]=="put"){
              Map<String,dynamic> map = json.decode(list[3]);
              if(map["path"]!="/"){
                if(timer!=null && timer.isActive){
                  timer.cancel();
                }
                int changed = map["data"];
                if(SearchPageState.data!=null&&SearchPageState.data[widget.code]!=null){
                  SearchPageState.data[widget.code]["a"][int.parse(map["path"].substring(1,map["path"].length))] = changed;
                }
                changedColors[int.parse(map["path"].substring(1,map["path"].length))] = true;
                timer = new Timer(new Duration(milliseconds: 750),(){
                  setState((){
                    changedColors = new List<bool>(widget.scores.length).map((b)=>false).toList();
                  });
                });
                widget.scores[int.parse(map["path"].substring(1,map["path"].length))] = changed;
                ultraTempMap = Map.fromIterables(widget.choices, widget.scores);
                sortedMap = new SplayTreeMap.from(ultraTempMap,(o1,o2)=>ultraTempMap[o2]-ultraTempMap[o1]!=0?ultraTempMap[o2]-ultraTempMap[o1]:widget.choices.indexOf(o1)-widget.choices.indexOf(o2));
                chart.scores = widget.scores;
                setState((){});
                if(_chartKey.currentState!=null){
                  _chartKey.currentState.updateData(widget.scores.reduce((o1,o2)=>o1+o2)>0?[new CircularStackEntry(sortedMap.keys.map((name){
                    return new CircularSegmentEntry(ultraTempMap[name]*1.0,new Color(hexToInt(ultraTempMap.keys.toList().indexOf(name)<11?charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(name)].shadeDefault.hexString:charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(name)-11].makeShades(2)[1].hexString)),rankKey:name);
                  }).toList())]:[]);
                }
              }else if(!ListEquality().equals(map["data"],widget.scores)){
                if(timer!=null && timer.isActive){
                  timer.cancel();
                }
                List changed = map["data"];
                for(int i = 0; i<changedColors.length;i++){
                  changedColors[i] = changed[i]!=widget.scores[i];
                }
                if(SearchPageState.data!=null&&SearchPageState.data[widget.code]!=null){
                  SearchPageState.data[widget.code]["a"] = changed;
                }
                widget.scores = changed;
                ultraTempMap = Map.fromIterables(widget.choices, widget.scores);
                sortedMap = new SplayTreeMap.from(ultraTempMap,(o1,o2)=>ultraTempMap[o2]-ultraTempMap[o1]!=0?ultraTempMap[o2]-ultraTempMap[o1]:widget.choices.indexOf(o1)-widget.choices.indexOf(o2));
                chart.scores = widget.scores;
                setState((){
                  timer = new Timer(new Duration(milliseconds: 750),(){
                    setState((){
                      changedColors = new List<bool>(widget.scores.length).map((b)=>false).toList();
                    });
                  });
                });
                if(_chartKey.currentState!=null){
                  _chartKey.currentState.updateData(widget.scores.reduce((o1,o2)=>o1+o2)>0?[new CircularStackEntry(sortedMap.keys.map((name){
                    return new CircularSegmentEntry(ultraTempMap[name]*1.0,new Color(hexToInt(ultraTempMap.keys.toList().indexOf(name)<11?charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(name)].shadeDefault.hexString:charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(name)-11].makeShades(2)[1].hexString)),rankKey:name);
                  }).toList())]:[]);
                }
              }
            }
          });
        }
      });
    });
  }

  bool isVoting = false;

  Image image;

  @override
  Widget build(BuildContext context){
    if(MediaQuery.of(context).size.width>MediaQuery.of(context).size.height){
      return new Scaffold(
          backgroundColor: Colors.white,
          body: new Container(
              child: new Center(
                // ignore: conflicting_dart_import
                  child: new Text("Please switch to portrait mode",textAlign: TextAlign.center,style:new TextStyle(fontSize:30*MediaQuery.of(context).size.width/640.0))
              )
          )
      );
    }
    chart = new PieChart(widget.scores,widget.choices);
    ultraTempMap = Map.fromIterables(widget.choices, widget.scores);
    sortedMap = new SplayTreeMap.from(ultraTempMap,(o1,o2)=>ultraTempMap[o2]-ultraTempMap[o1]!=0?ultraTempMap[o2]-ultraTempMap[o1]:widget.choices.indexOf(o1)-widget.choices.indexOf(o2));
    return new WillPopScope(child:new Scaffold(
        appBar: new AppBar(title:new Text(widget.code,style: new TextStyle(color:Colors.white)),backgroundColor: Colors.black54, actions: [
          !widget.hasVoted&&!widget.vote?new FlatButton(
              color: Colors.black38,
              onPressed: (){
                s.jumpTo(1.0);
                s.jumpTo(0.0);
                setState((){widget.vote = true;});
              },
              child: new Text("Vote",style: new TextStyle(color:Colors.white,fontSize:20.0))
          ):new Container()
        ]),
        body: new Container(
            child: new Center(
                child: /*new RefreshIndicator(onRefresh: (){
            Completer c = new Completer<Null>();
            http.get(Uri.encodeFull(database+"/data.json?auth="+secretKey)).then((r){
              Map<String, dynamic> map = json.decode(r.body);
              SearchPageState.data = map;
              widget.scores = map[widget.code]["a"];
              ultraTempMap = Map.fromIterables(widget.choices, widget.scores);
              sortedMap = new SplayTreeMap.from(ultraTempMap,(o1,o2)=>ultraTempMap[o2]-ultraTempMap[o1]!=0?ultraTempMap[o2]-ultraTempMap[o1]:widget.choices.indexOf(o1)-widget.choices.indexOf(o2));
              chart.scores = widget.scores;
              if(_chartKey.currentState!=null){
                _chartKey.currentState.updateData(widget.scores.reduce((o1,o2)=>o1+o2)>0?[new CircularStackEntry(sortedMap.keys.map((name){
                  return new CircularSegmentEntry(ultraTempMap[name]*1.0,new Color(hexToInt(ultraTempMap.keys.toList().indexOf(name)<11?charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(name)].shadeDefault.hexString:charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(name)-11].makeShades(2)[1].hexString)),rankKey:name);
                }).toList())]:[]);
              }
              setState((){c.complete();});
            });
            return c.future;
          },child:*/ new ListView(
                    physics: new AlwaysScrollableScrollPhysics(),
                    controller: s,
                    children: [
                      new Container(color:Colors.black54,height:1.0),
                      new Container(padding:EdgeInsets.only(top:10.0,bottom:10.0),color:Colors.black45,child:new Text(widget.question,style:new TextStyle(color:Colors.white,fontSize:25.0*MediaQuery.of(context).size.width/360.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                      new Container(color:Colors.black54,height:1.0),
                      widget.hasImage?new Padding(padding:EdgeInsets.only(bottom:4.0),child:new GestureDetector(onTapUp: (t){
                        if(width!=null){
                          Navigator.push(context,new PageRouteBuilder(opaque:false,pageBuilder: (context,a1,a2)=>new ImageView(child:new Center(child:new PhotoView(imageProvider:image.image,minScale: min(MediaQuery.of(context).size.width/width,MediaQuery.of(context).size.height/height), maxScale:4.0*min(MediaQuery.of(context).size.width/width,MediaQuery.of(context).size.height/height))),name:widget.code)));
                        }
                      },child:new FutureBuilder<ui.Image>(
                        future: completer.future,
                        builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot){
                          if(snapshot.hasData){
                            height = snapshot.data.height*1.0;
                            width = snapshot.data.width*1.0;
                            return new SizedBox(
                                height:MediaQuery.of(context).size.height/3.0,
                                child:new Image(image:image.image,fit:BoxFit.cover)
                            );
                          }else{
                            return new Container(height:2.0,child:new LinearProgressIndicator());
                          }
                        },
                      ))):new Container(),
                      new Column(
                          children: widget.vote?(widget.oneChoice?choicesString.map((String key){
                            return new Padding(padding: EdgeInsets.only(top:widget.choices.indexOf(key)!=0?4.0:0.0),child: new Container(color:Colors.black26,child:new RadioListTile(
                                value: key,
                                title: new Text(key,style:new TextStyle(color:Colors.white)),
                                groupValue: choice,
                                onChanged: (v){
                                  setState((){
                                    choice = v;
                                  });
                                }
                            )));
                          }).toList():checked.keys.map((String key){
                            return new Padding(padding:EdgeInsets.only(top:widget.choices.indexOf(key)!=0?4.0:0.0),child: new Container(color:Colors.black26,child:new CheckboxListTile(
                                title: new Text(key,style:new TextStyle(color:Colors.white)),
                                value: checked[key],
                                onChanged: (v){
                                  setState((){
                                    checked[key] = v;
                                  });
                                }
                            )));
                          }).toList()):sortedMap.keys.map((String key){
                            return new Padding(padding:EdgeInsets.only(top:sortedMap.keys.toList().indexOf(key)!=0?4.0:0.0),child:new Container(color:Colors.black26,child:new ListTile(
                                title: new Text(key,style:new TextStyle(color:Colors.white)),
                                subtitle: new Container(height:15.0,child:new LinearProgressIndicator(
                                    value: widget.scores.reduce((a,b)=>a+b)!=0?sortedMap[key]/(1.0*widget.scores.reduce((a,b)=>a+b)):0.0,
                                    valueColor: new AlwaysStoppedAnimation(new Color(hexToInt(ultraTempMap.keys.toList().indexOf(key)<11?charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(key)].shadeDefault.hexString:charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(key)-11].makeShades(2)[1].hexString))),
                                    backgroundColor: new Color(hexToInt(ultraTempMap.keys.toList().indexOf(key)<11?charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(key)].makeShades(4)[3].hexString:charts.MaterialPalette.getOrderedPalettes(20)[ultraTempMap.keys.toList().indexOf(key)-11].makeShades(5)[4].hexString))
                                )),
                                trailing: new Container(width:35.0,child:new Column(
                                    children: [
                                      new FittedBox(fit: BoxFit.scaleDown,alignment: Alignment.center,child:new Text(sortedMap[key].toString(),style:new TextStyle(color:!changedColors[widget.choices.indexOf(key)]?Colors.white:Colors.green))),
                                      new Text((widget.scores.reduce((a,b)=>a+b)!=0?(sortedMap[key]/(1.0*widget.scores.reduce((a,b)=>a+b)))*100.0:0.0).toStringAsFixed(0)+"\%",style:new TextStyle(color:Colors.white))
                                    ]
                                ))
                            )));
                          }).toList()),
                      widget.vote?new Padding(padding: EdgeInsets.only(top:20.0),child:new Column(crossAxisAlignment: CrossAxisAlignment.center,children:[new Container(
                          height:65.0,width:150.0,
                          child:new RaisedButton(
                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
                              onPressed: (){
                                if((widget.oneChoice&&choice!=null) || !widget.oneChoice){
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context){
                                        wait(){
                                          if(!isVoting){
                                            Navigator.of(context).pop();
                                          }else{
                                            new Timer(Duration.zero,wait);
                                          }
                                        }
                                        wait();
                                        return new AlertDialog(
                                            title: new Text("Loading"),
                                            content: new LinearProgressIndicator()
                                        );
                                      }
                                  );
                                  setState((){
                                    isVoting = true;
                                  });
                                  Map<String,dynamic> map;
                                  http.get(Uri.encodeFull(database+"/data/"+widget.code+".json?auth="+secretKey)).then((r){
                                    map = json.decode(r.body);
                                    for(int i = 0; i<widget.scores.length;i++){
                                      widget.scores[i] = widget.oneChoice?map["a"][i]+(i==choicesString.indexOf(choice)?1:0):map["a"][i]+(checked.values.toList()[i]?1:0);
                                    }
                                    String scorePrint = "";
                                    for(int i in widget.scores){
                                      scorePrint+=(i.toString()+", ");
                                    }
                                    scorePrint = scorePrint.substring(0,scorePrint.length-2);
                                    http.put(Uri.encodeFull(database+"/data/"+widget.code+"/a.json?auth="+secretKey),body:"["+scorePrint+"]").then((r){
                                      if(SearchPageState.data!=null&&SearchPageState.data[widget.code]!=null){
                                        SearchPageState.data[widget.code]["a"] = json.decode("["+scorePrint+"]");
                                      }
                                      if(widget.oneResponse){
                                        List<dynamic> users = map["i"];
                                        if(users!=null){
                                          users.add(userId);
                                        }
                                        String userPrint = "";
                                        if(users!=null){
                                          for(String s in users){
                                            userPrint+="\""+s+"\", ";
                                          }
                                          userPrint = userPrint.substring(0,userPrint.length-2);
                                        }
                                        http.put(Uri.encodeFull(database+"/data/"+widget.code+"/i.json?auth="+secretKey),body:(users!=null?"["+userPrint+"]":"[\""+userId+"\"]")).then((r){
                                          if(SearchPageState.data!=null&&SearchPageState.data[widget.code]!=null){
                                            SearchPageState.data[widget.code]["i"] = json.decode(users!=null?"["+userPrint+"]":"[\""+userId+"\"]");
                                          }
                                          choice = null;
                                          if(checked!=null){
                                            checked.forEach((key,b)=>checked[key]=false);
                                          }
                                          s.jumpTo(1.0);
                                          s.jumpTo(0.0);
                                          setState((){isVoting = false;widget.hasVoted=true;widget.vote=false;});
                                        });
                                      }else{
                                        choice = null;
                                        if(checked!=null){
                                          checked.forEach((key,b)=>checked[key]=false);
                                        }
                                        s.jumpTo(1.0);
                                        s.jumpTo(0.0);
                                        setState((){isVoting = false;widget.vote=false;});
                                      }
                                    });
                                  });
                                }else if(widget.oneChoice&&choice==null){
                                  showDialog(
                                      context: context,
                                      builder: (context){
                                        return new AlertDialog(
                                            title:new Text("Error"),
                                            content: new Text("Please make a selection"),
                                            actions: [
                                              new RaisedButton(
                                                  child: new Text("Okay",style:new TextStyle(color: Colors.black)),
                                                  onPressed: (){
                                                    Navigator.of(context).pop();
                                                  },
                                                  color: Colors.grey
                                              )
                                            ]
                                        );
                                      }
                                  );
                                  return;
                                }
                              },
                              child: new Text("Submit",style:new TextStyle(color:Colors.white,fontSize:25.0))
                          ))]
                      )):new Container(),
                      !widget.vote?widget.scores.reduce((a,b)=>a+b)!=0?chart:new Container():new Container(height:20.0)
                    ]
                )/*)*/
            )
        )
    ),
        onWillPop: (){
          isLeaving = true;
          client.close(force:true);
          return new Future<bool>(()=>true);
        });
  }
}

final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();

class PieChart extends StatefulWidget{
  List<dynamic> scores;
  List<dynamic> choices;
  PieChart(this.scores,this.choices);
  @override
  PieChartState createState() => new PieChartState();
}

class PieChartState extends State<PieChart>{
  int selectedScore;
  String selectedName;

  int hexToInt(String colorStr)
  {
    colorStr = "FF" + colorStr;
    colorStr = colorStr.replaceAll("#", "");
    int val = 0;
    int length = colorStr.length;
    for (int i = 0; i < length; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if(hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (length - 1 - i)));
      }else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (length - 1 - i)));
      }else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (length - 1 - i)));
      }else {
        throw new FormatException("An error occurred when converting a color");
      }
    }
    return val;
  }

  @override
  Widget build(BuildContext context){
    Map tempMap = Map.fromIterables(widget.choices, widget.scores);
    SplayTreeMap map = new SplayTreeMap.from(tempMap,(o1,o2)=>tempMap[o2]-tempMap[o1]!=0?tempMap[o2]-tempMap[o1]:widget.choices.indexOf(o1)-widget.choices.indexOf(o2));
    return new AnimatedCircularChart(
        key: _chartKey,
        size: new Size(300.0*MediaQuery.of(context).size.width/360.0, 300.0*MediaQuery.of(context).size.width/360.0),
        chartType: CircularChartType.Pie,
        initialChartData: widget.scores.reduce((o1,o2)=>o1+o2)>0?[new CircularStackEntry(map.keys.map((name){
          return new CircularSegmentEntry(tempMap[name]*1.0,new Color(hexToInt(tempMap.keys.toList().indexOf(name)<11?charts.MaterialPalette.getOrderedPalettes(20)[tempMap.keys.toList().indexOf(name)].shadeDefault.hexString:charts.MaterialPalette.getOrderedPalettes(20)[tempMap.keys.toList().indexOf(name)-11].makeShades(2)[1].hexString)),rankKey:name);
        }).toList())]:[],
        duration: Duration.zero
    );
  }
}

class Option extends StatefulWidget{
  bool isRemoved = false;
  GlobalKey key;
  int position;
  Option(this.position,this.key):super(key:key);
  @override
  OptionState createState() => new OptionState();
}

bool isRemoving = false;

class OptionState extends State<Option>{
  FocusNode f = new FocusNode();
  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(opacity:widget.isRemoved?0.0:1.0,duration:new Duration(milliseconds:300),child:new Container(height: 50.0,padding: EdgeInsets.only(left:!removing?24.0:0.0,right:24.0),child: new Row(children:[
      removing?new IconButton(
          icon: new Icon(Icons.delete),
          onPressed: (){
            if(!widget.isRemoved&&CreatePollState.optionCount>2){
              isRemoving = true;
              CreatePollState.optionCount--;
              setState((){widget.isRemoved = true;});
              new Timer(new Duration(milliseconds:301),(){
                CreatePollState.choices.removeAt(widget.position);
                CreatePollState.list.removeAt(widget.position);
                isRemoving = false;
                for(int i = 0; i<CreatePollState.list.length-1;i++){
                  (CreatePollState.list[i] as Option).position = i;
                  (CreatePollState.list[i] as Option).key.currentState.setState((){});
                  if(i!=widget.position&&(CreatePollState.list[i] as Option).isRemoved){
                    isRemoving = true;
                  }
                }
                context.ancestorStateOfType(new TypeMatcher<CreatePollState>()).setState((){});
              });
            }
          }
      ):new Container(width:0.0,height:0.0),
      new Expanded(child: new TextField(
          focusNode: f,
          decoration: new InputDecoration(
              hintText: 'Option '+(widget.position+1).toString(),
              filled: true,
              fillColor: Colors.white30,
              border: InputBorder.none,
              counterText: ""
          ),
          onChanged: (s){
            CreatePollState.choices[widget.position] = s;
          },
          inputFormatters: [new MaxInputFormatter(64)],
      ))])));
  }
}


class Settings extends StatefulWidget{
  @override
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<Settings>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Settings",style: new TextStyle(color:Colors.white)),backgroundColor: Colors.black54),
        body: new Container(
            child: new Center(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                    ]
                )
            )
        )
    );
  }
}

class SettingsInfo{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/themeinfo.txt');
  }

  Future<List<String>> readData() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();

      if(contents.split(" ").length!=2){
        return null;
      }

      List<String> list = contents.split(" ");

      return list;
    } catch (e) {
      return null;
    }
  }

  Future<File> writeData(String data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }

}

class CreatedInfo{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/createdinfo.txt');
  }

  Future<List<String>> readData() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();

      List<String> list = contents.split(" ");

      return list;
    } catch (e) {
      return null;
    }
  }

  Future<File> writeData(String data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }

}