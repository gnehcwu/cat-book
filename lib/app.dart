import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:the_cat_book/model/cat.dart';
import 'package:the_cat_book/widget/card.dart';
import 'package:the_cat_book/widget/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_cat_book/model/category.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CatBookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: CatBookSlidershow()));
  }
}

class CatBookSlidershow extends StatefulWidget {
  _CatBookSlidershowState createState() => _CatBookSlidershowState();
}

class _CatBookSlidershowState extends State<CatBookSlidershow>
    with TickerProviderStateMixin {
  final PageController _ctrl = PageController(viewportFraction: 1.0);
  AnimationController _filterAnimationController;
  Animation<double> _opacityAnimation;
  Animation<double> _positionAnimation;
  int _currentPage = 0;
  String _currentTag;
  List<Cat> _slides = List<Cat>();
  List<Cat> _allCats = List<Cat>();
  bool _isLoading = true;
  List<String> _favs;
  SharedPreferences _prefInstance;
  final String _key = 'favs';
  bool _tagPanelExpanded = false;
  double _indicatorToBottom = 35;
  TextEditingController _seachEditingController = TextEditingController();
  FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusNodeListener);
    _currentTag = 'all';
    _filterAnimationController =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this)
          ..addStatusListener((status) {
            setState(() {});
          });

    _positionAnimation = Tween<double>(begin: -300.0, end: 30.0).animate(
        CurvedAnimation(
            parent: _filterAnimationController, curve: Curves.bounceInOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _filterAnimationController, curve: Curves.bounceInOut));

    _loadData().then((data) {
      _allCats = data;
      SharedPreferences.getInstance().then((pref) {
        _prefInstance = pref;
        _favs = _prefInstance.getStringList(_key);
        if (_favs == null) {
          _favs = List<String>();
        }
        _queryData();
      });
    });

    _ctrl.addListener(() {
      int next = _ctrl.page.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  Future<Null> _focusNodeListener() async {
        if (_focusNode.hasFocus){
            setState(() {
              _indicatorToBottom = -35;
            });
        } else {
            setState(() {
              _indicatorToBottom = 35;
            });
        }
    }

  searchCats(String query) {
    setState(() {
      query = query.toLowerCase().trim();
      _slides = _allCats.where((cat) {
        return cat.name.toLowerCase().contains(query)
            || cat.description.toLowerCase().contains(query)
            || cat.temperament.toLowerCase().contains(query)
            || cat.origin.toLowerCase().contains(query)
            || cat.tag.contains(query);
      }).toList();

      if (_slides.length == 0) {
        _slides = _allCats;
      }
      _filterAnimationController.reverse().orCancel;
    });
    scrollToFirstPage();
  }

  _loadData() async {
    List<Cat> entries = new List<Cat>();
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/data/cats.json');
    var jsonData = jsonDecode(data);
    jsonData.forEach((item) {
      entries.add(Cat.fromJson(item));
    });

    return entries;
  }

  _queryData({String tag = 'all'}) {
    setState(() {
      _currentTag = tag;
      _seachEditingController.clear();

      if (tag == 'all') {
        _slides = _allCats;
      } else if (tag == 'favorite') {
        _slides = _allCats.where((cat) => _favs.indexOf(cat.name) > -1).toList();
      } else {
        _slides = _allCats.where((cat) => cat.tag.contains(tag)).toList();
      }

      if (_slides.length == 0) _slides = _allCats;

      _isLoading = false;
    });

    scrollToFirstPage();
  }

  void scrollToFirstPage() {
    if (_currentPage > 0) {
      _ctrl.animateToPage(0,
          duration: Duration(milliseconds: 500), curve: Curves.easeOutSine);
    }
  }

  _fav(String catName) async {
    if (_favs.indexOf(catName) > -1) {
      _favs.remove(catName);

      if (_currentTag == 'favorite') {
        setState(() {
          _slides = _allCats.where((cat) => _favs.indexOf(cat.name) > -1).toList();
          if (_slides.length == 0) {
            _slides = _allCats;
            _currentTag = 'all';
          }
        });
      }
    } else {
      _favs.add(catName);
    }

    await _prefInstance.setStringList(_key, _favs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Container(
          child: _isLoading
              ? new Loading()
              : Stack(
                  children: <Widget>[
                    buildPageView(),
                    buildSearchBar(),
                    buildIndicator(context),
                    buildFilterPanel(),
                    buildTuneButton()
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildIndicator(BuildContext context) {
    var contextSize = MediaQuery.of(context).size;
    return Positioned(
      right: contextSize.width / 2 - 10,
      bottom: _indicatorToBottom,
      child: Text('${_currentPage + 1} / ${_slides.length}',
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(fontFamily: 'Rubik', fontSize: 18)),
    );
  }

  Widget buildSearchBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CupertinoTextField(
              focusNode: _focusNode,
              clearButtonMode: OverlayVisibilityMode.editing,
              keyboardAppearance: Brightness.light,
              padding:
                  EdgeInsets.only(left: 40, right: 10, top: 10, bottom: 10),
              placeholder: 'Searching...',
              textInputAction: TextInputAction.search,
              controller: _seachEditingController,
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200], width: 1),
                color: Colors.white70,
              ),
              onSubmitted: (query) {
                searchCats(query);
              },
            ),
            Positioned(
              left: 10,
              child: Icon(
                Icons.search,
                color: Colors.grey[400],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTuneButton() {
    return Positioned(
        right: 10,
        bottom: 10,
        child: FloatingActionButton(
          child: Icon(FontAwesomeIcons.cat),
          onPressed: () {
            if (!_tagPanelExpanded) {
              _filterAnimationController.forward().orCancel;
            } else {
              _filterAnimationController.reverse().orCancel;
            }
            _tagPanelExpanded = !_tagPanelExpanded;
          },
        ));
  }

  Widget buildFilterPanel() {
    return Positioned(
      bottom: _positionAnimation.value,
      left: 30,
      right: 30,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 8),
                  Icon(
                    Icons.tune,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text('Filter With Tags',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Rubik',
                          fontSize: 20))
                ],
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: categoryList.map((tag) {
                  var isActive = _currentTag == tag;
                  return FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: isActive ? Colors.purple[600] : Colors.white70,
                    child: Text('#$tag',
                        style: TextStyle(
                            fontFamily: 'Rubik',
                            color: isActive ? Colors.white : Colors.black87)),
                    onPressed: () {
                      _queryData(tag: tag);
                      if (_tagPanelExpanded) {
                        _filterAnimationController.reverse().orCancel;
                        setState(() {
                          _tagPanelExpanded = !_tagPanelExpanded;
                        });
                      }
                    },
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  PageView buildPageView() {
    return PageView.builder(
        controller: _ctrl,
        itemCount: _slides.length,
        itemBuilder: (context, int currentIndex) {
          if (_slides.length >= currentIndex) {
            bool active = currentIndex == _currentPage;
            Cat cat = _slides[currentIndex];
            return CatCard(
              cat,
              active,
              _fav,
              _favs,
              key: ObjectKey(cat),
            );
          }
        });
  }
}
