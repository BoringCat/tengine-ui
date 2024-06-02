# TengineUI
基于 [![0xJacky/nginx-ui][nginx-ui]](https://github.com/0xJacky/nginx-ui) 替换后端为 [![tengine][tengine]](https://tengine.taobao.org) 的docker镜像

## 使用
### 初始化文件
运行以下命令会在 `/etc/nginx` 下创建 conf 和 html 文件夹，并覆盖存在的文件
```sh
docker run --rm -v /path/to/nginx:/etc/nginx --entrypoint /bin/sh -it boringcat/tengine-ui -c install.sh
```
### 启动
环境变量参考 https://nginxui.com/zh_CN/guide/env.html
```sh
docker run -v /path/to/nginx:/etc/nginx -v /path/to/nginx-ui:/etc/nginx-ui -it boringcat/tengine-ui
```

## 构建
```sh
docker build --build-arg TENGINE_BUILDFLAG='--with-http_ssl_module --with-http_v2_module --with-stream --with-stream_ssl_module'\
    -t tengine-ui:dev .
```
### 必填参数
- `TENGINE_BUILDFLAG`  
  编译 tengine 时使用的参数，参考 https://nginx.org/en/docs/configure.html 和 https://tengine.taobao.org/document_cn/install_cn.html

### 必要文件
- `sources/tengine-${TENGINE_VERSION}.tar.gz`  
  可从 https://tengine.taobao.org/download_cn.html 获取  
  Q: 为什么不在Dockerfile里面下载？  
  A: Debug每次都要下载太难受，本来apk add就慢了，还要不断重复下一样的东西？

### 可选参数
- `PNPM_VERSION`  
  当 nginx-ui 更新了 pnpm 时需要设置，默认值为 9.0.6，取自 v2.0.0-beta.24
- `APK_MIRROR`  
  alpine 镜像源，用来替换 dl-cdn.alpinelinux.org
- `APK_MIRROR_HTTPS`  
  是否使用 https 镜像源，true 为是，false 为否，其他值不修改  
  注：最新 alpine 镜像默认为 https，此项可以不设置  
  PS：设置为 false 加上本地 APK_MIRROR，你就能在本地缓存apk包方便debug
- `GOPROXY`  
  下载 go pkg 时的代理站点，推荐 [goproxy.cn](https://goproxy.cn)  
  示例: `--build-arg 'GOPROXY=https://goproxy.cn,direct'`
- `TENGINE_VERSION`  
  默认 3.1.0。需要和本地源码包版本匹配
- `BROTLI_VERISON`  
  br压缩模块版本，默认1.0.0rc  
  PS：它([google/ngx_brotli](https://github.com/google/ngx_brotli))也只有一个tag
- `NGX_CACHE_PURGE_VERSION`  
  缓存清理模块版本，默认 2.5.3
- `BUILD_THREADS`  
  编译 tengine 使用的线程数，默认为1

[nginx-ui]: https://img.shields.io/badge/0xJacky-nginx--ui-blue?link=https://github.com/0xJacky/nginx-ui&style=flat-square
[tengine]: https://img.shields.io/badge/taobao-tengine-blue?link=https://tengine.taobao.org&style=flat-square