When building apps there tends to be a case where users need to create a relatively complex piece of data. But, creating a simple to use UI to create said data can be a challenge. This is where [wizards](https://uxdesign.cc/the-wizard-of-user-experience-6926ca41bc9a) come in. Everyone exploring the web has encountered these wizards when creating accounts, entering payment details, etc. I decided to create my own wizard wrapper that I use in my [Crosscheck Sports App](https://crosschecksports.com) multiple times, for creating teams, seasons, events, and polls.

![Wizard Widget UI in Flutter {caption: Images of final product along with a real world use case}](https://raw.githubusercontent.com/jake-landersweb/code_vault/main/flutter-wizard/assets/wizard.png)

## Project Setup

This project will have one required package, [provider](https://pub.dev/packages/provider), for state management, and one optional package, [sprung](https://pub.dev/packages/sprung), for spring-like curves.

```yaml {4-5}
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.4
  sprung: ^3.0.1
```

## Model

We will use a change notifier class to handle the form state for our wizard. This will be held in a class `WizardModel`. This class will handle all of the `PageView` state used later in the view, which is controlled with a `PageController`.

```dart
class WizardModel extends ChangeNotifier {
  late int _index;
  late int numPages;
  late PageController controller;
  late Duration duration;
  late Curve curve;

  WizardModel({
    required this.numPages,
    int initialPage = 0,
    required this.duration,
    required this.curve,
  }) {
    controller = PageController(initialPage: initialPage);
    setIndex(initialPage);
  }
}
```

> model.dart

### Model Methods

This class will also host some methods to allow consumers of the provider access to changing pages. This will include `getPage()`, `setIndex()`, `setPage()`, `nextPage()`, `previousPage()`, and `isAtEnd()`.

```dart {2,7,13,23,32,41}
  /// get the current index
  int getPage() {
    return _index;
  }

  /// set the current index
  void setIndex(index) {
    _index = index;
    notifyListeners();
  }

  /// set the current page
  void setPage(int index) {
    controller.animateToPage(
      index,
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// navigate to the next page
  void nextPage() {
    controller.nextPage(
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// navigate to the previous page
  void previousPage() {
    controller.previousPage(
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// whether the user is at the end of the wizard or not
  bool isAtEnd() {
    return _index == numPages - 1;
  }
```

> model.dart

## Wizard Item

We need a way for us to pass the views we want to present inside this model in an easy to understand and consume way. Each page needs a title, an icon, and a child. So logically, we will create a class to hold this data.

```dart
class WizardItem {
  final String title;
  final IconData icon;
  final Widget child;

  WizardItem({
    required this.title,
    required this.icon,
    required this.child,
  });
}
```

> model.dart

## View

Now onto the meat of the project. Let's break down the view into easy to digest components that we can later combine together to create the full wizard.

### Wizard View

The wizard view is going to be a stateless widget with some various parameters to allow for customization of some aspects of the view. Here is the constructor for this view:

```dart
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
```

> wizard.dart

### Accessing the Provider

The very first thing we need to do with this view is consume the provider. We can do this in our `build()` method. We use the `builder()` method to get access to the provider in the rest of the widget.

```dart {11}
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
```

> wizard.dart

### Navigation

The first component we need to create is the header. This contains a list of these cell-like items that show a page's title and icon.

Each cell will need to be clickable and navigate to the corresponding page. Also, the cells should be highlighted when the current page is equal to or less than the items page index. Here is the code for a cell:

```dart
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
                      : widget.accentColor,
                ),
                color: index > model.getPage()
                    ? Colors.transparent
                    : widget.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            Icon(item.icon,
                color: index > model.getPage()
                    ? widget.accentColor
                    : Colors.white),
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
```

> wizard.dart

Putting the header together is easy, as all we need to make sure is the items are in a row, and then we can apply the Row modifier `mainAxisAlignment: MainAxisAlignment.spaceAround` to make sure the cells space themselves accordingly. We also need to take into account the user's device safe area, and add some extra padding on the top so the wizard looks proper on devices with no safe area.

```dart
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
        for (var i = 0; i < widget.pages.length; i++)
          _cell(context, model, i, widget.pages[i]),
      ],
    ),
  ),
);
```

> wizard.dart

### Action Buttons

In this wizard I have also provided some buttons on the bottom that let the user choose whether they want to swipe between the views or tap buttons. When the user gets to the end of the wizard, the right-most button expanded into an action button the user can tap to complete the wizard. This button accesses the `onComplete()` method the user passes into the wizard.

```dart
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
```

> wizard.dart

### Content

Now, we can create an object to hold the content that the user passed into the widget. We need to use a `PageView` to gain access to the smooth scrolling between the views, and to consume the controller the model provides. There are a few things we need to consider here.

First, we need to use a `Stack` to place the action buttons on top of the rest of the views. Second, the navigation needs to be wrapped in a container to give it a distinct background color. Second, The `PageView` needs to be wrapped in an `Expanded` when used in a Column. Lastly, we need to set the `onPageChanged()` method in the `PageView` to update the model's index whenever the page changes.

```dart
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
```

> wizard.dart

## Using the Wizard

To use this new wizard, all we need to pass in is a list of `WizardItem` and an action! We can also pass in a `curve`, `duration`, `accentColor`, and `initialPage`.

```dart {4-5}
Wizard(
  curve: Sprung.overDamped,
  duration: const Duration(milliseconds: 700),
  onComplete: () {},
  pages: [
    WizardItem(
      title: "Static",
      icon: Icons.star_outline,
      child: const Center(
        child: Text("static page"),
      ),
    ),
    WizardItem(
      title: "Scrollable",
      icon: Icons.scatter_plot_outlined,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.grey,
              child: const SizedBox(
                height: 1000,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    ),
    WizardItem(
      title: "Page 3",
      icon: Icons.three_k,
      child: const Center(
        child: Text("Page 3"),
      ),
    ),
    WizardItem(
      title: "Page 4",
      icon: Icons.four_k,
      child: const Center(
        child: Text("Page 4"),
      ),
    ),
  ],
),
```