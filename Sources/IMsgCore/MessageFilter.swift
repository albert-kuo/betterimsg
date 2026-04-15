import Foundation

public struct MessageFilter: Sendable, Equatable {
  public let participants: [String]
  public let startDate: Date?
  public let endDate: Date?
  public let excludeFromMe: Bool

  public init(
    participants: [String] = [],
    startDate: Date? = nil,
    endDate: Date? = nil,
    excludeFromMe: Bool = false
  ) {
    self.participants = participants
    self.startDate = startDate
    self.endDate = endDate
    self.excludeFromMe = excludeFromMe
  }

  public static func fromISO(
    participants: [String],
    startISO: String?,
    endISO: String?,
    excludeFromMe: Bool = false
  ) throws -> MessageFilter {
    let start = startISO.flatMap { ISO8601Parser.parse($0) }
    if let startISO, start == nil {
      throw IMsgError.invalidISODate(startISO)
    }
    let end = endISO.flatMap { ISO8601Parser.parse($0) }
    if let endISO, end == nil {
      throw IMsgError.invalidISODate(endISO)
    }
    return MessageFilter(
      participants: participants,
      startDate: start,
      endDate: end,
      excludeFromMe: excludeFromMe
    )
  }

  public func allows(_ message: Message) -> Bool {
    if excludeFromMe && message.isFromMe { return false }
    if let startDate, message.date < startDate { return false }
    if let endDate, message.date >= endDate { return false }
    if !participants.isEmpty {
      var match = false
      for participant in participants {
        if participant.caseInsensitiveCompare(message.sender) == .orderedSame {
          match = true
          break
        }
      }
      if !match { return false }
    }
    return true
  }
}
