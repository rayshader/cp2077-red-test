# Red Test
![Cyberpunk 2077](https://img.shields.io/badge/Cyberpunk%202077-v2.12-blue)
![GitHub License](https://img.shields.io/github/license/rayshader/cp2077-red-test)
[![Donate](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-yellow)](https://www.buymeacoffee.com/lpfreelance)

Tiny Redscript framework to run unit tests with helper functions.

# Getting started

1. Install requirements:
  - [Codeware] v1.8.0+ (in `scripts/Codeware` for autocompletion)

2. Clone repository in your scripts directory:

```shell
git submodule add https://github.com/rayshader/cp2077-red-test.git scripts/RedTest/
```

3. Create a Test directory:

```shell
mkdir -p scripts/Test/
```

4. Add a test:

> File: scripts/Test/MathTest.reds

- Rename `MathTest` to your convenience.
- Change `<ModName>` with the name of your mod.

```swift
public static func Add(a: Int32, b: Int32) -> Int32 {
  return a + b;
}

public class MathTest extends BaseTest {

  public func Create() {
    this.m_modName = "<ModName>";
    this.m_name = "Math";
  }

  public func Setup() {
    // e.g. get references before running tests.
  }

  private cb func Test_Add() {
    let actual = Add(5, 5);
    let expect = 10;

    this.ExpectInt32("5 + 5 == 10", actual, expect);
  }

  /*
                  | Start with prefix "Test_" to
                  | automatically discover your test.
                  v
  private cb func Test_() {
          ^
          | Callback is required!
  }
  */
}
```

5. Create entry-point and register your test:

> File: scripts/Test/Main.reds

```swift
public class MainTest extends ScriptableSystem {
  private let m_runner: ref<RedTest>;

  /// Lifecycle ///

  private func OnAttach() {
    this.m_runner = new RedTest();
    this.m_runner.Setup("MathTest", [
      new MathTest()
    ]);
  }

  private func OnDetach() {
    this.m_runner.TearDown();
  }
}
```

6. Install scripts in game directory.
7. Run the game.
8. Open CET and show Game Log popup.
9. You should see tests result.

> DON'T include tests in the release of your mod!

# Functions

> ExpectBool(name: String, actual: Bool, expect: Bool) -> Bool  
> ExpectInt32(name: String, actual: Int32, expect: Int32)  
> ExpectUint32(name: String, actual: Uint32, expect: Uint32)  
> ExpectInt64(name: String, actual: Int64, expect: Int64)  
> ExpectUint64(name: String, actual: Uint64, expect: Uint64)  
> ExpectFloat(name: String, actual: Float, expect: Float)  
> ExpectDouble(name: String, actual: Double, expect: Double)  
> ExpectString(name: String, actual: String, expect: String) -> Bool  
> ExpectUnicodeString(name: String, actual: String, expect: String) -> Bool

You can use `ExpectString` to test for enums like this:

```swift
enum Animal {
  Dog = 0,
  Bird = 1
}

let actual = Animal.Bird;

ExpectString("Is a bird", s"\(actual)", "Bird");
```

# Asynchronous

You can write asynchronous tests (e.g when using callbacks). You need to tell 
the framework test class is asynchronous:

```swift
import Codeware.*

// Custom callback, implementation is not defined for brevity.
public class CustomCallback {
  // ...
  public static func Create(target: ref<IScriptable>, fn: CName, opt args: array<Variant>) -> ref<CustomCallback> {
    // ...
  }

  public func Call() {
    // ...
  }
}

// Suppose this function will run in background and execute our callback
// when its job is finished.
public static func CallAsyncFunction(callback: ref<CustomCallback>) -> Void;

public class SpawnTest extends BaseTest {

  public func Create() {
    // ...
    this.m_isAsync = true; // REQUIRED
  }

  /*
                             | callback to execute when test is finished.
                             v
  */
  private cb func Test_Spawn(done: ref<CallbackTest>) {
    let callback = CustomCallback.Create(this, n"Async_Spawn", [done]);

    // Start a fake background job.
    CallAsyncFunction(callback);
  }

  // Called when background job is finished.
  private cb func Async_Spawn(done: ref<CallbackTest>) {
    this.ExpectBool("Assert", true, true);

    // Tell framework this unit test is finished.
    done.Call();
  }

  // Synchronous test can also be declared in an asynchronous context.
  private cb func Test_Sync(done: ref<CallbackTest>) {
    // Do synchronous stuff here.
    this.ExpectBool("Assert", true, true);

    // You still need to tell the framework this unit test is finished.
    done.Call();
  }
}
``` 

<!-- Table of links -->
[Codeware]: https://github.com/psiberx/cp2077-codeware