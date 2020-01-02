//
//  OutputType.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

enum OutputType: Int {
    case url = 0
    case html = 1
    case markdown = 2
    case ubb = 3
    
    init(value: Int? = 0) {
        switch value {
            case 1: self = .html
            case 2: self = .markdown
            case 3: self = .ubb
            default: self = .url
        }
    }
    
    init(value: String? = "url") {
        switch value {
            case "html": self = .html
            case "markdown": self = .markdown
            case "md": self = .markdown
            case "ubb": self = .ubb
            default: self = .url
        }
    }
    
    var title: String {
        switch self {
        case .url:
            return "URL"
        case .html:
            return "HTML"
        case .markdown:
            return "Markdown"
        case .ubb:
            return "UBB"
        }
    }
    
    func formatUrl(_ url: String) -> String {
        var filename = url.lastPathComponent.deletingPathExtension.trim()
        let tempArr = filename.components(separatedBy: .whitespaces).map{ $0.trim() }.filter{ !$0.isEmpty }
        filename = tempArr.joined(separator: "")
        
        var outputUrl = ""
        switch self {
        case .html:
            outputUrl = "<img src='\(url)' alt='\(filename)'/>"
            break
        case .markdown:
            outputUrl = "![\(filename)](\(url))"
            break
        case .ubb:
            outputUrl = "[img]\(url)[/img]"
            break
        default:
            outputUrl = url
            
        }
        
        return outputUrl
    }
}
