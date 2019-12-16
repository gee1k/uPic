<div align="right"><strong>🇨🇳中文</strong>  | <strong><a href="./README.md">🇬🇧English</a></strong></div>
<div align="center">
  <img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/logo.png" alt="uPic">
  <br>
  <br>
  <p>
    Picture and file upload tool for macOS. - A native, powerful, beautiful and simple  
  </p>
  
  <p>
  [![Travis Build Status](https://img.shields.io/travis/gee1k/uPic.svg?style=flat-square&logo=Travis)](https://travis-ci.org/gee1k/uPic) [![GitHub release](https://img.shields.io/github/release/gee1k/uPic?label=version&style=flat-square&logo=GitHub)](https://github.com/gee1k/uPic/releases/latest) [![Downloads](https://img.shields.io/github/downloads/gee1k/uPic/total.svg?style=flat-square)](https://github.com/gee1k/uPic/releases) [![MIT](https://img.shields.io/github/license/gee1k/uPic?style=flat-square)](https://github.com/gee1k/uPic/blob/master/LICENSE)
[![Donate on PayPal](https://img.shields.io/badge/support-PayPal-blue?style=flat-square&logo=PayPal)](https://paypal.me/geee1k) [![Chat on Telegram](https://img.shields.io/badge/chat-Telegram-blueviolet?style=flat-square&logo=Telegram)](https://t.me/upic_host) [![Follow My Twitter](https://img.shields.io/badge/follow-Tweet-blue?style=flat-square&logo=Twitter)](https://twitter.com/geee1k) [![Follow My Twitter](https://img.shields.io/badge/follow-Weibo-red?style=flat-square&logo=sina-weibo)](https://weibo.com/6436660358)
  </p>
</div>
-----
**👬Chat: _[Telegram](https://t.me/upic_host), [Twitter](https://twitter.com/geee1k), [Weibo](https://weibo.com/6436660358), [Wechat Group](https://raw.githubusercontent.com/gee1k/oss/master/personal/geee1k.JPG)_**

**☕️Donate: _[Paypal](https://paypal.me/geee1k), [Alipay](https://raw.githubusercontent.com/gee1k/oss/master/qrcode/alipay-mini.jpeg), [WechatPay](https://raw.githubusercontent.com/gee1k/oss/master/qrcode/wechat-zs.JPG)_**

## 📑 Introduction

> **uPic(upload Picture) is a image(file) hosting client for Mac.** 
> You can upload image, files to specified provider’s OSD service which was configured.
> Before uploading, you can get an url immediately which can be accessed on internet. 



**💡 Tips：** They can automatic uploading local file and screenshot, meanwhile the menu bar shows the uploading progress constantly. File's link will automatically copied to the clipboard when finish upload, make you insert pictures quickly when you are blogging or chatting. Link’s format can be a normal URL, HTML or Markdown, it's totally up to you.

**🔋 Support image hosting：**[smms](https://sm.ms/), [UPYUN USS](https://www.upyun.com/products/file-storage), [qiniu KODO](https://www.qiniu.com/products/kodo), [Aliyun OSS](https://www.aliyun.com/product/oss/), [TencentCloud COS](https://cloud.tencent.com/product/cos), [BaiduCloud BOS](https://cloud.baidu.com/product/bos.html), [Weibo](https://weibo.com/), [Github](https://github.com/settings/tokens), [Gitee](https://gitee.com/profile/personal_access_tokens), [Amazon S3](https://aws.amazon.com/cn/s3/), [Imgur](https://imgur.com/), [custom upload api](https://blog.svend.cc/upic/tutorials/custom), ...

## 🚀 How to install


### 1. Homebrew(Recommend):
```
brew cask install upic
```
### 2. Download from github
 Click [release](https://github.com/gee1k/uPic/releases) to download.
 **If accessing Github is difficult to download, you can download it from [Gitee release](https://gitee.com/gee1k/uPic/releases).**

### Check Finder Extensions's authority

- 1. Run uPic

- 2. Open `System preferences` - `Extensions` - `Finder Extensions` make sure that `uPicFinderExtension` is be selected

  <center>
    <img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-finder-extension.png" height="300">
  </center>



## 🕹 How to use it

| function | description | previewing |
| --- | --- | --- |
| **🖥 Pick** | choose file from `Finder` | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-selectFile.gif) |
| **⌨️ Copy** | uploud file from clipboard | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-paste.gif) |
| **🖱 Drag local file** | drag file to status bar | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-drag-finder.gif) |
| **🖱 Drag from browser** | drag image to status bar from browser | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-drag-browser.gif) |
| **📸 Screenshot** | capture a screenshot | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-screenshot.gif) |
| **📂 Right click** | right click to upload | ![](https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-finder-contextmenu.gif) |



## 🧰 More Functions

**Except these basic functions, uPic also provides a series of small features to improve user experience.**

<details><summary>1. ⌨︎ Global shortcut key</summary><br>
<p>
	<center>
		<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-shortcuts.png" height="300">
	</center>
</p>
</details>
<details><summary>2. 🕦 Upload history</summary><br>
<p>
	<center>
		<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-history.png" height="300">
	</center>
</p>
</details>
<details><summary>3. 📢 More functions are waiting for you to check it out</summary><br>
<p>
	...
</p>
</details>



## ❓ Question

<details>
	<summary>1.How to configurate image hosting❓</summary>
	<ul>
		<li><a href="https://blog.svend.cc/upic/tutorials/weibo/en" target="_blank">uPic configuration - Weibo</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/upyun_uss/en" target="_blank">uPic configuration - UPYUN</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/qiniu_kodo/en" target="_blank">uPic configuration - Qiniu</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/aliyun_oss/en" target="_blank">uPic configuration - Aliyun</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/tencent_cos/en" target="_blank">uPic configuration - Tencent Cloud</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/baidu_bos/en" target="_blank">uPic configuration - Baidu Cloud</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/amazon_s3/en" target="_blank">uPic configuration - Amazon S3</a></li>
    <li><a href="https://blog.svend.cc/upic/tutorials/imgur/en" target="_blank">uPic configuration - Imgur</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/github/en" target="_blank">uPic configuration - Github</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/gitee/en" target="_blank">uPic configuration - Gitee</a></li>
		<li><a href="https://blog.svend.cc/upic/tutorials/custom/en" target="_blank">uPic configuration - Custom upload</a></li>
	</ul>
</details>
<details><summary>2. Finder extension doesn't work❓</summary><br>
<p>Because of Finder extension will always be selected after select action was done. So if you come across Finder extension operation is unresponsive, maybe uPic program was not runing.</p>
</details>
<details>
	<summary>3.Why I finished configuration of image hosting already, image/file upload failed?</summary>
	<div>
		<p>maybe you choose the wrong image hosting, go to check it out~</p>
		<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/en-default-host.png" width="450">
	</div> 
</details>
<details>
<summary>4. Upload completed without notification❓</summary><br>
<p><strong>For example, when the v0.10.4 version is changed, the notification method has changed, and the user may not receive the notification after the upload is completed. Can be solved by the following methods</strong></p>
<p>1.In the <code>System preferences</code> - <code>Notifications</code>, find <code>uPic</code> in the list and delete (press the Delete key)</p>
<p>2.Exit uPic and restart</p>
<img src="https://raw.githubusercontent.com/gee1k/oss/master/screenshot/uPic/delete-notification.png" width="450">
</details>
<details>
<summary>5.macOS 10.15 can't open, software is damaged❓</summary><br>
<p><strong>After the terminal executes the following command, the APP can be opened normally.</strong></p>
<p><code>sudo xattr -d com.apple.quarantine /Applications/uPic.app</code> </p>
</details>

## ✨ Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/gee1k/uPic/graphs/contributors"><img src="https://opencollective.com/uPic/contributors.svg?width=890&button=true" /></a>


### Other Contributors

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


-----

**uPic** © [Svend](https://github.com/gee1k), Released under the [MIT](./LICENSE) License.<br>
Authored and maintained by Svend with help from contributors ([list](https://github.com/gee1k/uPic/contributors)).