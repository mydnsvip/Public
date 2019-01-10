# mydnsvip

### 介绍
**blog.mydns.vip**
更多内容，可以访问豫章小站 [https://blog.mydns.vip/](https://blog.mydns.vip?_blank)


var aTagArr = [].slice.apply(document.getElementsByTagName("a"));

aTagArr.forEach(function (e, i) {
  e.href.indexOf("_blank") > -1 ? e.target = "_blank" : null;
});