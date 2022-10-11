# Dart Neural Network Part 1: Implementation

These are a collection of my thoughts and reflections while working on the project as well as a technical walk-through of some of the functions/classes. If you want to look at the live example, follow [this link](https://nn.jakelanders.com). If you want to see the source code, follow [this link](https://github.com/jake-landersweb/dart_nn).

> This is not meant to be a tutorial on how neural networks work. This is to show the rational behind my own implementation of a neural network. If you are looking for a more interactive tutorial, then the video by Sebastian Lague or the book by Sentdex linked in the next section are great resources, and what I personally used to wrap my head around this implementation.

## Introduction (Skipable)

So you have decided to construct your own neural network. You tell yourself: "Hey! If I create my OWN neural network, I'll understand how they work better!" full of optimism and joy. Maybe you spend an hour or two tinkering around and begin to question why this is even valuable. You spend ages trying to determine the best language to use, factoring in that you want to have some support from a modern language, but you don't want to rely on packages to do the heavy lifting. You get gifted a ([wonderful](https://nnfs.io)) book written in Python that goes through all of the steps on creating your own neural network. Said book goes on to collect dust on your nightstand for 9 months.

But then there comes a day where you are GOING to accomplish the task of creating your own neural network, whatever that looks like. You know you don't know much going in, but you think you have a solid grasp on computer science and mathematics. Then you start reading your book and work for 2 weeks straight getting this damn thing to work properly. You choose Dart as your language, accepting that the performance hits will be worth easily throwing a font-end on your project with [Flutter](https://flutter.dev) (and you tell yourself "I can always port it to rust if I need speed." but you never will).

This fictional character is me and the factors and decisions I made leading up to working on this project. I am not going to lie and say the inspiration was all mine. An excellent video by [Sebastian Lague](https://www.youtube.com/watch?v=hfMk-kjRv4c) walked through his experience creating a neural network in C#. I watched that video and said "Hey! I can totally do that too!". So a couple weeks after watching that video, I set out on my journey to finally build my neural network.

## Inspiration

I followed the [Neural Networks from Scratch in Python](https://nnfs.io) book pretty heavily. If you have not bought that book from the great artificial intelligence Youtuber [Sentdex](https://www.youtube.com/channel/UCfzlCWGWYyIQ0aLC5w48gBQ), I cannot recommend it highly enough. The way he walks through the explanations and math behind how a particular function works before showing the Python implementation was fundamental to me learning the math behind the network.

## Vector Class

After the first few chapters of the book, it became extremely evident that I am going to need a class to handle some of the advanced arithmetic that you get when using Numpy. As my goal with this project was to use as few packages as possible (preferably 0), my own implementation was necessary.

My implementation is one that is not impossible to extend to greater than 2D arrays, but would require some work. An abstract class named `Vector` was created to give some common functionality between a 1D array and 2D array. This class implements the `iterable` trait, and as such needs tons of overload functions that I did not include here.

### Vector Abstract Class

```dart {3}
abstract class Vector<T> implements Iterable {
    /// list the vector is built around
    late List<T> val;
    ...
}
```

> [lib/vector/vector.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/vector/vector.dart)

Ths is the base class that powers most of the vector and matrix math needed by the network. After this basic implementation, two classes that implement this class were created: `Vector1` and `Vector2`. This may have not been the most accurate naming choice for what these classes do, but to me they made sense. `Vector1` is a 1D vector, and `Vector2` is a 2D vector.

The following is from `vector1.dart` and `vector2.dart` to show the class along with the constructors I created.

### Vector1

```dart
class Vector1 extends Vector<num> {
  /// Create a 1D vector with a size of [size] filled with [fill].
  Vector1(int size, {num fill = 0}) {
    val = List.generate(size, (index) => fill);
  }

  /// Create a 1D vector from a 1D array
  Vector1.from(List<num> list) {
    val = List.from(list);
  }

  /// Create a copy of the vector from the passed [Vector1].
  Vector1.fromVector(Vector1 vec) {
    val = List.from(vec.val);
  }

  /// Create an empty 1D vector
  Vector1.empty() {
    val = [];
  }

  /// Create a 1D vector of size [size] filled with random
  /// double values multiplied by [scaleFactor]. [seed] can be
  /// used to set the seed of the Random class from dart:math.
  Vector1.random(int size, {double scaleFactor = 0.01, int seed = seed}) {
    math.Random rng = math.Random(seed);
    List<num> out = [];
    for (var i = 0; i < size; i++) {
      out.add(rng.nextDouble() * scaleFactor);
    }
    val = out;
  }

  /// Create a vector of the same shape as the passed
  /// vector filled with the value of [fill]
  Vector1.like(Vector1 vec, {num fill = 0}) {
    val = List.generate(vec.length, (index) => fill);
  }

  ...
}
```

> [lib/vector/vector1.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/vector/vector1.dart)

### Vector2

```dart
class Vector2 extends Vector<Vector1> {
  Vector2 get T {
    List<List<num>> out = List.generate(this[0].length, (_) => []);

    for (var i = 0; i < length; i++) {
      for (var j = 0; j < this[i].length; j++) {
        out[j].add(this[i][j]);
      }
    }

    return Vector2.from(out);
  }

  /// Generate an empty 2D vector of [rows, height]
  Vector2(int rows, int cols, {num fill = 0}) {
    val = List.generate(
      rows,
      (_) => Vector1(cols, fill: fill),
    );
  }

  /// Create a 2D vector from a 2D array
  Vector2.from(List<List<num>> list) {
    val = List.from([for (var i in list) Vector1.from(i)]);
  }

  /// Generate copy of the passed [vec]
  Vector2.fromVector(Vector2 vec) {
    val = List.from([for (var i in vec.val) Vector1.fromVector(i)]);
  }

  // Create an empty 2D vector
  Vector2.empty() {
    val = [];
  }

  /// Create a 2D vector of size [rows, cols] filled with
  /// random values multipled by [scaleFactor]. [seed] can
  /// be used to set the value of the Random class from dart:math.
  Vector2.random(int rows, int cols,
      {double scaleFactor = 0.01, int seed = seed}) {
    math.Random rng = math.Random(seed);
    Vector2 list = Vector2.empty();
    for (var i = 0; i < rows; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < cols; j++) {
        var rand = rng.nextDouble() * scaleFactor;
        if (rng.nextBool()) {
          rand = -rand;
        }
        temp.add(rand);
      }
      list.add(temp);
    }
    val = list.val;
  }

  /// Create a 2D vector that is of size [size, size].
  /// Each diagonal will be filled with the value of [fill] (default 1),
  /// and the rest of the values filled with 0.
  /// For example, an eye of 3 will look like:
  /// ```
  /// [[1,0,0]
  ///  [0,1,0]
  ///  [0,0,1]]
  /// ```
  Vector2.eye(int size, {int fill = 1}) {
    Vector2 out = Vector2.empty();
    for (var i = 0; i < size; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < size; j++) {
        if (i == j) {
          temp.add(fill);
        } else {
          temp.add(0);
        }
      }
      out.add(temp);
    }
    val = out.val;
  }

  /// Create a 2D vector from a 1D array in the form of [eye].
  /// This will create a 2D vector in the size of [input.length, input.length],
  /// with the values of the array making up the diagonal and the
  /// rest of the values being filled with 0
  /// For example, with a passed of array = [5,4,3], the created
  /// vector will look like:
  /// ```
  /// [[5,0,0]
  ///  [0,4,0]
  ///  [0,0,3]]
  /// ```
  Vector2.diagonalFlat(List<num> input) {
    Vector2 out = Vector2.empty();
    for (var i = 0; i < input.length; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < input.length; j++) {
        if (i == j) {
          temp.add(input[i]);
        } else {
          temp.add(0);
        }
      }
      out.add(temp);
    }
    val = out.val;
  }

  /// Create a vector of the same shape as the passed [vec]
  /// filled with the value of [fill].
  Vector2.like(Vector2 vec, {num fill = 0}) {
    List<Vector1> out = [];
    for (Vector1 i in vec) {
      out.add(Vector1.like(i, fill: fill));
    }
    val = out;
  }

  ...
}
```

> [lib/vector/vector2.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/vector/vector2.dart)

As it should be evident from the code samples above, the `Vector1` class is a basic wrapper around a `List<num>` type. `Vector2` is very similar, just instead of a `List<List<num>>`, I use `List<Vector1>` to get some free functionality out of the `Vector1` class.

### Why Create a Vector Class?

Now why would I choose to just wrap a `List<num>` in a pointless class that would just cause confusion? The answer lies in vector arithmetic. While the concepts behind dot products and vector addition/subtraction/etc. may be simple, having to re-implement them over and over again is a hassle and inefficient. And while most of the functionality may have been accomplished by extending the `List<num>` type, the arithmetic plus the constructors in an object oriented language just made sense to me.

### Dot Product

The first thing I tried to tackle was the Dot product. The challenge here was to allow for (1D, 1D), (1D, 2D), and (2D, 2D) products.

```dart {5,8,13,16}
Vector dot(Vector v1, Vector v2) {
  if (v1 is Vector1) {
    if (v2 is Vector1) {
      // both 1D
      return _dot1D1D(v1, v2);
    } else {
      // v1 1D v2 2D
      return _dot1D2D(v1, v2 as Vector2);
    }
  } else {
    if (v2 is Vector1) {
      // v1 is 2D v2 is 1D
      return _dot1D2D(v2, v1 as Vector2);
    } else {
      // both 2D
      return _dot2D2D(v1 as Vector2, v2 as Vector2);
    }
  }
}
```

> Wrapper dot function

```dart
Vector1 _dot1D1D(Vector1 v1, Vector1 v2) {
  assert(v1.length == v2.length, "Lists must be the same length");
  double out = 0;
  for (int i = 0; i < v1.length; i++) {
    out += v1[i] * v2[i];
  }
  return Vector1.from([out]);
}

Vector1 _dot1D2D(Vector1 v1, Vector2 v2) {
  assert(v1.length == v2[0].length,
      "The elements in v2 should be the same length as v1");
  List<num> out = [];
  for (var i = 0; i < v2.length; i++) {
    out.add(_dot1D1D(v1, v2[i]).first);
  }
  return Vector1.from(out);
}

Vector2 _dot2D2D(Vector2 v1, Vector2 v2) {
  assert(v1[0].length == v2.length,
      "v2 must have the same length as the element length inside of v1");
  Vector2 transposedv2 = v2.T;

  List<List<num>> out = [];
  for (var i in v1.val) {
    List<num> col = [];
    for (var j in transposedv2.val) {
      col.add(_dot1D1D(i, j).first);
    }
    out.add(col);
  }

  return Vector2.from(out);
}
```

> [lib/vector/functions.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/vector/functions.dart)

### Vector Arithmetic

The hardest part to get right was the arithmetic. I had to rewrite this function multiple times because there would be some little issue plaguing me. You can check the commit history to see the evolution of this code. There are 4 different operations I implemented here. Addition, subtraction, multiplication, and division. The meat of the code is wrapped inside a function that takes an arithmetic function as an argument, to allow passing +,-,*,/ into. 

```dart {6,16,25,34}
  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator +(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 + x2);
  }

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator -(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 - x2);
  }

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator *(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 * x2);
  }

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator /(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 / x2);
  }
```

```dart
  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector _arithmetic(dynamic other, num Function(num x1, num x2) arithmetic) {
    // check if other is of type num
    if (other is num) {
      if (this is Vector1) {
        Vector1 out = Vector1.empty();
        for (num i in val as List<num>) {
          out.add(arithmetic(i, other));
        }
        return out;
      } else if (this is Vector2) {
        Vector2 out = Vector2.fromVector(this as Vector2);
        for (var i = 0; i < length; i++) {
          for (var j = 0; j < out[i].length; j++) {
            out[i][j] = arithmetic(out[i][j], other);
          }
        }
        return out;
      } else {
        throw "Vector is not of type Vector1 or Vector2";
      }
    }
    // determine types of vectors to add
    if (this is Vector1) {
      if (other is Vector1) {
        // both 1D
        assert(
          val.length == other.val.length,
          "Both vectors need to be the same length",
        );
        Vector1 list = Vector1.empty();
        for (var i = 0; i < val.length; i++) {
          list.add(arithmetic((val[i] as num), (other.val[i])));
        }
        return list;
      } else {
        // this is 1D, other is 2D
        assert(
          val.length == (other.val[0] as Vector1).length,
          "The first vector's length needs to match the elements inside the second vector's length",
        );
        Vector2 list = Vector2.empty();
        for (var i = 0; i < other.val.length; i++) {
          Vector1 temp = Vector1.empty();
          for (var j = 0; j < (other.val[i] as Vector1).length; j++) {
            temp.add(arithmetic((val[j] as num), other.val[i][j]));
          }
          list.add(temp);
        }
        return list;
      }
    } else {
      if (other is Vector1) {
        // this is 2D, other is 1D
        assert(
          (val[0] as Vector1).length == other.val.length,
          "The first vector item's length needs to match the second vector's length",
        );
        Vector2 list = Vector2.empty();
        for (var i = 0; i < val.length; i++) {
          Vector1 temp = Vector1.empty();
          for (var j = 0; j < (val[i] as Vector1).length; j++) {
            temp.add(arithmetic((other.val[j]), (val[i] as Vector1)[j]));
          }
          list.add(temp);
        }
        return list;
      } else {
        // both 2D
        Vector2 list = Vector2.empty();

        for (var i = 0; i < val.length; i++) {
          Vector1 temp = Vector1.empty();
          for (var j = 0; j < (val[i] as Vector1).length; j++) {
            if (other[0].length == 1) {
              if (other.length == 1) {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[0] as Vector1)[0]));
              } else {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[i] as Vector1)[0]));
              }
            } else {
              if (other.length == 1) {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[0] as Vector1)[j]));
              } else {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[i] as Vector1)[j]));
              }
            }
          }
          list.add(temp);
        }
        return list;
      }
    }
  }
```

> [/lib/vector/vector.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/vector/vector.dart)

As you may be able to see, this implementation is pretty rough. I manually check for types, and throw errors when those types are not found. The result of this is the code gets to exist only once, but when using this function you need to cast the result to the type you "expect" (either a `Vector1` or a `Vector2`). This is not safe at all, but works if you know the implementation.

Another limitation of this function is the inability to reverse the arithmetic. This is not an issue for addition or multiplication because 1 + 5 = 5 + 1 and 1 * 5 = 5 * 1. But this is not true for subtraction and division. So I created a function named `replaceWhere` in each of the vector classes that lets you perform more fine-tuned actions on the elements inside the vector. For example, you can use this function to subtract 1 by all values in the vector and return the results in another vector.

```dart
  /// Create a [Vector1] containing all of the values
  /// returned by the [logic] function and return this
  /// [Vector1].
  Vector1 replaceWhere(num Function(int index) logic) {
    Vector1 out = Vector1.like(this);
    for (int i = 0; i < length; i++) {
      out[i] = logic(i);
    }
    return out;
  }

  /// Create a [Vector2] containing all of the values
  /// returned by the [logic] function and return this
  /// [Vector2].
  Vector2 replaceWhere(num Function(int i, int j) logic) {
    Vector2 out = Vector2.like(this);
    for (int i = 0; i < length; i++) {
      for (int j = 0; j < this[i].length; j++) {
        out[i][j] = logic(i, j);
      }
    }
    return out;
  }
```

> [/lib/vector](https://github.com/jake-landersweb/dart_nn/blob/main/lib/vector/)

### Printing 2D Vectors

During debugging of the program, I needed a way to print the contents of the 2D vector in a way I could tell what was actually contained by the lists. I drew heavy inspiration from numpy. This implementation is far from perfect, but does the job well enough.

```dart
  @override
  String toString({int precision = 6}) {
    String calc(Vector2 list, bool exp, int startIndex) {
      late String out;
      if (startIndex == 0) {
        out = "[";
      } else {
        out = " ";
      }
      for (var i = 0; i < list.length; i++) {
        out += " ${startIndex + i} [";
        for (var j = 0; j < list[i].length; j++) {
          if (!list[i][j].isNegative) {
            out += " ";
          }
          if (exp) {
            out += list[i][j].toStringAsExponential(precision);
          } else {
            out += list[i][j].toStringAsFixed(precision);
          }
          if (j != list[i].length - 1) {
            out += " ";
          }
        }
        out += "]";
        if (i != list.length - 1) {
          out += "\n ";
        } else {
          out += "]";
        }
      }
      return out;
    }

    if (length > 10) {
      Vector2 beg = subVector(0, 5) as Vector2;
      Vector2 end = subVector(length - 5, length) as Vector2;
      String out1 =
          calc(beg, beg.any((e1) => e1.any((e2) => e2 != 0 && e2 < 0.001)), 0);
      String out2 = calc(
          end,
          end.any((e1) => e1.any((e2) => e2 != 0 && e2 < 0.001)),
          val.length - 5);
      return "$out1\n  ...\n$out2";
    } else {
      return calc(
          this, val.any((e1) => e1.any((e2) => e2 != 0 && e2 < 0.001)), 0);
    }
  }
```

> [/lib/vector/vector2.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/vector/vector2.dart)

There is tons more code contained inside the vector classes that give more functionality, like `sum()`, `abs()`, `flatMax()`, `pow()`, `sqrt()`, `exp()`, and `log()`.

## Layers

I implemented 1 type of layer, a fully connected dense layer. All of the types of functions have an abstract class holding shared functionality along with specific implementations in corresponding files. For the layer, as there is only 1 implementation, this does not make much sense. But it does pave the way if other layers are to be implemented, such as a dropout layer.

The layer also has an activation function wrapped inside of it so that the function does not need to be called separately. These could be separated easily, and might have to based on more complex networks.

### Abstract Class

```dart
abstract class Layer {
  late Vector2 weights;
  late Vector2 biases;
  late Activation activation;
  late int inputSize;
  late int numNeurons;
  Vector2? inputs;
  Vector2? output;

  // back prop values
  Vector2? dweights;
  Vector2? dbiases;
  Vector2? dinputs;

  // momentum values
  Vector2? weightMomentums;
  Vector2? biasMomentums;

  // weight cache values
  Vector2? weightCache;
  Vector2? biasCache;

  // regularization values
  late double weightRegL1;
  late double weightRegL2;
  late double biasRegL1;
  late double biasRegL2;

  // constructors
  Layer();
  Layer.fromMap(Map<String, dynamic> map);

  // required functional implementations
  void forward(Vector2 inputs);
  void backward(Vector2 dvalues);

  @override
  String toString() {
    return "Inputs:\n$inputs\nWeights:\n$weights\nBiases:\n$biases\ndWeights:\n$dweights\ndBiases:\n$dbiases\ndInputs:\n$dinputs";
  }
  ...
}
```

> [/lib/layers/layer.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/layers/layer.dart)

The rest of the class contains functions from saving and loading the layer values from json values, which is how I save the network.

### Dense Layer

#### Layer Forward Pass

The forward pass is pretty easy to comprehend. The inputs to the layer are saved in memory, then the dot product of the inputs and weights is taken, with a bias added. This value makes up the output, which is in turned passed through the forward pass of the activation function.

```dart {11}
  @override
  void forward(Vector2 inputs) {
    assert(inputs[0].length == weights.length,
        "The elements inside of inputs need to be of the same length as the weights");
    // save the inputs for backprop
    this.inputs = inputs;
    // run forward pass
    // output = (dot(inputs, weights) + biases) as Vector2;

    // send though activation function
    activation.forward((dot(inputs, weights) + biases) as Vector2);
    output = activation.output;
  }
```

#### Layer Backward Pass

The first operation performed on the backward pass is the activation function backward pass. The result of which is bound to `activation.dinputs`. Then, a gradient descent function is performed on the values, slightly tweaking each of the weights and biases of the layers based on the activation function.

The last part of the function is some regularization. This is to ensure the network does not rely on any one neuron too much. L1 is not used much at all, with L2 being the main way this is accomplished.

```dart
  @override
  void backward(Vector2 dvalues) {
    assert(inputs != null, "inputs is null, run forward() first");
    // send through activation function
    activation.backward(dvalues);

    // gradients on params
    dweights = dot(inputs!.T, activation.dinputs!) as Vector2;
    dbiases = activation.dinputs!.sum(axis: 0, keepDims: true) as Vector2;

    // gradients on regularization
    if (weightRegL1 > 0) {
      var dL1 = Vector2.like(weights, fill: 1);
      dL1 = dL1.replaceWhere((i, j) => weights[i][j] < 0 ? -1 : dL1[i][j]);
      dweights = dweights! + (dL1 * weightRegL1) as Vector2;
    }
    if (weightRegL2 > 0) {
      dweights = dweights! + (weights * (2 * weightRegL2)) as Vector2;
    }
    if (biasRegL1 > 0) {
      var dL1 = Vector2.like(biases, fill: 1);
      dL1 = dL1.replaceWhere((i, j) => biases[i][j] < 0 ? -1 : dL1[i][j]);
      dbiases = dbiases! + (dL1 * biasRegL1) as Vector2;
    }
    if (biasRegL2 > 0) {
      dbiases = dbiases! + (biases * (2 * biasRegL2)) as Vector2;
    }

    // gradients on values
    dinputs = dot(activation.dinputs!, weights.T) as Vector2;
  }
```

> [/lib/layers/layer_dense.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/layers/layer_dense.dart)

## Activation Functions

Activation functions are incredibly important for the learning behavior of the network. They decide how to tweak the weights and biases of the network.

The following activation functions were implemented:

- [ReLU](https://github.com/jake-landersweb/dart_nn/blob/main/lib/activation/relu.dart)
- [Sigmoid](https://github.com/jake-landersweb/dart_nn/blob/main/lib/activation/sigmoid.dart)
- [Softmax](https://github.com/jake-landersweb/dart_nn/blob/main/lib/activation/softmax.dart)

### Abstract Class

Again, an abstract class was used to hold some common code between all of the activation functions.

```dart {5-6}
abstract class Activation {
  Vector2? inputs;
  Vector2? output;
  Vector2? dinputs;

  void forward(Vector2 inputs);
  void backward(Vector2 dvalues);

  String name();
}
```

> [/lib/activation/activation.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/activation/activation.dart)

### ReLU

I will only go over one activation function, but this is probably the most important one. I use this activation function inside the hidden layer, and a sigmoid activation function for the output.

#### ReLU Forward Pass

The forward pass for the ReLU activation function is painfully simple. If the value is below 0, set it to 0. If the value is above 0, keep the value the same.

```dart {8}
  @override
  void forward(Vector2 inputs) {
    // save inputs
    this.inputs = Vector2.fromVector(inputs);
    // print(inputs.subVector(1, 2));

    // calculate the output values from the inputs
    output = maximum(0, inputs) as Vector2;
    // print(output!.subVector(1, 2));
  }
```

> [/lib/activation/relu.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/activation/relu.dart)

#### ReLU Backward Pass

The backward pass is the exact same concept. I did this implementation much later than the forward pass, so I forgot the `maximum()` function existed, so I used the `replaceWhere()` function instead. It results in the exact same output regardless.

```dart
  @override
  void backward(Vector2 dvalues) {
    // make a copy of dvalues since we will be modifying it
    dinputs = Vector2.fromVector(dvalues);
    // print(dinputs!.subVector(1, 2));

    // zero the gradient where the values are negative
    dinputs =
        dinputs!.replaceWhere((i, j) => inputs![i][j] < 0 ? 0 : dinputs![i][j]);
    // for (var i = 0; i < inputs!.length; i++) {
    //   for (var j = 0; j < inputs![i].length; j++) {
    //     if (inputs![i][j] < 0) {
    //       dinputs![i][j] = 0;
    //     }
    //   }
    // }

    // print(dinputs!.subVector(1, 2));
  }
```

> [/lib/activation/relu.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/activation/relu.dart)

## Loss Functions

Another critical component of the network is the loss function. This is the beginning of the backwards pass for the network. There is a lot of math that goes into a loss function, and the two that were implemented are as follows:

- [Categorical Cross-entropy](https://github.com/jake-landersweb/dart_nn/blob/main/lib/loss/cat_crossentropy.dart)
- [Binary Cross-entropy](https://github.com/jake-landersweb/dart_nn/blob/main/lib/loss/binary_crossentropy.dart)

### Categorical Cross-Entropy

For the example that I have hosted at [nn.jakelanders.com](https://nn.jakelanders.com), the network needs to give the percent confidence for each number that it thinks each digit is. So, we need the network to "categorize" the values. So, we are going to use the categorical cross-entropy loss function.

#### Loss Forward Pass

For the forward pass, we are going to clip each input between 1e-7 and 1-1e-7 to avoid taking the log of 0.

```dart {10-11}
  @override
  Vector1 forward(Vector2 predictions, Vector1 labels) {
    assert(predictions.length == labels.length,
        "The prediction length and label length need to match");
    Vector1 loss = Vector1.empty();

    for (var i = 0; i < predictions.length; i++) {
      // need to avoid taking the log of 0
      // make the max value 1 - 1e-7, and min value 1e-7
      loss.add(-math.log(math.min(
          math.max(predictions[i][labels[i].round()], 1e-7), 1 - 1e-7)));
    }
    return loss;
  }
```

> [/lib/loss/cat_crossentropy.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/loss/cat_crossentropy.dart)

#### Loss Backward Pass

For the backwards pass, we need to compare the `dvalues` and the labels (`yTrue`). First, we convert to a one hot vector (where the non-correct indexes are 0 with the correct being 1), and divide the negative values of the one hot vector by the input dvalues. Then, we divide this `dinputs` value by the samples.

```dart {10,12-13}
  @override
  void backward(Vector2 dvalues, Vector1 yTrue) {
    var samples = dvalues.length;
    var labels = dvalues[0].length;

    // convert y to one-hot vector
    Vector2 eyeTemp = Vector2.eye(labels);
    Vector2 yTrueOneHot = Vector2.empty();
    for (var i = 0; i < dvalues.length; i++) {
      yTrueOneHot.add(eyeTemp[yTrue[i] as int]);
    }
    Vector2 dinputs = ((yTrueOneHot * -1) / dvalues) as Vector2;
    dinputs = (dinputs / samples) as Vector2;

    this.dinputs = dinputs;
  }
```

> [/lib/loss/cat_crossentropy.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/loss/cat_crossentropy.dart)

## Optimizers

Optimizers are what allow a network to learn. This is where you hear terms such as `learningRate` and `decay`. By far the most popular optimizer for neural networks is the Adam optimizer. This is a cumulation of some other optimizer types with some various tweaks to make it especially powerful. It pulls ideas from the SGD optimizer and the RMS Prop optimizer.

The following optimizers were implemented:

- [Ada Grand](https://github.com/jake-landersweb/dart_nn/blob/main/lib/optimizer/ada_grand.dart)
- [Adam](https://github.com/jake-landersweb/dart_nn/blob/main/lib/optimizer/adam.dart)
- [RMS Props](https://github.com/jake-landersweb/dart_nn/blob/main/lib/optimizer/rms_prop.dart)
- [SGD](https://github.com/jake-landersweb/dart_nn/blob/main/lib/optimizer/sgd.dart)

### Abstract Class

```dart
abstract class Optimizer {
  late double learningRate;
  late double currentLearningRate;
  late double decay;
  late int iterations;

  // constructors
  Optimizer();
  Optimizer.fromMap(Map<String, dynamic> values);

  /// To be called before each layer has been optimized
  void pre();

  /// Update the layer with the specified optimizer function
  void update(Layer layer);

  /// To be called after all layers have been optimized
  void post();

  // basic name
  String name();

  /// to convert the optimizer to a map for json storage
  Map<String, dynamic> toMap();
}
```

> [/lib/optimizer/optimizer.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/optimizer/optimizer.dart)

### Adam Optimizer

The adam optimizer has some serious math behind the operations. I am not going to get into the technical details, partly because I am not qualified to speak on how this all works. I highly recommend Neural Networks from Scratch in Python. It gives a fantastic explanation behind the how AND why of all of the optimizers.

```dart
  @override
  void pre() {
    if (decay != 0) {
      currentLearningRate = learningRate * (1 / (1 + decay * iterations));
    }
  }

  @override
  void update(Layer layer) {
    // initialize momentum and cache values
    layer.weightMomentums ??=
        Vector2(layer.weights.shape[0], layer.weights.shape[1]);
    layer.weightCache ??=
        Vector2(layer.weights.shape[0], layer.weights.shape[1]);
    layer.biasMomentums ??=
        Vector2(layer.biases.shape[0], layer.biases.shape[1]);
    layer.biasCache ??= Vector2(layer.biases.shape[0], layer.biases.shape[1]);

    // update the momentum with the current gradient
    layer.weightMomentums = (layer.weightMomentums! * beta1) +
        (layer.dweights! * (1 - beta1)) as Vector2;
    layer.biasMomentums = (layer.biasMomentums! * beta1) +
        (layer.dbiases! * (1 - beta1)) as Vector2;

    // get correct momentum
    // iterations is 0 at first pass, and we need to start with 1 here
    Vector2 weightMomentumsCorrected = layer.weightMomentums! /
        (1 - math.pow(beta1, iterations + 1)) as Vector2;
    Vector2 biasMomentumsCorrected =
        layer.biasMomentums! / (1 - math.pow(beta1, iterations + 1)) as Vector2;

    // update the cache with the squared current gradients
    layer.weightCache = (layer.weightCache! * beta2) +
        (layer.dweights!.pow(2) * (1 - beta2)) as Vector2;
    layer.biasCache = (layer.biasCache! * beta2) +
        (layer.dbiases!.pow(2) * (1 - beta2)) as Vector2;

    // get corrected cache
    Vector2 weightCacheCorrected =
        layer.weightCache! / (1 - math.pow(beta2, iterations + 1)) as Vector2;
    Vector2 biasCacheCorrected =
        layer.biasCache! / (1 - math.pow(beta2, iterations + 1)) as Vector2;

    // vanilla sgd parameter update + normalization with square root cache
    layer.weights = layer.weights +
        ((weightMomentumsCorrected * -currentLearningRate) /
            (weightCacheCorrected.sqrt() + epsilon)) as Vector2;
    layer.biases = layer.biases +
        ((biasMomentumsCorrected * -currentLearningRate) /
            (biasCacheCorrected.sqrt() + epsilon)) as Vector2;
  }

  @override
  void post() {
    iterations += 1;
  }
```

> [/lib/optimizer/adam.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/optimizer/adam.dart)

## Neural Network Class

Now to pull this all together. All that composes a neural network is a list of layers with an activation function, a loss function, and an optimizer. That's it. So defining a class to hold all of these options is fairly simple.

I have some extra required fields in the network class to better protect myself from randomly creating parameters, having the network perform well, and completely forget what the network looked like. These options get thrown into a metadata file when the network is saved to disk.

```dart {5,9,14,17,23,27}
class NeuralNetwork {
  /// list of layers that the model will run through. The first
  /// layer size should accept the size of your input, and the last
  /// layer should be your output layer giving your output.
  late List<Layer> layers;

  /// The loss function to use. The available functions are:
  /// [LossBinaryCrossentropy] and [LossCategoricalCrossentropy].
  late Loss lossFunction;

  /// Which optimizer to use. This will usually be adam, but other
  /// loss functions are available. This includes: [OptimizerAdaGrad],
  /// [OptimizerAdam], [OptimizerRMSProp], and [OptimizerSGD].
  late Optimizer optimizer;

  /// An accuracy class to use. There is only one option: [Accuracy].
  late Accuracy accuracy;

  /// The batch size to split the training or testing data into.
  /// using larger batch sizes will usually result in better
  /// network performance, up to a certain limit. A good number
  /// for this is 128. The default is 1.
  int? batchSize;

  /// The seed used to generate any data, will be saved in the model
  /// output for you to reference later.
  late int seed;

  /// The name of the dataset used. This is not used anywhere except
  /// when saving the model, required to make sure you keep
  /// proper track of what data your network was trained on.
  late String dataset;

  /// A description to describe any random information that you may
  /// want to reference later when a model is saved
  late String metadata;

  /// Create a neural network with the list of Layers in [layers],
  /// a [lossFunction], and an [optimizer]. There are some other
  /// parameters that are required in order to properly generate
  /// an output. These consist of [seed], [dataset], and [metadata].
  NeuralNetwork({
    required this.layers,
    required this.lossFunction,
    required this.optimizer,
    required this.seed,
    required this.dataset,
    required this.metadata,
    this.batchSize,
  }) : assert(layers.isNotEmpty, "Layers cannot be an empty list") {
    accuracy = Accuracy();
  }
  ...
}
```

> [/lib/neural_network.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/neural_network.dart)

### Network Forward Pass

The forward pass is as simple as running through the layers which in turn will pass through the activation functions for the layers.

```dart {5,7}
  Vector2 _forward(Vector2 trainingData) {
    // pass through layers
    for (int i = 0; i < layers.length; i++) {
      if (i == 0) {
        layers[i].forward(trainingData);
      } else {
        layers[i].forward(layers[i - 1].output!);
      }
    }

    return layers.last.output!;
  }
```

> [/lib/neural_network.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/neural_network.dart#L200)

### Network Backward Pass

The backwards pass is simple as well. The loss function is called first, then all of the layers are ran through as well.

```dart {7,9}
  void _backward(Vector2 predictions, Vector1 trainingLabels) {
    // backwards pass
    lossFunction.backward(predictions, trainingLabels);
    // loop backwards through all layers
    for (int i = layers.length - 1; i > -1; i--) {
      if (i == layers.length - 1) {
        layers[i].backward(lossFunction.dinputs!);
      } else {
        layers[i].backward(layers[i + 1].dinputs!);
      }
    }
  }
```

> [/lib/neural_network.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/neural_network.dart#L213)

### Training the Network

These two functions, `_forward()` and `_backward()`, are called from both the `train()` and the `test()` function. The `train()` function is a little more involved. We need to factor in epochs, batches, and optimization. The epochs are simple, it is just how many times we run through the data. The batch size is a bit tricky. We need to pull sub vectors corresponding to the amount of loops we need to run to pass through the entire training data. The code for which is as follows:

```dart
    batchSize ??= trainingData.shape[0];
    // calculate step number
    int steps = (trainingData.shape[0] / batchSize!).round();
    // include any stragling data
    if (steps * batchSize! < trainingData.shape[0]) {
      steps += 1;
    }
    print("# Beginning training of model:");
    print("# epochs: $epochs, batch size: $batchSize, steps: $steps");

    for (int epoch = 0; epoch < epochs; epoch++) {
      // reset accumulated values
      lossFunction.newPass();
      accuracy.newPass();

      for (int step = 0; step < steps; step++) {
        Vector2 batchData = trainingData.subVector(
            step * batchSize!, (step + 1) * batchSize!) as Vector2;
        Vector1 batchLabels = trainingLabels.subVector(
            step * batchSize!, (step + 1) * batchSize!) as Vector1;
        ...
      }
      ...
    }
    ...
```

> [/lib/neural_network.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/neural_network.dart#L140)

Then, the rest of the training pass is as simple as calling the _forward function, calculating the loss and accuracy, running the backwards function, then running the optimizer.

```dart
    // run forward pass
    var predictions = _forward(batchData);

    var dataLoss = lossFunction.calculate(
        layers.last.output!,
        batchLabels,
    );

    // calculate accuracy
    var acc = accuracy.calculate(predictions, batchLabels);

    // backwards pass
    _backward(predictions, batchLabels);

    // optimize
    optimizer.pre();
    for (int i = 0; i < layers.length; i++) {
        optimizer.update(layers[i]);
    }
    optimizer.post();
```

> [/lib/neural_network.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/neural_network.dart#L161)

### Testing the Network

There are 2 scenarios we want to cover when testing the network. The first, is to test on an entire batch of data and get an average of the accuracy. The code for this is pretty similar to the training code.

```dart
  /// Test the model against a list of inputs. The shape
  /// must match that of your training data and the input
  /// layer of the model. You can optionally print data to
  /// the console every x steps with [printEveryStep].
  double test({
    required Vector2 testingData,
    required Vector1 testingLabels,
    int? printEveryStep,
  }) {
    print("# Beggining tesing of model:");
    batchSize ??= testingData.shape[0];

    // calculate step number
    int steps = (testingData.shape[0] / batchSize!).round();
    // include any stragling data
    if (steps * batchSize! < testingData.shape[0]) {
      steps += 1;
    }

    double totalAccuracy = 0;

    for (int step = 0; step < steps; step++) {
      Vector2 batchData = testingData.subVector(
          step * batchSize!, (step + 1) * batchSize!) as Vector2;
      Vector1 batchLabels = testingLabels.subVector(
          step * batchSize!, (step + 1) * batchSize!) as Vector1;

      // run through the model
      for (int i = 0; i < layers.length; i++) {
        if (i == 0) {
          layers[i].forward(batchData);
        } else {
          layers[i].forward(layers[i - 1].output!);
        }
      }

      // calulate loss
      var loss = lossFunction.calculate(layers.last.output!, batchLabels);
      var correct = 0;
      for (var i = 0; i < batchLabels.length; i++) {
        if (layers.last.output![i].maxIndex() == batchLabels[i]) {
          correct += 1;
        }
      }
      var accuracy = correct / batchLabels.length;
      totalAccuracy += accuracy;

      if (printEveryStep != null &&
          (step % printEveryStep == 0 || step == steps - 1)) {
        print(
            "validation, acc: ${accuracy.toStringAsPrecision(3)}, loss: ${loss.toStringAsPrecision(3)}");
      }
    }
    double totalAcc = totalAccuracy / steps;
    print("# [Total accuracy: ${(totalAcc * 100).toStringAsPrecision(4)}%]");
    return totalAcc;
  }
```

> [/lib/neural_network.dart](https://github.com/jake-landersweb/dart_nn/blob/cb6abb864259fdc54891fe750f8c756a2214f8ec/lib/neural_network.dart#L230)

The second scenario we want to cover is testing a single input. The network runs many inputs in parallel, so we just need to convert a list of pixels into a `Vector2` with length 1. 

```dart {7-8}
  /// Pass a single datapoint through the network to get a
  /// list of confidences cooresponding to what the network
  /// 'thinks' the inputted [data] is.
  List<double> getConfidenceSingle(List<double> data) {
    var prediction = _forward(Vector2.from([data]));
    List<double> preds = [];
    for (num i in prediction[0]) {
      preds.add(i.toDouble());
    }
    return preds;
  }
```

> [/lib/neural_network.dart](https://github.com/jake-landersweb/dart_nn/blob/cb6abb864259fdc54891fe750f8c756a2214f8ec/lib/neural_network.dart#L314)

## Mnist Dataset

This network was trained on the mnist dataset. Instead of using the raw file format from the original authors, I used a csv formatted version which you can find [here](https://www.kaggle.com/datasets/oddrationale/mnist-in-csv?resource=download).

### NNImage Class

The images are loaded into a special class created to hold the image data along with the size, label, and some extra classes to randomize the images.

```dart
/// Wrapper to hold image data along with a label
class NNImage {
  late List<double> image;
  late int label;
  late int size;
  ...

  /// Randomize the image position, angle, noise, and scale
  NNImage randomized() {
    ImageProcessor imageProcessor = ImageProcessor();
    return imageProcessor.transformImage(
      this,
      TransformationSettings.random(),
    );
  }
}
```

> [/lib/datasets/nnimage.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/datasets/nnimage.dart)

### Image Randomization

After running into some issues with over-fitting on the dataset, I became blocked and did not know what direction to go in. The video by Sebastian Lague really helped me get unblocked, as he faced a similar issue. The solution was to randomize the position, angle, size, and noise of the images. So, on the `NNImage` class there is a function to convert the vanilla image into a transformed image, which runs it though this code:

```dart
// heavily pulled from https://github.com/SebLague/Neural-Network-Experiments/blob/main/Assets/Scripts/Data+Handling/ImageProcessor.cs
class ImageProcessor {
  NNImage transformImage(NNImage original, TransformationSettings settings) {
    math.Random rng = math.Random();
    NNImage transformedImage = NNImage.from(original);
    if (settings.scale != 0) {
      Tuple2<double, double> iHat = Tuple2(
        v1: math.cos(settings.angle) / settings.scale,
        v2: math.sin(settings.angle) / settings.scale,
      );
      Tuple2<double, double> jHat = Tuple2(v1: -iHat.v2, v2: iHat.v1);
      for (int y = 0; y < transformedImage.size; y++) {
        for (int x = 0; x < transformedImage.size; x++) {
          double u = x / (transformedImage.size - 1);
          double v = y / (transformedImage.size - 1);

          double uTransformed = iHat.v1 * (u - 0.5) +
              jHat.v1 * (v - 0.5) +
              0.5 -
              settings.offset.v1;
          double vTransformed = iHat.v2 * (u - 0.5) +
              jHat.v2 * (v - 0.5) +
              0.5 -
              settings.offset.v2;
          double pixelValue = sample(original, uTransformed, vTransformed);
          double noiseValue = 0;
          if (rng.nextDouble() <= settings.noiseProbability) {
            noiseValue = (rng.nextDouble() - 0.5) * settings.noiseStrength;
          }
          transformedImage.image[getFlatIndex(transformedImage, x, y)] =
              math.min(math.max(pixelValue + noiseValue, 0), 1);
        }
      }
    }
    return transformedImage;
  }

  double sample(NNImage image, double u, double v) {
    u = math.max(math.min(1, u), 0);
    v = math.max(math.min(1, v), 0);

    double texX = u * (image.size - 1);
    double texY = v * (image.size - 1);

    int indexLeft = texX.toInt();
    int indexBottom = texY.toInt();
    int indexRight = math.min(indexLeft + 1, image.size - 1);
    int indexTop = math.min(indexBottom + 1, image.size - 1);

    double blendX = texX - indexLeft;
    double blendY = texY - indexBottom;

    double bottomLeft =
        image.image[getFlatIndex(image, indexLeft, indexBottom)];
    double bottomRight =
        image.image[getFlatIndex(image, indexRight, indexBottom)];
    double topLeft = image.image[getFlatIndex(image, indexLeft, indexTop)];
    double topRight = image.image[getFlatIndex(image, indexRight, indexTop)];

    double valueBottom = bottomLeft + (bottomRight - bottomLeft) * blendX;
    double valueTop = topLeft + (topRight - topLeft) * blendX;
    double interpolatedValue = valueBottom + (valueTop - valueBottom) * blendY;
    return interpolatedValue;
  }

  int getFlatIndex(NNImage image, int x, int y) {
    return y * image.size + x;
  }
}

class TransformationSettings {
  late double angle;
  late double scale;
  late Tuple2<double, double> offset;
  late int noiseSeed;
  late double noiseProbability;
  late double noiseStrength;

  TransformationSettings({
    required this.angle,
    required this.scale,
    required this.offset,
    required this.noiseSeed,
    required this.noiseProbability,
    required this.noiseStrength,
  });
  ...
}
```

> [/lib/datasets/image_processor.dart](https://github.com/jake-landersweb/dart_nn/blob/main/lib/datasets/image_processor.dart)

### Training and Testing Images

The training of the network included the original 60000 images along with all 60000 images randomized, for a total of 120000 images. The testing dataset was composed of 10000 images along with all 10000 images randomized, for a total of 20000 images.

Lastly, I hand generated 1000 images of digits in the format the test program creates them in, to give the network a little diversity in the image pixel values. So, 900 of these images were added for training and 100 were added for testing.

### Model Performance

The accuracy of the model on the testing data was 93%. This still shows a bit of over-fitting, but the performance tends to be relatively good on images drawn on the website example.

There are some issues when it comes to drawing digits outside of the center of the grid, which could be fixed in a variety of ways. One, is to add some more variety to the training data. The second, is to take the pixel input from the user and run a function to center their input, though I am not sure how effective this would be.

## Concluding Thoughts

This was an extremely fun and rewarding project to work on. I hope the information I put here helps someone in the future on the same journey. If there happens to be some part of my implementation that helps you, please let me know! I would love to hear what other similar projects people have done along with suggestions for how to improve my own implementation!