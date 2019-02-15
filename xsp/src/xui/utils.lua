local _M={}

_M.buildID=function(par,id)
	return tostring(par).."@"..tostring(id)
end

_M.mergeTable=function (t1,t2)
	if type(t1) == 'table' and type(t2) == 'table' then
		for k ,v in pairs(t2) do
			t1[k] = v
		end
	end
end

_M.split=function (str,delimiter)
	if str == nil or str == '' or delimiter == nil then
		return {}
	end
	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result,match)
	end
	return result
end

_M.getTableLen=function (t)
	local index = 0
	for k ,v in pairs(t) do
		index = index +1
	end
	return index
end

function table.copy(Tbl)
	local t={}
	for k ,v in pairs(Tbl) do
		if type(v) == 'table' then
			t[k] = table.copy(v)
		else
			t[k] = v
		end
	end
	return t
end

return _M