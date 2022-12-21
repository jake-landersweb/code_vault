[SwiftUI](https://developer.apple.com/xcode/swiftui/) and [Flutter](https://flutter.dev) are two popular frameworks for explicitly creating mobile user interfaces. It can be hard to choose what to build your next app with, so building the same screen in both frameworks can shed some light on the pros and cons of both. 

## Comparing the Frameworks

Here are some key differences between Flutter and SwiftUI:

1. Language: Flutter uses the Dart programming language, while SwiftUI uses the Swift programming language.

2. Architecture: Flutter uses a fast and reactive framework that allows developers to build efficient and beautiful user interfaces. SwiftUI, on the other hand, is built on top of Apple's declarative framework and uses a declarative syntax to build user interfaces.

3. Compatibility: Flutter can be used to build applications for Android, iOS, web, desktop, and even embedded devices. SwiftUI, on the other hand, is only compatible with iOS, iPadOS, macOS, watchOS, and tvOS.

4. Community: Flutter has a large and growing community of developers, with a wide range of third-party packages and plugins available. SwiftUI is a newer framework, so it has a smaller community and fewer third-party packages and plugins available.

## End Result:

![Profile page in SwiftUI {caption: Final product of the profile view page, in SwiftUI}](https://raw.githubusercontent.com/jake-landersweb/code_vault/main/swift_vs_flutter-profile/lib/profile.png)

## Avatar

First, we need to start with the avatar. This will be an image loaded from the device, and shaped to be a circle with a slight border. Lets take a look at the Swift and Flutter implementation:

### Swift Avatar

```swift
var avatar: some View {
    ZStack {
        Image("jake")
            .resizable()
            .frame(width: 125, height: 125)
            .clipShape(Circle())
        Circle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 135, height: 135)
    }
}
```

### Flutter Avatar

```dart
Widget _avatar(BuildContext context) {
    return Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 5),
            shape: BoxShape.circle,
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(75),
            child: Image.asset(
                "assets/jake.jpg",
                height: 150,
                width: 150,
            ),
        ),
    );
    }
```

One thing to note about SwiftUI is that there is not an easy way to add a border to a view after adding a clip shape. Therefore, we can use a `ZStack` to add a background circle with our desired border color and size it to be `10px` larger than our profile image. But in Flutter, we are able to add the `decoration` attribute on the `Container`, and add the `border` and `shape` fields to give the circle border effect.

> The reason the Avatars are different sizes is one was using an iPhone 14 pro max simulator, while the other was using the non-max.

## Stats

Next, we can define some user stats that will be shown on the main dashboard page. This will include `Followers` and `Following`.

### Swift Stats

```swift
var stats: some View {
    HStack(spacing: 32) {
        VStack {
            Text("140")
                .font(.system(size: 24))
            Text("Following")
        }
        VStack {
            Text("237")
                .font(.system(size: 24))
            Text("Followers")
        }
    }
    .foregroundColor(.white)
}
```

### Flutter Stats

```dart
Widget _stats(BuildContext context) {
    return Row(
        children: [
            Column(
                children: const [
                    Text(
                        "140",
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        ),
                    ),
                    Text(
                        "Following",
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        ),
                    ),
                ],
            ),
            const SizedBox(width: 32),
            Column(
                children: const [
                    Text(
                        "237",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                        ),
                    ),
                    Text(
                        "Followers",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                        ),
                    ),
                ],
            ),
        ],
    );
}
```

SwiftUI's declarative syntax really shines here, as we do not need to define the text color on every view, just on the surrounding `HStack`. Along with no nested children, this portion of the code is a lot less verbose compared to the Flutter version. In the Flutter version, we need to define the `style` attribute on the `Text` widget for every one. There are ways to get around this with `styles`, but this does not completely alleviate the issue.

## Header

Now, we can combine the two views into a complete header view.

### Swift Header

```swift
HStack {
    avatar
    Spacer()
    stats
    Spacer()
}
```

### Flutter Header

```dart
Row(
    children: [
        _avatar(context),
        const Spacer(),
        _stats(context),
        const Spacer(),
    ],
),
```

When defining basic horizontal and vertical layouts, these two frameworks are shockingly similar. The SwiftUI implementation uses an `HStack`, with Flutter opting for the `Row` widget. referencing the children we created above and the use of the `Spacer` view is the same between both frameworks, and easily readable.

## Content

### Swift Content

```swift
var content: some View {
    VStack(spacing: 8) {
        ForEach(0..<3, id:\.self) { i in
            HStack(spacing: 8) {
                ForEach(0..<3, id:\.self) { j in
                    Rectangle()
                        .fill(bgColorAccent)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }
}
```

### Flutter Content

```dart
Widget _content(BuildContext context) {
return Column(
    children: [
        for (var i = 0; i < 3; i++)
            Row(
                children: [
                    for (var i = 0; i < 3; i++)
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                                color: bgColorAccent,
                                width: double.infinity,
                                child: const AspectRatio(aspectRatio: 1),
                            ),
                        ),
                    ),
                ],
            ),
        ],
    );
}
```

Again, both of the implementations use very similar syntax and structure to accomplish the same thing. The `Columns` in Flutter are `VStacks` in SwiftUI. The `Rows` are `HStacks`. Flutter opts for a more traditional for loop, while SwiftUI uses the `ForEach` view.

## Putting It All Together

### Swift

```swift
struct Profile: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                avatar
                Spacer()
                stats
                Spacer()
            }
            VStack(alignment: .leading) {
                Text("Jake Landers")
                    .foregroundColor(.white)
                    .font(.system(size: 42, weight: .semibold))
                Text("Developer and Creator at SapphireNW")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 18, weight: .semibold))
            }
            Text("Latest Posts")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .semibold))
                .padding(.top, 16)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bgColor)
    }
    
    var avatar: some View {
        ZStack {
            Image("jake")
                .resizable()
                .frame(width: 125, height: 125)
                .clipShape(Circle())
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 135, height: 135)
        }
    }
    
    var stats: some View {
        HStack(spacing: 32) {
            VStack {
                Text("140")
                    .font(.system(size: 24))
                Text("Following")
            }
            VStack {
                Text("237")
                    .font(.system(size: 24))
                Text("Followers")
            }
        }
        .foregroundColor(.white)
    }
    
    var content: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id:\.self) { i in
                HStack(spacing: 8) {
                    ForEach(0..<3, id:\.self) { j in
                        Rectangle()
                            .fill(bgColorAccent)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
}
```

### Flutter

```dart
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: bgColor,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _avatar(context),
                  const Spacer(),
                  _stats(context),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Jake Landers",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Developer and Creator at SapphireNW",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Latest Posts",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _content(context),
            ],
          ),
        ),
      ),
    ),
  );
}
```

The structure between the two views is very similar. Though one main difference is that in the SwiftUI implementation, I am taking advantage of the `spacing` parameter on `VStacks` and `HStacks`. This adds some padding between the views. Accomplishing the same effect in Flutter is not hard though, just using `Sizedbox` wherever necessary.

## Conclusion

Overall, the developer experience in building with these two frameworks are about equal. There are some pros to SwiftUI, while there are others to Flutter. Such as in SwiftUI, animations and overall syntax is a bit more intuitive and less verbose. But with Flutter, there is access to a large community of packages. And using `pub`, adding these packages to your project is trivial. 

Lastly, these are two different tools for two different jobs. Flutter aims to be the most compatible with as many platforms as possible, and to maintain consistency between the platforms. SwiftUI on the other hand, runs a bit faster than the Flutter `Skia` engine, but is locked down to the Apple ecosystem of devices. I know it may be hard to hear, but the platform to choose for your next project **heavily depends** on what your project is.
