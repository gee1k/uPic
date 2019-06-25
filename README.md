# uPic 

> 图片(文件)上传 

<p align="center">
  <img src="https://s2.svend.cc/projects/uPic/icon_128x128.png" alt="">
</p>
<p align="center">
  <a href="https://github.com/gee1k/uPic/releases">
    <img src="https://img.shields.io/github/downloads/gee1k/uPic/total.svg?style=flat-square" alt="">
  </a>
  <a href="https://github.com/gee1k/uPic/releases/latest">
    <img src="https://img.shields.io/github/release/gee1k/uPic.svg?style=flat-square" alt="">
  </a>
</p>


## ⚒ 上传方式

**uPic支持选择文件上传、拖拽文件上传、复制文件上传、截图上传。支持菜单栏显示实时进度**

### 1.选择文件上传
点击菜单栏 `选择文件上传`即可打开 Finder 选择需要上传的文件。
![selectFile](https://s2.svend.cc/projects/uPic/upload/selectFile.gif)

### 2.复制上传
将需要上传的文件复制到剪切板，然后点击菜单栏中的`上传已拷贝的文件`即可上传。
![paste](https://s2.svend.cc/projects/uPic/upload/paste.gif)

### 3.拖拽上传
只需要将当前图床所支持格式的文件拖到菜单栏的 uPic 图标上即可上传。
![drag](https://s2.svend.cc/projects/uPic/upload/drag.gif)

### 4.截图上传
点击菜单栏 `截图上传`会激活截图操作，拉框选择要截图的范围即可自动上传。
![screenshot](https://s2.svend.cc/projects/uPic/upload/screenshot.gif)

> 除了复制上传以外，所有上传方式均可以在`偏好设置`中设置全局快捷键。
> 设置好全局快捷键之后可以在任何时候通过快捷键激活对应的上传操作

![shortcuts](https://s2.svend.cc/projects/uPic/upload/shortcuts.png)

## 💻 图床配置

**在`偏好设置`中可配置图床，同一类型图床可配置多个，已满足多个云储存位置**

![hosts](https://s2.svend.cc/projects/uPic/upload/hosts.png)

配置好的图床可以在菜单栏`图床`栏看到，并选择您接下来要上传到的图床。

![default-host](https://s2.svend.cc/projects/uPic/upload/default-host.png)

## 📝 输出格式

**支持多种输出格式，以快速帮你实现的不同需求。**

![output](https://s2.svend.cc/projects/uPic/upload/output.png)

## 支持图床服务

**以下是现有和未来计划加入支持的图床**

- [x] [~~smms~~](https://sm.ms/)

- [x] [~~又拍云 USS~~](https://www.upyun.com/products/file-storage)

- [x] [~~七牛云 KODO~~](https://www.qiniu.com/products/kodo)

- [x] [~~腾讯云 COS~~](https://cloud.tencent.com/product/cos)

- [x] [~~阿里云 OSS~~](https://www.aliyun.com/product/oss)

- ...

  # ⚙ 开发

- 1.克隆代码到本地
	
	`https://github.com/gee1k/uPic.git`
	
- 2.安装依赖，本项目依赖使用 [Cocoapods](https://cocoapods.org/) 管理，请先确保已有 Cocoapods 环境

  ```sh
  # 进入项目目录
  cd uPic
  # 安装依赖
  pod install
  ```

- 3.依赖安装完成之后，可编译测试一下是否通过

# ✉️ 联系我

- `Email`: `svend.jin#gmail.com` (#替换为@)
- `微信群`: `JSW5297` (请备注一下uPic)
- `Telegram`: [gee1k]()

# ❤️ 赞助

如果你喜欢 uPic ，欢迎给我打赏

- 支付宝：

<img src="https://s2.svend.cc/qrcode/alipay-mini.jpeg" alt="">

- 微信：

<img src="https://s2.svend.cc/qrcode/wechat-mini.jpeg" alt="">

## License

[MIT](http://opensource.org/licenses/MIT)

Copyright (c) 2019 gee1k
