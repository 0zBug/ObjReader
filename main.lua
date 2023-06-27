
local PngReader = loadstring(game:HttpGet("https://raw.github.com/0zBug/PngReader/main/main.lua"))()
local MtlReader = loadstring(game:HttpGet("https://raw.github.com/0zBug/MtlReader/main/main.lua"))()

local function SplitData(Data)
	return table.unpack(string.split(string.gsub(string.gsub(Data, "%a+%s+", ""), "%s+", " "), " "))
end

local function VertexData(Face)
	local Index, Coordinate = unpack(string.split(Face, "/"))

	return tonumber(Index), tonumber(Coordinate)
end

return function(File)
	local Objects = {}
	local Materials = {}
	local Material
	
	local function AddObject(Name)
		table.insert(Objects, {
			Name = Name,
			Verticies = {},
			Triangles = {},
			Coordinates = {}
		})
	end
	
	local Match = {
		["mtllib%s+(.+)\.mtl"] = function(File)
			for Material, File in next, MtlReader(File .. ".mtl") do
				Materials[Material] = PngReader.new(readfile(File))
			end
		end,
		["usemtl%s+%w+"] = function(usemtl) 
			Material = string.gsub(usemtl, "usemtl%s+", "")
		end,
		["v%s+[\-\.%d]+%s+[\-\.%d]+%s+[\-\.%d]+"] = function(Vertex) 
			table.insert(Objects[#Objects].Verticies, {SplitData(Vertex)})
		end,
		["vt%s+[\-\./%d]+%s+[\-\./%d]+"] = function(Coordinates) 
			table.insert(Objects[#Objects].Coordinates, {SplitData(Coordinates)})
		end,
		["f%s+[\-/%d]+%s+[\-/%d]+%s+[\-/%d]+"] = function(Face)
			local a, b, c = SplitData(Face)
			
			local a, at = VertexData(a)
			local b, bt = VertexData(b)
			local c, ct = VertexData(c)
			
			table.insert(Objects[#Objects].Triangles, {a, b, c, at, bt, ct, Materials[Material]})
		end,
		["object%s+(.+)"] = AddObject,
		["o%s+(.+)"] = AddObject,
		["g%s+(.+)"] = AddObject
	}
	
	for _, Line in next, string.split(readfile(File .. ".obj"), "\n") do
		for Match, Callback in next, Match do
			local Matched = string.match(Line, Match)
			if Matched then
				Callback(Matched)
			end
		end
	end
	
	local function Rotate(rx, ry)
		local cx, sx = math.cos(rx), math.sin(rx)
		local cy, sy = math.cos(ry), math.sin(ry)
		
		for _, Object in next, Objects do
			for _, v in next, Object.Verticies do
				local x, y, z = v[1], v[2], v[3]
				v[1], v[2], v[3] = x * cx - z * sx, y * cy - x * sx * sy - z * cx * sy, x * sx * cy + y * sy + z * cx * cy
			end
		end
	end
	
	local function Scale(x, y, z)
		for _, Object in next, Objects do
			for _, v in next, Object.Verticies do
				v[1], v[2], v[3] = v[1] * x, v[2] * y, v[3] * z
			end
		end
	end
	
	local function Translate(x, y, z)
		for _, Object in next, Objects do
			for _, v in next, Object.Verticies do
				v[1], v[2], v[3] = v[1] + x, v[2] + y, v[3] + z
			end
		end
	end
	
	return {
		Objects = Object,
		Rotate = Rotate,
		Scale = Scale,
		Translate = Translate
	}
end
