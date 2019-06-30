//
//  Regex.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Foundation

public struct Regex {
    
    private let regularExpression: NSRegularExpression
    
    //使用正则表达式进行初始化
    public init(_ pattern: String, options: Options = []) throws {
        regularExpression = try NSRegularExpression(
            pattern: pattern,
            options: options.toNSRegularExpressionOptions
        )
    }
    
    //正则匹配验证（true表示匹配成功）
    public func matches(_ string: String) -> Bool {
        return firstMatch(in: string) != nil
    }
    
    //获取第一个匹配结果
    public func firstMatch(in string: String) -> Match? {
        let firstMatch = regularExpression
            .firstMatch(in: string, options: [],
                        range: NSRange(location: 0, length: string.utf16.count))
            .map { Match(result: $0, in: string) }
        return firstMatch
    }
    
    //获取所有的匹配结果
    public func matches(in string: String) -> [Match] {
        let matches = regularExpression
            .matches(in: string, options: [],
                     range: NSRange(location: 0, length: string.utf16.count))
            .map { Match(result: $0, in: string) }
        return matches
    }
    
    //正则替换
    public func replacingMatches(in input: String, with template: String,
                                 count: Int? = nil) -> String {
        var output = input
        let matches = self.matches(in: input)
        let rangedMatches = Array(matches[0..<min(matches.count, count ?? .max)])
        for match in rangedMatches.reversed() {
            let replacement = match.string(applyingTemplate: template)
            output.replaceSubrange(match.range, with: replacement)
        }
        
        return output
    }
}

//正则匹配可选项
extension Regex {
    /// Options 定义了正则表达式匹配时的行为
    public struct Options: OptionSet {
        
        //忽略字母
        public static let ignoreCase = Options(rawValue: 1)
        
        //忽略元字符
        public static let ignoreMetacharacters = Options(rawValue: 1 << 1)
        
        //默认情况下,“^”匹配字符串的开始和结束的“$”匹配字符串,无视任何换行。
        //使用这个配置，“^”将匹配的每一行的开始,和“$”将匹配的每一行的结束。
        public static let anchorsMatchLines = Options(rawValue: 1 << 2)
        
        ///默认情况下,"."匹配除换行符(\n)之外的所有字符。使用这个配置，选项将允许“.”匹配换行符
        public static let dotMatchesLineSeparators = Options(rawValue: 1 << 3)
        
        //OptionSet的 raw value
        public let rawValue: Int
        
        //将Regex.Options 转换成对应的 NSRegularExpression.Options
        var toNSRegularExpressionOptions: NSRegularExpression.Options {
            var options = NSRegularExpression.Options()
            if contains(.ignoreCase) { options.insert(.caseInsensitive) }
            if contains(.ignoreMetacharacters) {
                options.insert(.ignoreMetacharacters) }
            if contains(.anchorsMatchLines) { options.insert(.anchorsMatchLines) }
            if contains(.dotMatchesLineSeparators) {
                options.insert(.dotMatchesLineSeparators) }
            return options
        }
        
        //OptionSet 初始化
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

//正则匹配结果
extension Regex {
    // Match 封装有单个匹配结果
    public class Match: CustomStringConvertible {
        //匹配的字符串
        public lazy var string: String = {
            return String(describing: self.baseString[self.range])
        }()
        
        //匹配的字符范围
        public lazy var range: Range<String.Index> = {
            return Range(self.result.range, in: self.baseString)!
        }()
        
        //正则表达式中每个捕获组匹配的字符串
        public lazy var captures: [String?] = {
            let captureRanges = stride(from: 0, to: result.numberOfRanges, by: 1)
                .map(result.range)
                .dropFirst()
                .map { [unowned self] in
                    Range($0, in: self.baseString)
            }
            
            return captureRanges.map { [unowned self] captureRange in
                if let captureRange = captureRange {
                    return String(describing: self.baseString[captureRange])
                }
                
                return nil
            }
        }()
        
        private let result: NSTextCheckingResult
        
        private let baseString: String
        
        //初始化
        internal init(result: NSTextCheckingResult, in string: String) {
            precondition(
                result.regularExpression != nil,
                "Invalid Regex"
            )
            
            self.result = result
            self.baseString = string
        }
        
        //返回一个新字符串，根据“模板”替换匹配的字符串。
        public func string(applyingTemplate template: String) -> String {
            let replacement = result.regularExpression!.replacementString(
                for: result,
                in: baseString,
                offset: 0,
                template: template
            )
            
            return replacement
        }
        
        //藐视信息
        public var description: String {
            return "Match<\"\(string)\">"
        }
    }
}
