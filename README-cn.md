<div align="right"><strong>🇨🇳中文</strong>  | <strong><a href="./README.md">🇬🇧English</a></strong></div>
<div align="center">
  <img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/logo.png" alt="uPic">
</div>

# ☁️ 简洁的 Mac 图床客户端 uPic

<div style="display: flex;justify-content: center;" align="center">
	<a href="https://github.com/gee1k/uPic/releases/latest">
    <img src="https://img.shields.io/github/release/gee1k/uPic?label=version&style=flat-square" alt="">
  </a>
	<a href="https://github.com/gee1k/uPic/releases" style="margin: 0 5px;">
    <img src="https://img.shields.io/github/downloads/gee1k/uPic/total.svg?style=flat-square" alt="">
  </a> 
  <a href="https://github.com/gee1k/uPic/blob/master/LICENSE">
		<img alt="GitHub" src="https://img.shields.io/github/license/gee1k/uPic?style=flat-square">
	</a>
</div>


## 📑 简介

> **uPic(upload Picture) 是一款 Mac 端的图床(文件)上传客户端**
> 可将图片、各种文件上传到配置好的指定提供商的对象存储中。
> 然后快速获取可供互联网访问的文件 URL

**💡 特点：** 无论是本地文件、或者屏幕截图都可自动上传，菜单栏显示实时上传进度。上传完成后文件链接自动复制到剪切板，让你无论是在写博客、灌水聊天都能快速插入图片。
连接格式可以是普通 URL、HTML 或者 Markdown，仍由你掌控。

**🔋 支持图床：** [smms](https://sm.ms/)、 [又拍云 USS](https://www.upyun.com/products/file-storage)、[七牛云 KODO](https://www.qiniu.com/products/kodo)、 [阿里云 OSS](https://www.aliyun.com/product/oss/)、 [腾讯云 COS](https://cloud.tencent.com/product/cos)、[微博](https://weibo.com/)、[Github](https://github.com/settings/tokens)、 [Gitee](https://gitee.com/profile/personal_access_tokens)、 [Amazon S3](https://aws.amazon.com/cn/s3/)、[Imgur](https://imgur.com/)、[自定义上传接口](https://blog.svend.cc/upic/tutorials/custom)、...

## 🚀 如何安装

### 下载安装
#### 1.Homebrew:
```
brew cask install upic
```
#### 2.手动
从 [Github release](https://github.com/gee1k/uPic/releases) 下载。
**如果访问 Github 下载困难的，可以从[Gitee release](https://gitee.com/gee1k/uPic/releases)下载。**

### 检查 Finder 扩展权限

- 1.打开 uPic

- 2.打开`系统偏好设置` - `扩展` - `访达扩展` 确保 `uPicFinderExtension`是勾选状态

  <center>
    <img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/finder-extension.png" height="300">
  </center>



## 🕹 使用方式

| 功能 | 描述 | 预览 |
| --- | --- | --- |
| **🖥 选择文件上传** | 从`Finder`选择文件上传 | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/selectFile.gif) |
| **⌨️ 复制文件上传** | 上传已拷贝到剪切板的文件 | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/paste.gif) |
| **🖱 拖拽本地文件上传** | 拖拽文件到状态栏上传 | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/drag-finder.gif) |
| **🖱 拖拽浏览器图片上传** | 从浏览器拖拽图片到状态栏上传 | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/drag-browser.gif) |
| **📸 截图上传** | 直接拉框截图上传 | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/screenshot.gif) |
| **📂 Finder 中右键上传** | 右击文件上传 | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/finder-contextmenu.gif) |



## 🧰 更多功能

**除了以上这些最基本的功能以外，uPic 还提供了一系列小功能让你使用起来更方便更顺心**

<details><summary>1. ⌨︎ 全局快捷键</summary><br>
<p>
	<center>
		<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/shortcuts.png" height="300">
	</center>
</p>
</details>
<details><summary>2. 🕦 上传历史</summary><br>
<p>
	<center>
		<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/history.png" height="300">
	</center>
</p>
</details>
<details><summary>3. 📢 更多功能等待你发现</summary><br>
<p>
	...
</p>
</details>



## ❓ 常见问题

<details>
	<summary>1.图床如何配置❓</summary>
	<ul>
		<li><a href="https://blog.svend.cc/upic/tutorials/weibo" target="_blank">uPic 图床配置教程 - 微博</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/upyun_uss" target="_blank">uPic 图床配置教程 - 又拍云</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/qiniu_kodo" target="_blank">uPic 图床配置教程 - 七牛云</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/aliyun_oss" target="_blank">uPic 图床配置教程 - 阿里云</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/tencent_cos" target="_blank">uPic 图床配置教程 - 腾讯云</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/amazon_s3" target="_blank">uPic 图床配置教程 - Amazon S3</a></li>
    <li><a href="https://blog.svend.cc/upic/tutorials/imgur" target="_blank">uPic 图床配置教程 - Imgur</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/github" target="_blank">uPic 图床配置教程 - Github</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/gitee" target="_blank">uPic 图床配置教程 - 码云(Gitee)</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/custom" target="_blank">uPic 图床配置教程 - 自定义上传</a></li>
	</ul>
</details>
<details><summary>2. Finder 扩展不工作了❓</summary><br>
<p>由于 Finder 扩展是只要加上之后会一直都存在，所以当你遇到 Finder 扩展操作无反应的时候，可能是 uPic 主程序没有打开</p>
</details>
<details>
<summary>3.为什么我配置了图床，图片/文件却没有上传到我的图床中</summary>
	<div>
		<p>配置好的图床可以在菜单栏`图床`中选择。选中的图床就是您接下来文件会上传到的图床</p>
		<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/default-host.png" width="450">
	</div> 
</details>
<details>
<summary>4.上传完成没有通知❓</summary><br>
<p><strong>如v0.10.4版本时通知方式发生了改变，可能会有用户在上传完成之后没有收到通知。可使用以下方法解决</strong></p>
<p>1.在<code>系统偏好设置</code> - <code>通知</code>，列表中找到 <code>uPic</code> 选中并删除（按 Delete 键）</p>
<p>2.退出 uPic 并重新启动</p>
<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/delete-notification.png" width="450">
</details>




## 💌 联系我

- `Email`: svend.jin@gmail.com
- `Telegram`: [gee1k](https://t.me/gee1k)
- `项目地址`: [Github](https://github.com/gee1k/uPic)
- `uPic 产品交流群(Telegram)`:  [点击加入 TG 群](https://t.me/upic_host)
- `微信群`:  <small>扫描下方二维码加好友拉你入群 ↓ </small>

	<img src="https://raw.githubusercontent.com/gee1k/oss/master/personal/geee1k.JPG" height="200">


## ❤️ 赞助

如果你喜欢 uPic ，欢迎给我打赏

| **Paypal** | **支付宝** | **微信** |
| :-: | :-: | :-: |
| [@Geee1k](https://paypal.me/geee1k) | ![](https://raw.githubusercontent.com/gee1k/oss/master/qrcode/alipay-mini.jpeg) | ![](https://raw.githubusercontent.com/gee1k/oss/master/qrcode/wechat-zs.JPG) |


## ✨ Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://alley.js.org"><img src="https://avatars1.githubusercontent.com/u/19723234?v=4" width="100px;" alt="alley"/><br /><sub><b>alley</b></sub></a><br /><a href="#translation-m01i0ng" title="Translation">🌍</a></td>
    <td align="center"><a href="https://github.com/Jackxun123"><img src="https://avatars2.githubusercontent.com/u/33611532?v=4" width="100px;" alt="Jackxun123"/><br /><sub><b>Jackxun123</b></sub></a><br /><a href="#translation-Jackxun123" title="Translation">🌍</a></td>
    <td align="center"><a href="https://github.com/kkkkkkyrie"><img src="https://avatars2.githubusercontent.com/u/30786071?v=4" width="100px;" alt="eleven"/><br /><sub><b>eleven</b></sub></a><br /><a href="#translation-kkkkkkyrie" title="Translation">🌍</a></td>
    <td align="center"><a href="https://immx.io/"><img src="https://avatars1.githubusercontent.com/u/16921591?v=4" width="100px;" alt="zhucebuliaomax"/><br /><sub><b>zhucebuliaomax</b></sub></a><br /><a href="#design-ihatework" title="Design">🎨</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

