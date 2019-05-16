import 'package:flutter/material.dart';
import 'package:the_cat_book/model/cat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class CatCard extends StatefulWidget {
  final Cat cat;
  final bool active;
  final Function favAction;
  final List<String> favCats;

  const CatCard(this.cat, this.active, this.favAction, this.favCats, {Key key})
      : super(key: key);

  @override
  _CardState createState() => _CardState();
}

class _CardState extends State<CatCard> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  Animation<double> _rightPositionAnimation;
  Animation<double> _topPositionAnimation;
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.favCats.indexOf(widget.cat.name) > -1;

    _controller =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            }
          });
    _animation = Tween<double>(begin: 27.0, end: 37.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));
    _rightPositionAnimation = Tween<double>(begin: -2.0, end: -7.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));
    _topPositionAnimation = Tween<double>(begin: 30, end: 20.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
              margin: EdgeInsets.only(left: 12, right: 12,),
              alignment: Alignment.center,
              child: Container(
                width: double.infinity,
                height: _height * 0.74,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black12)]),
                child: buildCard(),
              ));
        });
  }

  Widget buildCard() {
    return IntrinsicHeight(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[buildHeader(), Expanded(child: buildBody())],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      height: 230,
      child: ClipRRect(
        child: Image.asset(
          widget.cat.image,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(top: 10),
            children: <Widget>[
              Text(
                widget.cat.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Theme.of(context).textTheme.headline.fontSize,
                    fontFamily: "Rubik"),
              ),
              SizedBox(
                height: 9,
              ),
              buildMetricItem('Child Friendly: ', widget.cat.childFriendly),
              buildMetricItem(
                  'Stranger Friendly: ', widget.cat.strangerFriendly),
              buildMetricItem('Dog Friendly: ', widget.cat.dogFriendly),
              buildMetricItem('Health Issue: ', widget.cat.healthIssue),
              buildMetricItem('Energy Level: ', widget.cat.energyLevel),
              buildMetricItem('Social: ', widget.cat.social),
              buildMetricItem('Affection Level: ', widget.cat.affectionLevel),
              buildMetricItem('Intelligence: ', widget.cat.intelligence),
              SizedBox(
                height: 9,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Life Span: ',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Rubik',
                            fontSize: 16)),
                    Text(widget.cat.lifeSpan,
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Rubik')),
                  ]),
              SizedBox(
                height: 9,
              ),
              Text(
                widget.cat.description,
                style: TextStyle(
                    color: Colors.white, fontFamily: "Rubik", fontSize: 16),
              )
            ],
          ),
          Positioned(
            right: 0.0,
            top: 0.0,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.wikipediaW),
              color: Colors.white,
              iconSize: 20.0,
              onPressed: () async {
                if (await canLaunch(widget.cat.wiki)) {
                  await launch(widget.cat.wiki);
                }
              },
            ),
          ),
          Positioned(
            top: _topPositionAnimation.value,
            right: _rightPositionAnimation.value,
            child: IconButton(
              icon: Icon(
                Icons.favorite,
                color: isFavorited ? Colors.red : Colors.white.withOpacity(0.9),
              ),
              iconSize: _animation.value,
              onPressed: () async {
                _controller.forward();
                await widget.favAction(widget.cat.name);
                setState(() {
                  isFavorited = !isFavorited;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Column buildMetricItem(title, value) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 9,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(title,
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Rubik', fontSize: 16)),
            SmoothStarRating(
              color: Colors.white.withOpacity(0.9),
              rating: value.toDouble(),
              borderColor: Colors.white.withOpacity(0.9),
              size: 18,
            ),
          ],
        ),
      ],
    );
  }
}