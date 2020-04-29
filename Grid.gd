extends Node2D

onready var start_x = 200
onready var start_y = 20
onready var grid_size_x = 40
onready var grid_size_y = 30
onready var cell_length_in_pixel = 16
onready var matrix_of_cells
onready var number_of_generations = 0
onready var running = false
onready var timer = Timer.new()

var time = 0
var time_offset = 1
var time_to_render = 0
var epsilon = 0.1

var eight_neighbor_cell_transformation = [
	[-1, 0],
	[-1, -1],
	[0, -1],
	[1, -1],
	[1, 0],
	[1, 1],
	[0, 1],
	[-1, 1]
]
var three_neighbor_cell_transformation = [
	[1, 0],
	[1, 1],
	[0, 1]
]

var five_neighbor_cell_tranformation = [
	[-1, 0],
	[-1, 1],
	[0, 1],
	[1, 1],
	[1, 0]
]

func _ready():
	matrix_of_cells = make_grid(start_x, start_y, grid_size_x, grid_size_y, cell_length_in_pixel)

func _process(delta):
	if running:
		time += delta
		if abs(time-time_to_render) <= epsilon:
			run_simulation()
			time_to_render += time_offset
	
func make_grid(x, y, grid_size_x,grid_size_y, width_in_pixel):
	
	var matrix = []
	var cell_scene = load("res://Cell.tscn")
	for i in range(grid_size_x):
		matrix.append([])
		for j in range(grid_size_y):
			var cell = cell_scene.instance()
			cell.move_local_x(width_in_pixel*i + x)
			cell.move_local_y(width_in_pixel*j + y)
			matrix[i].append(cell)
			add_child(cell)
	
	return matrix
		

func start_game():
	time = 0
	time_to_render = 0
	running = true
	print ("Game Of Life: Starting Game.")
	run_simulation()
	
	# start simulation for all cells
	
func stop_game():
	running = false
	print ("Game Of Life: Stopping Game")

func clear():
	
	print ("Game Of Life: Clearing Game")
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var cell = matrix_of_cells[i][j]
			cell.kill()

func run_simulation():
	
	var new_world = []
	for i in range(grid_size_x):
		var new_generation = []
		for j in range(grid_size_y):
			var cell = matrix_of_cells[i][j]
			var number_of_live_neighbors = get_number_of_live_neighbors(i, j, matrix_of_cells, grid_size_x, grid_size_y)
			var give_new_life = game_of_life(cell, number_of_live_neighbors)
			new_generation.append(give_new_life)
		new_world.append(new_generation)
	
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var cell = matrix_of_cells[i][j]
			var give_new_life = new_world[i][j]
			if give_new_life:
				cell.alive()
			else:
				cell.kill()
	

func game_of_life(cell, live_neighbors):
	
	if cell.alive:
		
		if live_neighbors <= 1 or live_neighbors >= 4:
			return false
		return true
		
	else:
		
		if live_neighbors == 3:
			return true
	
	return false
	

# gives the number of live cells given a i,j and a 2D cell matrix
func get_number_of_live_neighbors(i, j, cell_matrix, grid_size_x, grid_size_y):

	var alive_neighbors = 0
	var last_index_x = grid_size_x - 1
	var last_index_y = grid_size_y - 1
	var transformation_matrix = get_transformation(i, j, last_index_x, last_index_y)
	var live_neighbors = 0
	
	for transformation in transformation_matrix:
		var x = i+transformation[0]
		var y = j+transformation[1]
		var cell = cell_matrix[x][y]
		if cell.alive:
			live_neighbors += 1
	return live_neighbors
	

func get_transformation(i, j, last_index_x, last_index_y):
	
	# this is probably too long. TODO: make it more readable
	if i > 0 and j > 0 and i < last_index_x and j < last_index_y:
		return eight_neighbor_cell_transformation
	elif j == 0 and i == 0:
		return three_neighbor_cell_transformation
	elif j == 0 and i == last_index_x:
		return reflect_x_axis_matrix_transformation(three_neighbor_cell_transformation)
	elif j == last_index_y and i == 0:
		var transformation_matrix = reflect_x_axis_matrix_transformation(three_neighbor_cell_transformation)
		return swap_x_and_y(transformation_matrix)
	elif j == last_index_y and i == last_index_x:
		# probably a better way to this
		var transformation_matrix = reflect_x_axis_matrix_transformation(three_neighbor_cell_transformation)
		transformation_matrix = swap_x_and_y(transformation_matrix)
		return reflect_x_axis_matrix_transformation(transformation_matrix)
	elif i > 0 and j == 0:
		return five_neighbor_cell_tranformation
	elif i > 0 and j == last_index_y:
		var transformation_matrix = rotate_matrix(five_neighbor_cell_tranformation, PI)
		return reflect_x_axis_matrix_transformation(transformation_matrix)
	elif j > 0 and i == 0:
		var transformation_matrix = rotate_matrix(five_neighbor_cell_tranformation, PI/2)
		transformation_matrix = reflect_x_axis_matrix_transformation(transformation_matrix)
		return reflect_y_axis_matrix_transformation(transformation_matrix)
	elif j > 0 and i == last_index_x:
		return rotate_matrix(five_neighbor_cell_tranformation, PI/2)
	
	return []
			
func reflect_x_axis_matrix_transformation(matrix_trasnformation):
	var reflected_x_axis_matrix = []
	for trans in matrix_trasnformation:
		var reflected = [-1 * trans[0], trans[1]]
		reflected_x_axis_matrix.append(reflected)
	return reflected_x_axis_matrix
	
func reflect_y_axis_matrix_transformation(matrix_trasnformation):
	var reflected_y_axis_matrix = []
	for trans in matrix_trasnformation:
		var reflected = [trans[0], -1 * trans[1]]
		reflected_y_axis_matrix.append(reflected)
	return reflected_y_axis_matrix

func swap_x_and_y(matrix_transformation):
	var swapped_matrix = []
	for trans in matrix_transformation:
		var swapped = [trans[1], trans[0]]
		swapped_matrix.append(swapped)
	return swapped_matrix

func rotate_matrix(matrix, angle):
	var rotated_matrix = []
	for point in matrix:
		var rotated_point = rotate_point(point, angle)
		rotated_matrix.append(rotated_point)
	return rotated_matrix
	
func rotate_point(point, angle_in_radians):
	var x = point[0]*int(cos(angle_in_radians)) - point[1]*int(sin(angle_in_radians))
	var y = point[0]*int(sin(angle_in_radians)) + point[1]*int(cos(angle_in_radians))
	return [x,y]
			
