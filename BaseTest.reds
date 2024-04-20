import Codeware.*

public struct ResultTest {
  let failCount: Int32;
  let passCount: Int32;
  let totalCount: Int32;
}

public class CallbackTest {
  private let m_target: wref<IScriptable>;
  private let m_fn: CName;
  private let m_arguments: array<Variant>;

  public static func Create(target: wref<IScriptable>, fn: CName, opt arguments: array<Variant>) -> ref<CallbackTest> {
    let self = new CallbackTest();

    self.m_target = target;
    self.m_fn = fn;
    self.m_arguments = arguments;
    return self;
  }

  public func Call() {
    let type = Reflection.GetClassOf(this.m_target);
    let function = type.GetFunction(this.m_fn);

    function.Call(this.m_target, this.m_arguments);
  }

  public func AsyncCall(next: ref<CallbackTest>) {
    let type = Reflection.GetClassOf(this.m_target);
    let function = type.GetFunction(this.m_fn);

    function.Call(this.m_target, [next]);
  }
}

public abstract class BaseTest {

  private let m_tests: array<ref<CallbackTest>>;
  private let m_result: ResultTest;

  protected let m_modName: String;
  protected let m_name: String;
  protected let m_isAsync: Bool = false;

  public func IsAsync() -> Bool {
    return this.m_isAsync;
  }

  public func GetResult() -> ResultTest {
    return this.m_result;
  }

  public abstract func Create();

  public func Discover() {
    let cls = Reflection.GetClass(this.GetClassName());
    let functions = cls.GetFunctions();

    for fn in functions {
      let name = fn.GetName();

      if StrBeginsWith(s"\(name)", "Test_") {
        this.AddTest(name);
      }
    }
  }

  public abstract func Setup();

  public func Run() -> ResultTest {
    LogChannel(n"Info", s"");
    LogChannel(n"Info", s"== \(this.m_modName) - Test - \(this.m_name) ==");
    this.m_result = new ResultTest(0, 0, 0);
    let size = ArraySize(this.m_tests);
    let i = 0;

    while i < size {
      this.m_tests[i].Call();
      i += 1;
      if i < size {
        LogChannel(n"Info", "");
      }
    }
    return this.m_result;
  }

  public func AsyncRun(done: ref<CallbackTest>) -> Void {
    LogChannel(n"Info", s"");
    LogChannel(n"Info", s"== \(this.m_modName) - Test - \(this.m_name) ==");
    if ArraySize(this.m_tests) == 0 {
      LogChannel(n"Info", s"");
      LogChannel(n"Info", s" No unit tests");
      LogChannel(n"Info", "");
      done.Call();
      return;
    }
    this.m_result = new ResultTest(0, 0, 0);
    let next = CallbackTest.Create(this, n"AsyncRunNext", [0, done]);
    let test = this.m_tests[0];

    test.AsyncCall(next);
    LogChannel(n"Info", "");
  }

  private cb func AsyncRunNext(index: Int32, done: ref<CallbackTest>) {
    index += 1;
    if index >= ArraySize(this.m_tests) {
      done.Call();
      return;
    }
    let next = CallbackTest.Create(this, n"AsyncRunNext", [index, done]);
    let test = this.m_tests[index];

    test.AsyncCall(next);
    LogChannel(n"Info", "");
  }

  protected func AddTest(fn: CName) {
    ArrayPush(this.m_tests, CallbackTest.Create(this, fn));
  }

  protected func ExpectBool(from: String, actual: Bool, expected: Bool) -> Bool {
    if !Equals(actual, expected) {
      this.LogFail(from, s"\(actual)", s"\(expected)");
      return false;
    } else {
      this.LogPass(from);
      return true;
    }
  }

  protected func ExpectInt32(from: String, actual: Int32, expected: Int32) {
    if !Equals(actual, expected) {
      this.LogFail(from, s"\(actual)", s"\(expected)");
    } else {
      this.LogPass(from);
    }
  }

  protected func ExpectUint32(from: String, actual: Uint32, expected: Uint32) {
    if !Equals(actual, expected) {
      this.LogFail(from, s"\(actual)", s"\(expected)");
    } else {
      this.LogPass(from);
    }
  }

  protected func ExpectInt64(from: String, actual: Int64, expected: Int64) {
    if !Equals(actual, expected) {
      this.LogFail(from, s"\(actual)", s"\(expected)");
    } else {
      this.LogPass(from);
    }
  }

  protected func ExpectUint64(from: String, actual: Uint64, expected: Uint64) {
    if !Equals(actual, expected) {
      this.LogFail(from, s"\(actual)", s"\(expected)");
    } else {
      this.LogPass(from);
    }
  }

  protected func ExpectFloat(from: String, actual: Float, expected: Float) {
    if !FloatIsEqual(actual, expected) {
      this.LogFail(from, s"\(actual)", s"\(expected)");
    } else {
      this.LogPass(from);
    }
  }

  protected func ExpectDouble(from: String, actual: Double, expected: Double) {
    // Use formatted string to compare, raw type comparison is not precise.
    if !Equals(s"\(actual)", s"\(expected)") {
      this.LogFail(from, s"\(actual)", s"\(expected)");
    } else {
      this.LogPass(from);
    }
  }

  protected func ExpectString(from: String, actual: String, expected: String) -> Bool {
    if !Equals(actual, expected) {
      this.LogFail(from, s"'\(actual)'", s"'\(expected)'");
      return false;
    } else {
      this.LogPass(from);
      return true;
    }
  }

  protected func ExpectUnicodeString(from: String, actual: String, expected: String) {
    if !UnicodeStringEqual(actual, expected) {
      this.LogFail(from, s"'\(actual)'", s"'\(expected)'");
    } else {
      this.LogPass(from);
    }
  }

  protected func LogFail(from: String, actual: String, expected: String) {
    LogChannel(n"Error", s"FAIL: \(from)");
    LogChannel(n"Error", s"  Actual: \(actual)");
    LogChannel(n"Error", s"  Expected: \(expected)");
    this.m_result.failCount += 1;
    this.m_result.totalCount += 1;
  }

  protected func LogPass(from: String) {
    LogChannel(n"Info", s"PASS: \(from)");
    this.m_result.passCount += 1;
    this.m_result.totalCount += 1;
  }

}
