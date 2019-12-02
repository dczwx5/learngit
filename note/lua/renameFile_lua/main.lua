require("lfs")

local processDir = 'E:/code/framework/src/a_core'
local replaceStr = '.as';
local newStr = '.ts';


-- [[
function loopDir(path, loopFunc)
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path.. '/' ..file
			local attr = lfs.attributes (f)
			if attr.mode == "directory" then
				loopDir(f, loopFunc)
			else
				loopFunc(f);
			end
		end
	end
end
--]]

function loopFunc(f)
	local oldName = f;
	local newName = string.gsub(f, replaceStr, newStr);
	os.rename(oldName, newName);

end

loopDir(processDir, loopFunc)


os.rename('aaa.txt', 'abc.txt');

local s = 'aabbcc';
s = string.gsub(s, 'bb', 'dd');
print(s);
