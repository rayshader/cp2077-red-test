import Codeware.*

public struct ResultTest {
  let failCount: Int32;
  let passCount: Int32;
  let totalCount: Int32;
}

public class CallbackTest {
  private let m_target: ref<BaseTest>;
  private let m_fn: CName;
  private let m_arguments: array<Variant>;

  public static func Create(target: ref<BaseTest>, fn: CName, opt arguments: array<Variant>) -> ref<CallbackTest> {
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
}

public abstract class BaseTest {

  private let m_tests: array<ref<CallbackTest>>;
  private let m_result: ResultTest;

  protected let m_modName: String;
  protected let m_name: String;

  public func Init();

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

  public func Run() -> ResultTest {
    LogChannel(n"Info", s"");
    LogChannel(n"Info", s"== \(this.m_modName) - Test - \(this.m_name) ==");
    this.m_result.failCount = 0;
    this.m_result.passCount = 0;
    this.m_result.totalCount = 0;
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

  protected func AddTest(fn: CName, opt args: array<Variant>) {
    ArrayPush(this.m_tests, CallbackTest.Create(this, fn, args));
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
