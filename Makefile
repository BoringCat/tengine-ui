build:
	@docker build --pull\
		--build-arg 'BUILD_THREADS=8'\
		--build-arg 'TENGINE_VERSION=3.1.0'\
		--build-arg 'BROTLI_VERISON=1.0.0rc'\
		--build-arg 'NGX_CACHE_PURGE_VERSION=2.5.3'\
		--build-arg 'APK_MIRROR=mirrors.sjtug.sjtu.edu.cn'\
		--build-arg 'TENGINE_BUILDFLAG=--with-http_ssl_module --with-http_v2_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_slice_module --with-http_realip_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-select_module --with-poll_module --add-module=modules/ngx_http_upstream_check_module --add-module=modules/ngx_http_reqstat_module --add-module=modules/ngx_http_upstream_dynamic_module'\
	-t boringcat/tengine-ui:latest .

buildx-publish:
	@docker buildx build --pull --push\
		--platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6\
		--builder multiplatform\
		--build-arg 'BUILD_THREADS=8'\
		--build-arg 'TENGINE_VERSION=3.1.0'\
		--build-arg 'BROTLI_VERISON=1.0.0rc'\
		--build-arg 'NGX_CACHE_PURGE_VERSION=2.5.3'\
		--build-arg 'APK_MIRROR=mirrors.sjtug.sjtu.edu.cn'\
		--build-arg 'TENGINE_BUILDFLAG=--with-http_ssl_module --with-http_v2_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_slice_module --with-http_realip_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-select_module --with-poll_module --add-module=modules/ngx_http_upstream_check_module --add-module=modules/ngx_http_reqstat_module --add-module=modules/ngx_http_upstream_dynamic_module'\
		-t boringcat/tengine-ui:latest .