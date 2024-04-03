FROM openresty/openresty:focal
RUN mkdir -p /homework && mkdir -p /var/run/openresty/ && mkdir -p /usr/local/openresty/nginx/sites && groupadd -r -g 1001 openresty && useradd -r -u 1001 -g openresty openresty
WORKDIR /homework
RUN chown -R openresty:openresty /homework && chown -R openresty:openresty /var/run/openresty/ && chown -R openresty:openresty /usr/local/openresty/
COPY default.conf /etc/nginx/conf.d/default.conf
COPY prometheus.lua /usr/local/openresty/nginx/lualib/lib/prometheus.lua
COPY prometheus_keys.lua /usr/local/openresty/nginx/lualib/lib/prometheus_keys.lua
COPY prometheus_test.lua /usr/local/openresty/nginx/lualib/lib/prometheus_test.lua
COPY prometheus_resty_counter.lua /usr/local/openresty/nginx/lualib/lib/prometheus_resty_counter.lua
EXPOSE 8000
USER openresty
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
