local user_context = {};

local function get_conn(uc, db_name)
	assert(uc ~= nil and type(uc) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	local conn = uc.db_connections[db_name].conn;
	assert(conn ~= nil)

	return conn;
end

function user_context:get_connection(db_name)
	return get_conn(self, db_name);
end

function user_context:commit(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	local conn = get_conn(self, db_name);
	local flg, msg = conn:commit();
	if (not flg) then
		error(msg);
	end
	return;
end

function user_context:rollback(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	local conn = get_conn(self, db_name);
	local flg, msg = conn:rollback();
	if (not flg) then
		error(msg);
	end
	return;
end

function user_context:get_seq_nextval(db_name, seq_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	assert(seq_name ~= nil and type(seq_name) == 'string');

	local conn = get_conn(self, db_name);
	return conn:get_seq_nextval(seq_name);
end

function user_context:get_systimestamp(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');

	local conn = get_conn(self, db_name);
	return conn:get_systimestamp();
end

local mt = { __index = user_context };
local factory = {};

function factory.new()
	local uc = {};
	uc.db_connections = {};
	uc = setmetatable(uc, mt);
	return uc;
end

return factory;

