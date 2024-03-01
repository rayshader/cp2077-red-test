import Codeware.*

class MainTest extends ScriptableSystem {
  private let m_callbackSystem: wref<CallbackSystem>;

  private let m_isLoaded: Bool;
  private let m_modName: String;
  private let m_tests: array<ref<BaseTest>>;
  
  /// Lifecycle ///

  private func OnAttach() {
    this.m_isLoaded = false;
    this.m_modName = "<ModName>";
    this.m_tests = [
      // new BasicTest()
    ];
    this.m_callbackSystem = GameInstance.GetCallbackSystem();
    this.m_callbackSystem.RegisterCallback(n"Session/Ready", this, n"OnSessionReady");
  }

  private func OnDetach() {
    this.m_isLoaded = false;
    this.m_callbackSystem.UnregisterCallback(n"Session/Ready", this, n"OnSessionReady");
    this.m_callbackSystem = null;
  }

  /// Game events ///

  private cb func OnSessionReady(event: ref<GameSessionEvent>) {
    let isPreGame = event.IsPreGame();

    if !isPreGame || this.m_isLoaded {
      return;
    }
    LogChannel(n"Info", s"== \(this.m_modName) - All Tests ==");
    let all_result = new ResultTest(0, 0, 0);
    let result: ResultTest;

    for test in this.m_tests {
      test.Init();
      result = test.Run();
      all_result.failCount += result.failCount;
      all_result.passCount += result.passCount;
      all_result.totalCount += result.totalCount;
    }
    LogChannel(n"Info", "");
    LogChannel(n"Info", s"Tests: \(all_result.failCount) failed, \(all_result.passCount) passed, \(all_result.totalCount) total");
    LogChannel(n"Info", "");
    LogChannel(n"Info", s"== \(this.m_modName) - All Tests ==");
  }
}