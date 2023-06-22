
return function(File)
	local File = readfile(File .. ".obj")

	local function GetData(Object, Type)
	    local Data = {}
	    
	    for x, y, z in Object:gmatch(Type .. "%s+([%d%p]+)%s+([%d%p]+)%s+([%d%p]+)") do
	        table.insert(Data, {x = x, y = y, z = z})
	    end
	    
	    return Data
	end
	
	local Verticies = {}
	
	local Edges = {}
	local Triangles = {}
	
	for _, Vertex in next, GetData(File, "v") do
	    table.insert(Verticies, {Vertex.x, Vertex.y, Vertex.z})
	end
	   
	for _, Face in next, GetData(File, "f") do
		a, b, c = tonumber(Face.x), tonumber(Face.y), tonumber(Face.z)
		table.insert(Triangles, {a, b, c})
	end
	
	local function Rotate(rx, ry)
		local cx, sx = math.cos(rx),math.sin(rx)
		local cy, sy = math.cos(ry),math.sin(ry)
		
		for _, v in next, Verticies do
			local x,y,z = v[1], v[2], v[3]
			v[1], v[2], v[3] = x * cx - z * sx, y * cy - x * sx * sy - z * cx * sy, x * sx * cy + y * sy + z * cx * cy
		end
	end
	
	local function Scale(x, y, z)
		for _, v in next, Verticies do
			v[1], v[2], v[3] = v[1] * x, v[2] * y, v[3] * z
		end
	end
	
	local function Translate(x, y, z)
		for _, v in next, Verticies do
			v[1], v[2], v[3] = v[1] + x, v[2] + y, v[3] + z
		end
	end
	
	return {
		Verticies = Verticies,
		Edges = Edges,
		Triangles = Triangles,
		Rotate = Rotate,
		Scale = Scale,
		Translate = Translate
	}
end
