import 'dart:async';

import 'package:stream_transform/stream_transform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/themes/tb_theme.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';

class TbAppBar extends TbContextWidget<TbAppBar, _TbAppBarState> implements PreferredSizeWidget {

  final Widget? title;
  final List<Widget>? actions;
  final double? elevation;
  final bool showLoadingIndicator;

  @override
  final Size preferredSize;

  TbAppBar(TbContext tbContext, {this.title, this.actions, this.elevation,
                                 this.showLoadingIndicator = false}) :
    preferredSize = Size.fromHeight(kToolbarHeight + (showLoadingIndicator ? 4 : 0)),
    super(tbContext);

  @override
  _TbAppBarState createState() => _TbAppBarState();

}

class _TbAppBarState extends TbContextState<TbAppBar, _TbAppBarState> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    children.add(buildDefaultBar());
    if (widget.showLoadingIndicator) {
      children.add(
          ValueListenableBuilder(
              valueListenable: loadingNotifier,
              builder: (context, bool loading, child) {
                if (loading) {
                  return LinearProgressIndicator();
                } else {
                  return Container(height: 4);
                }
              }
          )
      );
    }
    return Column(
      children: children,
    );
  }

  AppBar buildDefaultBar() {
    return AppBar(
      title: widget.title,
      actions: widget.actions,
      elevation: widget.elevation,
    );
  }
}

class TbAppSearchBar extends TbContextWidget<TbAppSearchBar, _TbAppSearchBarState> implements PreferredSizeWidget {

  final double? elevation;
  final bool showLoadingIndicator;
  final String? searchHint;
  final void Function(String searchText)? onSearch;

  @override
  final Size preferredSize;

  TbAppSearchBar(TbContext tbContext, {this.elevation,
    this.showLoadingIndicator = false, this.searchHint, this.onSearch}) :
        preferredSize = Size.fromHeight(kToolbarHeight + (showLoadingIndicator ? 4 : 0)),
        super(tbContext);

  @override
  _TbAppSearchBarState createState() => _TbAppSearchBarState();
}

class _TbAppSearchBarState extends TbContextState<TbAppSearchBar, _TbAppSearchBarState> {

  final TextEditingController _filter = new TextEditingController();
  final _textUpdates = StreamController<String>();

  @override
  void initState() {
    super.initState();
    // _textUpdates.add('');
    _filter.addListener(() {
      _textUpdates.add(_filter.text);
    });
    _textUpdates.stream.skip(1).debounce(const Duration(milliseconds: 150)).distinct().forEach((element) => widget.onSearch!(element));
  }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    children.add(buildSearchBar());
    if (widget.showLoadingIndicator) {
      children.add(
          ValueListenableBuilder(
              valueListenable: loadingNotifier,
              builder: (context, bool loading, child) {
                if (loading) {
                  return LinearProgressIndicator();
                } else {
                  return Container(height: 4);
                }
              }
          )
      );
    }
    return Column(
      children: children,
    );
  }

  AppBar buildSearchBar() {
    return AppBar(
      centerTitle: true,
      title: Theme(
          data: tbDarkTheme,
          child: TextField(
            controller: _filter,
            cursorColor: Colors.white,
            decoration: new InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 15, right: 15),
              hintText: widget.searchHint ?? 'Search',
            ),
          )
      ),
      actions: [
        ValueListenableBuilder(valueListenable: _filter,
            builder: (context, value, child) {
              if (_filter.text.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                      Icons.clear
                  ),
                  onPressed: () {
                    _filter.text = '';
                  },
                );
              } else {
                return Container();
              }
            }
        )
      ]
    );
  }
}