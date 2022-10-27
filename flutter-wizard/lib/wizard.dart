import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/wizard/model.dart';
import 'package:provider/provider.dart';

class Wizard extends StatelessWidget {
  const Wizard({
    super.key,
    required this.pages,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.accentColor = Colors.blue,
    this.initialPage = 0,
  });
  final List<WizardItem> pages;
  final VoidCallback onComplete;
  final Duration duration;
  final Curve curve;
  final Color accentColor;
  final int initialPage;

  Color _textColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Color _backgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return const Color.fromRGBO(242, 242, 248, 1);
    } else {
      return const Color.fromRGBO(30, 30, 33, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WizardModel>(
      create: (_) => WizardModel(
        numPages: pages.length,
        duration: duration,
        curve: curve,
        initialPage: initialPage,
      ),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return _body(context);
      },
    );
  }

  Widget _body(BuildContext context) {
    WizardModel model = Provider.of<WizardModel>(context);
    return Container(
      color: _backgroundColor(context),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _content(context, model),
          _actions(context, model),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, WizardModel model) {
    return Column(
      children: [
        Container(
          color: _textColor(context).withOpacity(0.05),
          child: Column(children: [
            _navigation(context, model),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: model.controller,
            children: [
              for (var i in pages) i.child,
            ],
            onPageChanged: (page) {
              model.setIndex(page);
            },
          ),
        ),
      ],
    );
  }

  Widget _navigation(BuildContext context, WizardModel model) {
    return SafeArea(
      top: true,
      left: false,
      right: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < pages.length; i++)
              _cell(context, model, i, pages[i]),
          ],
        ),
      ),
    );
  }

  Widget _cell(
      BuildContext context, WizardModel model, int index, WizardItem item) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      borderRadius: BorderRadius.zero,
      onPressed: () {
        model.setPage(index);
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.width / 8,
                width: MediaQuery.of(context).size.width / 8,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: index == model.getPage()
                        ? Colors.transparent
                        : accentColor,
                  ),
                  color: index > model.getPage()
                      ? Colors.transparent
                      : accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(item.icon,
                  color: index > model.getPage() ? accentColor : Colors.white),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: _textColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, WizardModel model) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: model.getPage() == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                borderRadius: BorderRadius.zero,
                onPressed: () {
                  if (model.getPage() != 0) {
                    model.previousPage();
                  }
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _textColor(context).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: _textColor(context).withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const Spacer(),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              borderRadius: BorderRadius.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: model.isAtEnd()
                        ? MediaQuery.of(context).size.width / 1.8
                        : 50,
                    height: 50,
                    child: model.isAtEnd()
                        ? const Center(
                            child: Text(
                              "Complete",
                              softWrap: false,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              onPressed: () {
                if (model.isAtEnd()) {
                  onComplete();
                } else {
                  model.nextPage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
