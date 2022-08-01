import 'package:flutter/material.dart';
import 'dart:math';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        platform: TargetPlatform.windows,
        brightness: Brightness.dark,
      ),
      home: const Home(),
    );
  }
}

const List _photos =[
  'pfp/1.jpg',
  'pfp/2.jpg',
  'pfp/3.jpg',
  'pfp/4.jpg',
  'pfp/5.jpg',
  'pfp/6.png',
  'pfp/7.jpg',
  'pfp/8.jpg',
  'pfp/9.jpg',
];

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: MyScener(),
      ),
    );
  }
}

class CardData{
  late Color color;
  double? x,y,z, angle;
  final int idx;
  double alpha = 0;

  Color get lightColor{
    var val = HSVColor.fromColor(color);
    return val.withSaturation(.5).withValue(.8).toColor();
  }

  CardData(this.idx){
    color = Colors.primaries[idx%Colors.primaries.length];
    x = 0;
    y = 0;
    z = 0;
  }
}

class MyScener extends StatefulWidget {
  const MyScener({Key? key}) : super(key: key);

  @override
  State<MyScener> createState() => _MyScenerState();
}

class _MyScenerState extends State<MyScener> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<CardData> cardData= [];
  int numItems = 9;
  double radio = 200.0;
  late double radioStep;
  int centerIdx = 1;

  @override
  void initState(){
    cardData = List.generate(numItems, (index){
      return CardData(index);
    }).toList();
    radioStep = (pi*2)/numItems;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 15
      )
    );

    _animationController.addListener((){
      setState((){});
    });

    _animationController.addStatusListener((status)async{
      if(status == AnimationStatus.completed){
        _animationController.value = 0;
        _animationController.animateTo(1);
        ++centerIdx;
      }
    });
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = _animationController.value;
    double animValue = centerIdx + ratio;

    for(var i = 0; i<cardData.length; ++i){
      var c = cardData[i];
      double ang = c.idx * radioStep + animValue;
      c.angle = ang + pi / 2;
      c.x = cos(ang) * radio;
      c.z = sin(ang) * radio;
    }

    cardData.sort((a,b){
      return a.z!.compareTo(b.z!);
    });

    var list = cardData.map((vo){
      var c = addCard(vo);
      var mt2 = Matrix4.identity();
      mt2.setEntry(3, 2, 0.001);
      mt2.translate(vo.x, vo.y!, -vo.z!);
      mt2.rotateY(vo.angle! + pi);
      c =  Transform(
        alignment: Alignment.center,
        origin: const Offset(0.0, -0.0),
        transform: mt2,
        child: c,
      );
      return c;
    }).toList();
    
    return Container(
      alignment: Alignment.center,
      //color: Colors.grey[800],
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  "https://pbs.twimg.com/profile_banners/1204978594490961920/1607279384/1500x500"
              ),
              fit: BoxFit.cover),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: list,
      ),
    );
    
  }
  Widget addCard(CardData vo) {
    var alpha = ((1 - vo.z! / radio) / 2) * .6;
    Widget c;
    c = Container(
      margin: const EdgeInsets.all(15),
      width: 100,
      height: 250,
      alignment: Alignment.center,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black.withOpacity(alpha),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.2 + alpha * .2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child:  Image.asset(_photos[vo.idx]),
    );
    return c;
  }
}



