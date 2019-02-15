_GetSpaceNum = 	{
		"\t",
		"\t\t",
		"\t\t\t",
		"\t\t\t\t",
		"\t\t\t\t\t",
		"\t\t\t\t\t\t",
		"\t\t\t\t\t\t\t",
		"\t\t\t\t\t\t\t\t",
		"\t\t\t\t\t\t\t\t\t",
		"\t\t\t\t\t\t\t\t\t\t",
		"\t\t\t\t\t\t\t\t\t\t\t",
	}
function _SpaceNumRep(SpaceNum,Num)
	if SpaceNum[Num] then
		return SpaceNum[Num]
	end
	return Num == 0 and '' or string.rep('\t',Num)
end

function Print(...)
	local SpaceNum=_GetSpaceNum
	local Num=0
	local format=string.format
	local arg={...}
	local tbl={}
	local function printTable(t,Num)
		Num=Num+1
		local tbl={}
		for k,v in pairs(t) do
			local _type=type(v)
			local _Space=_SpaceNumRep(SpaceNum,Num)
				if _type=="table" and (v._type=="point" or v._type=="multiPoint") then
					tbl[#tbl+1]=format("%s[%s] = %s",_Space,tostring(k),(_printcustomData_(v._type))(v,_SpaceNumRep(SpaceNum,Num+1)))
				elseif _type=="table" and k~="_G" and(not v.package) then
					tbl[#tbl+1]=format("%s[%s](tbl)={ \n %s %s }",_Space,tostring(k),printTable(v,Num),_SpaceNumRep(SpaceNum,Num))
				elseif _type=="table" and (v.package) then
					tbl[#tbl+1]=format("%s[%s](%s) = %s",_Space,tostring(k),_type,v)
				elseif _type=="boolean" then
					tbl[#tbl+1]=format("%s[%s](bool) = %s",_Space,tostring(k),(v and "true" or "false"))
				else
					tbl[#tbl+1]=format("%s[%s](%s) = %s",_Space,tostring(k),string.sub(_type,1,3),v)
				end
			tbl[#tbl+1]="\n"
		end
		return table.concat(tbl)
	end
	for i=1,#arg do
		local t=arg[i]
		local _type=type(t)
		if _type=="table" then
			if (t._type=="point" or t._type=="multiPoint") then
				tbl[#tbl+1]=format("%s",(_printcustomData_(t._type))(t))
			else
				tbl[#tbl+1]=format("\n Table = { \n %s }",printTable(t,Num)) 
			end
		elseif _type=="string" then
			tbl[#tbl+1]=format("%s",(t=="" and "empty_s"  or t))
		elseif _type=="boolean" then
			tbl[#tbl+1]=format("%s",(t and "true" or "false"))
		elseif _type=="nil" then
			tbl[#tbl+1]=format("%s","nil")
		else
			tbl[#tbl+1]=format("%s",t)
		end
		tbl[#tbl+1]=","
	end
	tbl[#tbl]=""
	print(table.concat(tbl))
end

