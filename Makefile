TENGINE_BUILDFLAG       ?= --with-http_ssl_module\
	--with-http_v2_module\
	--with-http_stub_status_module\
	--with-http_gzip_static_module\
	--with-http_auth_request_module\
	--with-http_slice_module\
	--with-http_realip_module\
	--with-stream\
	--with-stream_ssl_module\
	--with-stream_ssl_preread_module\
	--with-select_module\
	--with-poll_module\
	--add-module=modules/ngx_http_upstream_check_module\
	--add-module=modules/ngx_http_reqstat_module\
	--add-module=modules/ngx_http_upstream_dynamic_module\
	--add-module=modules/ngx_brotli\
	--add-module=modules/ngx_cache_purge
OS                      := $(shell uname)
TENGINE_VERSION         ?= 3.1.0
BROTLI_VERISON          ?= 1.0.0rc
NGX_CACHE_PURGE_VERSION ?= 2.5.3
DOCKER_BUILDX_BUILDER   ?= default
DOCKER_IMAGE_PREFIX     ?= docker.io/boringcat
ifndef NGINX_UI_VERSION
	$(error NGINX_UI_VERSION is undefined)
endif

ifeq ($(OS),Linux)
	BUILD_THREADS ?= $(shell nproc)
else ifeq ($(OS),Darwin)
	BUILD_THREADS ?= $(shell sysctl -n hw.physicalcpu)
endif
BUILD_THREADS           ?= 1

download:
	@mkdir -p sources/
ifeq (,$(wildcard ./sources/tengine-$(TENGINE_VERSION).tar.gz))
	@wget -c https://tengine.taobao.org/download/tengine-$(TENGINE_VERSION).tar.gz -O sources/tengine-$(TENGINE_VERSION).tar.gz
endif
ifeq (,$(wildcard ./sources/ngx_brotli-$(BROTLI_VERISON).tar.gz))
	@wget -c https://github.com/google/ngx_brotli/archive/refs/tags/v$(BROTLI_VERISON).tar.gz -O sources/ngx_brotli-$(BROTLI_VERISON).tar.gz
endif
ifeq (,$(wildcard ./sources/ngx_cache_purge-$(NGX_CACHE_PURGE_VERSION).tar.gz))
	@wget -c https://github.com/nginx-modules/ngx_cache_purge/archive/refs/tags/$(NGX_CACHE_PURGE_VERSION).tar.gz -O sources/ngx_cache_purge-$(NGX_CACHE_PURGE_VERSION).tar.gz
endif

build: download
	@docker build --pull\
		--build-arg 'BUILD_THREADS=$(BUILD_THREADS)'\
		--build-arg 'TENGINE_VERSION=$(TENGINE_VERSION)'\
		--build-arg 'BROTLI_VERISON=$(BROTLI_VERISON)'\
		--build-arg 'NGX_CACHE_PURGE_VERSION=$(NGX_CACHE_PURGE_VERSION)'\
		--build-arg 'APK_MIRROR=$(APK_MIRROR)'\
		--build-arg 'APK_MIRROR_HTTPS=$(APK_MIRROR_HTTPS)'\
		--build-arg 'TENGINE_BUILDFLAG=$(TENGINE_BUILDFLAG)'\
		-t $(DOCKER_IMAGE_PREFIX)/tengine-ui:latest\
		-t $(DOCKER_IMAGE_PREFIX)/tengine-ui:$(NGINX_UI_VERSION)\
		.

buildx-publish: download
	@docker buildx build --pull --push\
		--platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6\
		--builder $(DOCKER_BUILDX_BUILDER)\
		--build-arg 'BUILD_THREADS=$(BUILD_THREADS)'\
		--build-arg 'TENGINE_VERSION=$(TENGINE_VERSION)'\
		--build-arg 'BROTLI_VERISON=$(BROTLI_VERISON)'\
		--build-arg 'NGX_CACHE_PURGE_VERSION=$(NGX_CACHE_PURGE_VERSION)'\
		--build-arg 'APK_MIRROR=$(APK_MIRROR)'\
		--build-arg 'APK_MIRROR_HTTPS=$(APK_MIRROR_HTTPS)'\
		--build-arg 'TENGINE_BUILDFLAG=$(TENGINE_BUILDFLAG)'\
		-t $(DOCKER_IMAGE_PREFIX)/tengine-ui:latest\
		-t $(DOCKER_IMAGE_PREFIX)/tengine-ui:$(NGINX_UI_VERSION)\
		.