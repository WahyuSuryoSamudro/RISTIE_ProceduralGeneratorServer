extends Spatial

export var period = 80
export var octaves = 2
var noise = OpenSimplexNoise.new() # i think im going to initialize globally so later on noise object can be used for all function
export var xResGen = 1024
export var yResGen = 1024
export var terrainGenSmoothingSubdivision_depth = 640
export var terrainGenSmoothingSubdivision_width = 640

func _ready():
	randomize()
	# Lets use a predetermined seed for this experiment (what we wanted is a configuration which persist on all sessions without the needed to save the whole maps)
	noise.seed = 6969696969
	noise.period = period
	noise.octaves = octaves
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(xResGen,yResGen)
	plane_mesh.subdivide_depth = terrainGenSmoothingSubdivision_depth
	plane_mesh.subdivide_width = terrainGenSmoothingSubdivision_width
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh,0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	
	data_tool.create_from_surface(array_plane,0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_3d(vertex.x, vertex.y, vertex.z) *60
		
		data_tool.set_vertex(i,vertex)
		
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane,0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://terrainHeightLevelColouring.material"))
	
	add_child(mesh_instance)

func _process(delta):
	$RotateViewPort.rotate_y(delta*0.04)
