//
//  CommandLineKit.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

/*
 * CommandLine.swift
 * Copyright (c) 2014 Ben Gollmer.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

import Foundation

let shortOptionPrefix = "-"
let longOptionPrefix = "--"

/* Stop parsing arguments when an ArgumentStopper (--) is detected. This is a GNU getopt
 * convention; cf. https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html
 */
let argumentStopper = "--"

/* Allow arguments to be attached to flags when separated by this character.
 * --flag=argument is equivalent to --flag argument
 */
let argumentAttacher: Character = "="

/* An output stream to stderr; used by CommandLine.printUsage(). */
private struct StderrOutputStream: TextOutputStream {
  static let stream = StderrOutputStream()
  func write(_ s: String) {
    fputs(s, stderr)
  }
}

/**
 * The CommandLine class implements a command-line interface for your app.
 *
 * To use it, define one or more Options (see Option.swift) and add them to your
 * CommandLine object, then invoke `parse()`. Each Option object will be populated with
 * the value given by the user.
 *
 * If any required options are missing or if an invalid value is found, `parse()` will throw
 * a `ParseError`. You can then call `printUsage()` to output an automatically-generated usage
 * message.
 */
public class CommandLineKit {
  private var _arguments: [String]
  private var _options: [Option] = [Option]()
  private var _maxFlagDescriptionWidth: Int = 0
  private var _usedFlags: Set<String> {
    var usedFlags = Set<String>(minimumCapacity: _options.count * 2)

    for option in _options {
      for case let flag? in [option.shortFlag, option.longFlag] {
        usedFlags.insert(flag)
      }
    }

    return usedFlags
  }

  /**
   * After calling `parse()`, this property will contain any values that weren't captured
   * by an Option. For example:
   *
   * ```
   * let cli = CommandLine()
   * let fileType = StringOption(shortFlag: "t", longFlag: "type", required: true, helpMessage: "Type of file")
   *
   * do {
   *   try cli.parse()
   *   print("File type is \(type), files are \(cli.unparsedArguments)")
   * catch {
   *   cli.printUsage(error)
   *   exit(EX_USAGE)
   * }
   *
   * ---
   *
   * $ ./readfiles --type=pdf ~/file1.pdf ~/file2.pdf
   * File type is pdf, files are ["~/file1.pdf", "~/file2.pdf"]
   * ```
   */
  public private(set) var unparsedArguments: [String] = [String]()

  /**
   * If supplied, this function will be called when printing usage messages.
   *
   * You can use the `defaultFormat` function to get the normally-formatted
   * output, either before or after modifying the provided string. For example:
   *
   * ```
   * let cli = CommandLine()
   * cli.formatOutput = { str, type in
   *   switch(type) {
   *   case .Error:
   *     // Make errors shouty
   *     return defaultFormat(str.uppercaseString, type: type)
   *   case .OptionHelp:
   *     // Don't use the default indenting
   *     return ">> \(s)\n"
   *   default:
   *     return defaultFormat(str, type: type)
   *   }
   * }
   * ```
   *
   * - note: Newlines are not appended to the result of this function. If you don't use
   * `defaultFormat()`, be sure to add them before returning.
   */
  public var formatOutput: ((String, OutputType) -> String)?

  /**
   * The maximum width of all options' `flagDescription` properties; provided for use by
   * output formatters.
   *
   * - seealso: `defaultFormat`, `formatOutput`
   */
  public var maxFlagDescriptionWidth: Int {
    if _maxFlagDescriptionWidth == 0 {
      _maxFlagDescriptionWidth = _options.map { $0.flagDescription.count }.sorted().first ?? 0
    }

    return _maxFlagDescriptionWidth
  }

  /**
   * The type of output being supplied to an output formatter.
   *
   * - seealso: `formatOutput`
   */
  public enum OutputType {
    /** About text: `Usage: command-example [options]` and the like */
    case about

    /** An error message: `Missing required option --extract`  */
    case error

    /** An Option's `flagDescription`: `-h, --help:` */
    case optionFlag

    /** An Option's help message */
    case optionHelp
  }

  /** A ParseError is thrown if the `parse()` method fails. */
  public enum ParseError: Error, CustomStringConvertible {
    /** Thrown if an unrecognized argument is passed to `parse()` in strict mode */
    case invalidArgument(String)

    /** Thrown if the value for an Option is invalid (e.g. a string is passed to an IntOption) */
    case invalidValueForOption(Option, [String])

    /** Thrown if an Option with required: true is missing */
    case missingRequiredOptions([Option])

    public var description: String {
      switch self {
      case let .invalidArgument(arg):
        return "Invalid argument: \(arg)"
      case let .invalidValueForOption(opt, vals):
        let vs = vals.joined(separator: ", ")
        return "Invalid value(s) for option \(opt.flagDescription): \(vs)"
      case let .missingRequiredOptions(opts):
        return "Missing required options: \(opts.map { return $0.flagDescription })"
      }
    }
  }

  /**
   * Initializes a CommandLine object.
   *
   * - parameter arguments: Arguments to parse. If omitted, the arguments passed to the app
   *   on the command line will automatically be used.
   *
   * - returns: An initalized CommandLine object.
   */
  public init(arguments: [String] = Swift.CommandLine.arguments) {
    self._arguments = arguments

    /* Initialize locale settings from the environment */
    setlocale(LC_ALL, "")
  }

  /* Returns all argument values from flagIndex to the next flag or the end of the argument array. */
  private func _getFlagValues(_ flagIndex: Int, _ attachedArg: String? = nil) -> [String] {
    var args: [String] = [String]()
    var skipFlagChecks = false

    if let a = attachedArg {
      args.append(a)
    }

    for i in flagIndex + 1 ..< _arguments.count {
      if !skipFlagChecks {
        if _arguments[i] == argumentStopper {
          skipFlagChecks = true
          continue
        }

        if _arguments[i].hasPrefix(shortOptionPrefix) && Int(_arguments[i]) == nil &&
          _arguments[i].toDouble() == nil {
          break
        }
      }

      args.append(_arguments[i])
    }

    return args
  }

  /**
   * Adds an Option to the command line.
   *
   * - parameter option: The option to add.
   */
  public func addOption(_ option: Option) {
    let uf = _usedFlags
    for case let flag? in [option.shortFlag, option.longFlag] {
      assert(!uf.contains(flag), "Flag '\(flag)' already in use")
    }

    _options.append(option)
    _maxFlagDescriptionWidth = 0
  }

  /**
   * Adds one or more Options to the command line.
   *
   * - parameter options: An array containing the options to add.
   */
  public func addOptions(_ options: [Option]) {
    for o in options {
      addOption(o)
    }
  }

  /**
   * Adds one or more Options to the command line.
   *
   * - parameter options: The options to add.
   */
  public func addOptions(_ options: Option...) {
    for o in options {
      addOption(o)
    }
  }

  /**
   * Sets the command line Options. Any existing options will be overwritten.
   *
   * - parameter options: An array containing the options to set.
   */
  public func setOptions(_ options: [Option]) {
    _options = [Option]()
    addOptions(options)
  }

  /**
   * Sets the command line Options. Any existing options will be overwritten.
   *
   * - parameter options: The options to set.
   */
  public func setOptions(_ options: Option...) {
    _options = [Option]()
    addOptions(options)
  }

  /**
   * Parses command-line arguments into their matching Option values.
   *
   * - parameter strict: Fail if any unrecognized flags are present (default: false).
   *
   * - throws: A `ParseError` if argument parsing fails:
   *   - `.InvalidArgument` if an unrecognized flag is present and `strict` is true
   *   - `.InvalidValueForOption` if the value supplied to an option is not valid (for
   *     example, a string is supplied for an IntOption)
   *   - `.MissingRequiredOptions` if a required option isn't present
   */
  public func parse(strict: Bool = false) throws {
    var strays = _arguments

    /* Nuke executable name */
    strays[0] = ""

    let argumentsEnumerator = _arguments.enumerated()
    for (idx, arg) in argumentsEnumerator {
      if arg == argumentStopper {
        break
      }

      if !arg.hasPrefix(shortOptionPrefix) {
        continue
      }

      let skipChars = arg.hasPrefix(longOptionPrefix) ?
        longOptionPrefix.count : shortOptionPrefix.count
      let flagWithArg = arg[arg.index(arg.startIndex, offsetBy: skipChars)..<arg.endIndex]

      /* The argument contained nothing but ShortOptionPrefix or LongOptionPrefix */
      if flagWithArg.isEmpty {
        continue
      }

      /* Remove attached argument from flag */
      let splitFlag = flagWithArg.split(separator: argumentAttacher, maxSplits: 1)
      let flag = String(splitFlag[0])
      let attachedArg: String? = splitFlag.count == 2 ? String(splitFlag[1]) : nil

      var flagMatched = false
      for option in _options where option.flagMatch(flag) {
        let vals = self._getFlagValues(idx, attachedArg)
        guard option.setValue(vals) else {
          throw ParseError.invalidValueForOption(option, vals)
        }

        var claimedIdx = idx + option.claimedValues
        if attachedArg != nil { claimedIdx -= 1 }
        for i in idx...claimedIdx {
          strays[i] = ""
        }

        flagMatched = true
        break
      }

      /* Flags that do not take any arguments can be concatenated */
      let flagLength = flag.count
      if !flagMatched && !arg.hasPrefix(longOptionPrefix) {
        let flagCharactersEnumerator = flag.enumerated()
        for (i, c) in flagCharactersEnumerator {
          for option in _options where option.flagMatch(String(c)) {
            /* Values are allowed at the end of the concatenated flags, e.g.
            * -xvf <file1> <file2>
            */
            let vals = (i == flagLength - 1) ? self._getFlagValues(idx, attachedArg) : [String]()
            guard option.setValue(vals) else {
              throw ParseError.invalidValueForOption(option, vals)
            }

            var claimedIdx = idx + option.claimedValues
            if attachedArg != nil { claimedIdx -= 1 }
            for i in idx...claimedIdx {
              strays[i] = ""
            }

            flagMatched = true
            break
          }
        }
      }

      /* Invalid flag */
      guard !strict || flagMatched else {
        throw ParseError.invalidArgument(arg)
      }
    }

    /* Check to see if any required options were not matched */
    let missingOptions = _options.filter { $0.required && !$0.wasSet }
    guard missingOptions.count == 0 else {
      throw ParseError.missingRequiredOptions(missingOptions)
    }

    unparsedArguments = strays.filter { $0 != "" }
  }

  /**
   * Provides the default formatting of `printUsage()` output.
   *
   * - parameter s:     The string to format.
   * - parameter type:  Type of output.
   *
   * - returns: The formatted string.
   * - seealso: `formatOutput`
   */
  public func defaultFormat(s: String, type: OutputType) -> String {
    switch type {
    case .about:
      return "\(s)\n"
    case .error:
      return "\(s)\n\n"
    case .optionFlag:
      return "  \(s.padded(toWidth: maxFlagDescriptionWidth)):\n"
    case .optionHelp:
      return "      \(s)\n"
    }
  }

  /* printUsage() is generic for OutputStreamType because the Swift compiler crashes
   * on inout protocol function parameters in Xcode 7 beta 1 (rdar://21372694).
   */

  /**
   * Prints a usage message.
   *
   * - parameter to: An OutputStreamType to write the error message to.
   */
  public func printUsage<TargetStream: TextOutputStream>(_ to: inout TargetStream) {
    /* Nil coalescing operator (??) doesn't work on closures :( */
    let format = formatOutput != nil ? formatOutput! : defaultFormat

    let name = _arguments[0]
    print(format("Usage: \(name) [options]", .about), terminator: "", to: &to)

    for opt in _options {
      print(format(opt.flagDescription, .optionFlag), terminator: "", to: &to)
      print(format(opt.helpMessage, .optionHelp), terminator: "", to: &to)
    }
  }

  /**
   * Prints a usage message.
   *
   * - parameter error: An error thrown from `parse()`. A description of the error
   *   (e.g. "Missing required option --extract") will be printed before the usage message.
   * - parameter to: An OutputStreamType to write the error message to.
   */
  public func printUsage<TargetStream: TextOutputStream>(_ error: Error, to: inout TargetStream) {
    let format = formatOutput != nil ? formatOutput! : defaultFormat
    print(format("\(error)", .error), terminator: "", to: &to)
    printUsage(&to)
  }

  /**
   * Prints a usage message.
   *
   * - parameter error: An error thrown from `parse()`. A description of the error
   *   (e.g. "Missing required option --extract") will be printed before the usage message.
   */
  public func printUsage(_ error: Error) {
    var out = StderrOutputStream.stream
    printUsage(error, to: &out)
  }

  /**
   * Prints a usage message.
   */
  public func printUsage() {
    var out = StderrOutputStream.stream
    printUsage(&out)
  }
}
