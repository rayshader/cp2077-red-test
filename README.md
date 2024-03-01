# Red Test

Tiny Redscript framework to run unit tests with helper functions.

# Getting started

1. Install requirements:
  - [Codeware] v1.8.0+ (in `scripts/Codeware` for autocompletion)

2. Clone repository in your scripts directory:

```shell
git clone https://github.com/rayshader/cp2077-red-test.git .
```

3. Create a Test directory:

```shell
mkdir -p scripts/Test/
```

4. Add a test:

> File: scripts/Test/MathTest.reds

- Rename MathTest to your convenience.
- Change &lt;ModName&gt; with the name of your mod.

```swift
public class MathTest extends BaseTest {

  public func Init() {
    this.m_modName = "<ModName>";
    this.m_name = "Math";

    this.AddTest(n"Test_Add");
  }

  private cb func Test_Add() {
    let actual = 5 + 5;
    let expect = 10;

    this.ExpectInt32("5 + 5 == 10", actual, expect);
  }
}
```

5. Register your test:

> File: scripts/RedTest/MainTest.reds

```swift
class MainTest extends ScriptableSystem {
  // ...

  private func OnAttach() {
    // ...
    this.m_modName = "<ModName>";
    this.m_tests = [
      new MathTest()
    ];
    // ...
  }

  // ...
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
> ExpectDouble(name: String, actual: Double, expect: Double)  
> ExpectString(name: String, actual: String, expect: String) -> Bool

You can use `ExpectString` to test for enums like this:

```swift
enum Animal {
  Dog = 0,
  Bird = 1
}

let actual = Animal.Bird;

ExpectString("Is a bird", s"\(actual)", "Bird");
```

<!-- Table of links -->
[Codeware]: https://github.com/psiberx/cp2077-codeware