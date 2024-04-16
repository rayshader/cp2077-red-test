import Codeware.*

public class RedTest {
  private let m_callbackSystem: wref<CallbackSystem>;

  private let m_isLoaded: Bool;
  private let m_modName: String;

  private let m_results: ResultTest;
  private let m_tests: array<ref<BaseTest>>;
  private let m_asyncTests: array<ref<BaseTest>>;
  
  /// Lifecycle ///

  public func Setup(modName: String, tests: array<ref<BaseTest>>) {
    this.m_isLoaded = false;
    this.m_modName = modName;
    this.m_tests = [];
    this.m_asyncTests = [];
    for test in tests {
      test.Create();
      test.Discover();
      if !test.IsAsync() {
        ArrayPush(this.m_tests, test);
      } else {
        ArrayPush(this.m_asyncTests, test);
      }
    }
    this.m_callbackSystem = GameInstance.GetCallbackSystem();
    this.m_callbackSystem.RegisterCallback(n"Session/Ready", this, n"OnSessionReady");
  }

  public func TearDown() {
    this.m_isLoaded = false;
    this.m_callbackSystem.UnregisterCallback(n"Session/Ready", this, n"OnSessionReady");
    this.m_callbackSystem = null;
    LogChannel(n"Info", "");
    LogChannel(n"Info", s"Tests: \(this.m_results.failCount) failed, \(this.m_results.passCount) passed, \(this.m_results.totalCount) total");
    LogChannel(n"Info", "");
    LogChannel(n"Info", s"== \(this.m_modName) - All Tests ==");
  }

  /// Game events ///

  private cb func OnSessionReady(event: ref<GameSessionEvent>) {
    let isPreGame = event.IsPreGame();

    if !isPreGame || this.m_isLoaded {
      return;
    }
    LogChannel(n"Info", s"== \(this.m_modName) - All Tests ==");
    this.m_results = new ResultTest(0, 0, 0);
    this.Run();
    let isFinished = this.AsyncRun();

    if isFinished {
      this.TearDown();
    }
  }

  private func Run() {
    for test in this.m_tests {
      test.Setup();
      let result = test.Run();

      this.m_results.failCount += result.failCount;
      this.m_results.passCount += result.passCount;
      this.m_results.totalCount += result.totalCount;
    }
  }

  private func AsyncRun() -> Bool {
    if ArraySize(this.m_asyncTests) == 0 {
      return true;
    }
    let next = CallbackTest.Create(this, n"AsyncRunNext", [0]);
    let asyncTest = this.m_asyncTests[0];

    asyncTest.Setup();
    asyncTest.AsyncRun(next);
    return false;
  }

  private cb func AsyncRunNext(index: Int32) {
    let result = this.m_asyncTests[index].GetResult();

    this.m_results.failCount += result.failCount;
    this.m_results.passCount += result.passCount;
    this.m_results.totalCount += result.totalCount;
    index += 1;
    if index >= ArraySize(this.m_asyncTests) {
      this.TearDown();
      return;
    }
    let next = CallbackTest.Create(this, n"AsyncRunNext", [index]);
    let asyncTest = this.m_asyncTests[index];

    asyncTest.Setup();
    asyncTest.AsyncRun(next);
  }

}