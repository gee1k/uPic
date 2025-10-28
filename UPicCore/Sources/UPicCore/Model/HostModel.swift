//
//  HostModel.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import HandyJSON

public class HostModel: HandyJSON {
    public var id: String!
    public var name: String!
    public var type: HostType!
    public var data: HostConfig?
    
    required public init() {}
    
    public init(_ type: HostType, data: HostConfig?) {
        self.id = "\(Date().secondStamp)"
        self.name = type.displayNname
        self.type = type
        self.data = data
    }
    
    public func isValid() -> Bool {
        guard let _ = self.id, let _ = self.name, let _ = self.type else {
            return false
        }
        
        if let data = self.data {
            return data.isValid()
        }
        
        return true
    }
    
    public func copy() -> HostModel? {
        guard let str = self.serialize() else {
            return nil
        }
        let hostModel = HostModel.deserialize(serializeString: str)
        return hostModel
    }
    
    public func serialize() -> String? {
        return self.toJSONString()
    }
    
    public static func deserialize(serializeString: String, designatedPath: String? = nil) -> HostModel? {
        guard let model = HostModel.deserialize(from: serializeString, designatedPath: designatedPath) else {
            return nil
        }
        switch model.type {
        case .aliyun_oss:
            model.data = AliyunHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .s3:
            model.data = S3HostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .baidu_bos:
            model.data = BaiduHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .custom:
            model.data = CustomHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .gitee:
            model.data = GiteeHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .github:
            model.data = GithubHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .imgur:
            model.data = ImgurHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .qiniu_kodo:
            model.data = QiniuHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .smms:
            model.data = SmmsHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .tencent_cos:
            model.data = TencentHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .upyun_uss:
            model.data = UpyunHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .weibo:
            model.data = WeiboHostConfig.deserialize(from: serializeString, designatedPath: "data")
        case .none:
            break
        }
        
        return model
    }
}
