local basic_file = require("rockspec");
local stringx = require("pl.stringx");

function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

function include_xsd_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -1 '..directory..' |grep _xml.lua')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		filename = filename:gsub(".lua","");
        local output_file_path_parts = stringx.split(directory,"/");
		local j = 1;
		local output_file_path = '';
		while(j <= #output_file_path_parts) do
			if(j <= #output_file_path_parts) then
				output_file_path = output_file_path..output_file_path_parts[j]..".";
		    else
				output_file_path = output_file_path..output_file_path_parts[j];
			end
		    j = j+1;
		end
        local mapping = require(output_file_path..filename);
        for i, v in pairs(mapping) do
            xsd_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
            table.insert(basic_file.build.modules, xsd_mapping);
    	end
    end
    pfile:close()
end

if(exists("build/com/biop/registrar") == true and exists("build/com/biop/aaa") == true) then
	include_xsd_files("build/com/biop/registrar");
	include_xsd_files("build/com/biop/aaa");
end

function include_idl_files(directory)
	local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..' |grep .xml')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		local module = directory:gsub("idl.","");
        local mapping = require("build.biop."..module..".idl."..filename:gsub("%.xml", "").."_interface_xml");
        for i, v in pairs(mapping) do
            idl_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
            table.insert(basic_file.build.modules, idl_mapping);
        end
    end
    pfile:close()
end

if(exists("idl/") == true) then
	include_idl_files("idl/aaa");
	include_idl_files("idl/registrar");
end

function include_val_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..' |grep .xml')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		local mapping = require("build.biop.registrar.val."..filename:gsub("%.xml", "").."idations_xml");
		for i, v in pairs(mapping) do
			val_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
		    table.insert(basic_file.build.modules, val_mapping);
	    end
    end
    pfile:close()
end

if(exists("val") == true) then
	include_val_files("val/");
end

function include_ddl_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..' |grep .xml');
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
        local mapping = require("build.biop.registrar.tbl."..filename:gsub("%.xml", "").."_xml");
		for i, v in pairs(mapping) do
			ddl_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
        	table.insert(basic_file.build.modules, ddl_mapping);
		end
    end
    pfile:close()
end

if(exists("ddl") == true) then
	include_ddl_files("ddl/");
end

function include_src_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..' |grep .lua');
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		local src_mapping = '[\"biop.registrar.'..filename:gsub("%.lua", "").."\"] = ".."\"src/"..filename.."\"";
        table.insert(basic_file.build.modules, src_mapping);
    end
    pfile:close()
end

if(exists("src") == true) then
	include_src_files("src/");
end

function write_rockspec(basic_file, filename)
	local file = io.open(filename,"w+");
	--Write rockspec file with basic info
	file:write("package = \""..basic_file.package.."\"\nversion = \""..basic_file.version.."\"\n\ndescription = {\n\tsummary = \""..basic_file.description.summary.."\",\n\tdetailed = [[\n"..basic_file.description.detailed.."]],\n\tlicense = \""..basic_file.description.license.."\",\n\thomepage = \""..basic_file.description.homepage.."\"\n}\n\ndependencies = {\n\t\""..basic_file.dependencies[1].."\"\n}\n\nsource = {\n\turl = \""..basic_file.source.url.."\",\n\ttag = \""..basic_file.source.tag.."\",\n}\n\nbuild = {\n\ttype = \""..basic_file.build.type.."\",\n\tmodules = {\n");
	--Write the appended modules part to the rockspec file
	local j = 1;
    for i, v in pairs(basic_file.build.modules) do
		j=j+1;
		if(j < #basic_file.build.modules) then
			file:write("\t\t"..v..",\n");
		else if(j == #basic_file.build.modules) then
			file:write("\t\t"..v);
		end
	end
end
	file:write("\n  }\n}");
  
  print("Rockspec created "..filename);
  return;
end

local File=arg[1];


write_rockspec(basic_file, File);
