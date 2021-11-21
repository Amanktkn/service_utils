local netssl = require('libevlnetssl');

local client = {}

local mt = { __index = client };
local client_maker = {};

local function get_uri_from_url(url)
	return string.match(url, '[^?]+');
end

local function make_new_http_client(hostname, port)
	assert(hostname ~= nil and type(hostname) == 'string');
	assert(port ~= nil and math.type(port) == 'integer');

	local new_client = {};
	new_client = setmetatable(new_client, mt);

	local http_conn, msg, ss = platform.make_http_connection(hostname, port);

	new_client._http_conn = http_conn;
	new_client._ss = ss;
	new_client._host = tostring(hostname)..':'..tostring(port);

	return new_client;
end

client_maker.new = function(url, port)
	return make_new_http_client(url, port);
end

client.send_request = function (self, uri, headers, body)
	assert(self ~= nil and type(self) == 'table');
	assert(uri ~= nil and type(uri) == 'string');
	assert(headers ~= nil and type(headers) == 'table');
	assert(headers.method == nil or type(headers.method) == 'string');
	assert(body == nil or type(body) == 'string');
	assert(headers.method == 'GET' or headers.method == 'PUT'
			or headers.method == 'POST' or headers.method == 'DELETE');

	local request = platform.new_request();
	for n,v in pairs(headers) do
		request:set_hdr_field(n, v);
	end
	request:set_uri(uri);
	request:set_host(self._host);
	--request:set_chunked_trfencoding(true);
	request:set_content_length(string.len(body));
	request:set_expect_continue(true);
	request:set_content_type('application/json');

	platform.send_request_header(self._http_conn, request);
	request:write(body);
	platform.send_request_body(self._http_conn, request);

	return;
end

client.connext_TLS = function (self)
	netssl.connect_TLS(self._ss);
end

client.recv_response = function (self)
	assert(self ~= nil and type(self) == 'table');

	local response = platform.receive_http_response(self._http_conn);
	local resp_status = response:get_status();
	local status = true;
	if (math.floor(resp_status / 100) ~= 2) then
		status = false;
	end
	local resp_buf = '';
	local buf = response:read();
	while (buf ~= nil) do
		resp_buf = resp_buf..buf;
		buf = response:read();
	end
	return status, resp_buf;
end


return client_maker;

