# ZHAuthorization
iOS系统各种权限请求、判断

# cocoapods support
```
pod 'ZHAuthorization'
```

```
//请求使用位置权限
[ZHAuthManager requestAuthorization:AuthTypeLocationAlways authorizedResult:^(BOOL granted) {
//do something
}];

```
### 其他的权限类此
