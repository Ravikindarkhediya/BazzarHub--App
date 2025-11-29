import Foundation
import os.lock

/// Swift 5 compatible version of Firebase's `FIRAllocatedUnfairLock`.
public final class FIRAllocatedUnfairLock<State>: @unchecked Sendable {
  private var lockPointer: UnsafeMutablePointer<os_unfair_lock>
  private var state: State

  public init(initialState: State) {
    lockPointer = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
    lockPointer.initialize(to: os_unfair_lock())
    state = initialState
  }

  public convenience init() where State == Void {
    self.init(initialState: ())
  }

  deinit {
    lockPointer.deallocate()
  }

  public func lock() {
    os_unfair_lock_lock(lockPointer)
  }

  public func unlock() {
    os_unfair_lock_unlock(lockPointer)
  }

  public func value() -> State {
    lock()
    defer { unlock() }
    return state
  }

  @discardableResult
  public func withLock<R>(_ body: (inout State) throws -> R) rethrows -> R {
    lock()
    defer { unlock() }
    return try body(&state)
  }

  @discardableResult
  public func withLock<R>(_ body: () throws -> R) rethrows -> R {
    lock()
    defer { unlock() }
    return try body()
  }
}






