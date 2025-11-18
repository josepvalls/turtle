extends Node2D

#spring factor, dampening factor and spread factor
#spread factor dictates how much the waves will spread to their neighboors
export var k = 0.015
export var d = 0.03
export var spread = 0.2

#the spring array
var springs = []
var passes = 12

export var distance_between_springs = 32
export var max_spring_number = 6
export var water_body_width = 512
var spring_number = 6

export var scroll_speed = 2561

#spring scene reference
onready var water_spring = $WaterLineSpringArea2D
onready var water_line = $WaterLine2D

#the body of water depth
export var depth = 1000
var target_height = position.y

#the position of the bottom of our body of water
var bottom = target_height + depth

#reference to our polygon2D
onready var water_polygon = $WaterLinePolygon2D

#reference to our water border
onready var water_border = $WaterLinePath2D
export var border_thickness = 1.1

func _ready():
	water_border.width = border_thickness	
	spread = spread / 1000
	
	var spring_number = min(max_spring_number, water_body_width / distance_between_springs)
	
	#loops through all the springs
	#makes an array with all the springs
	#initializes each spring
	for i in range(spring_number):
		#the spring x position
		#they are generated from left to right --- > 0, 32, 64, 96...
		var x_position = distance_between_springs * i
		var w = water_spring.duplicate()
		add_child(w)
		springs.append(w)
		w.initialize(x_position, i)
		w.set_collision_width(distance_between_springs)
		#connects our splash signal and calls the function splash
		w.connect("splash", self, "splash")
	water_spring.queue_free()
	
	#calculates the total lenght of the water body
	var total_lenght = distance_between_springs * (spring_number - 1)
	
	#creates a new rectangle shape 2D
	var rectangle = RectangleShape2D.new().duplicate()
	
	# area position stays right in the middle of the water body
	# the extents of the rectangle are half of the size of the water body
	var rect_position = Vector2(total_lenght / 2, depth / 2)
	var rect_extents = Vector2(total_lenght / 2, depth / 2)
	
	#sets the position and the extents of the area and the collisionshape
	#water_body_area.position = rect_position
	rectangle.set_extents(rect_extents)
	#collisionShape.set_shape(rectangle)

func _physics_process(delta):
	# scroll the springs
	for i in springs:
		i.position.x -= scroll_speed * delta * 0.1
	if springs[0].position.x < -distance_between_springs:
		springs[0].position.x += water_body_width
		springs[0].position.y = 0
		springs[0].collided_with = null
		springs.append(springs.pop_front())
	
	#moves all the springs accordingly
	for i in springs:
		i.water_update(k,d)
	
	#represents the movement of the left and right neighbor of the springs
	
	var left_deltas = []
	var right_deltas = []
	
	#initialize the values with an array of zeros
	for i in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
		pass
	
	for j in range(passes):
		#loops through each spring of our array
		for i in range(springs.size()):
			#adds velocity to the spring to the LEFT of the current spring
			if i > 0:
				left_deltas[i] = spread * (springs[i].height - springs[i-1].height)
				springs[i-1].velocity += left_deltas[i]
			#adds velocity to the spring to the RIGHT of the current spring
			if i < springs.size()-1:
				right_deltas[i] = spread * (springs[i].height - springs[i+1].height)
				springs[i+1].velocity += right_deltas[i]
	new_border()
	draw_water_body()
	

func draw_water_body():
	
	#gets the curve of the border
	var curve = water_border.curve
	
	#makes an array of the points in the curve
	var points = Array(curve.get_baked_points())
	
	#the water polygon will contain all the points of the surface
	var water_polygon_points = points
	
	#gets the first and last indexes of our surface array
	var first_index = 0
	var last_index = water_polygon_points.size()-1
	
	#add other two points at the bottom of the polygon, to close the water body
	water_polygon_points.append(Vector2(water_polygon_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(water_polygon_points[first_index].x, bottom))
	
	#transforms our normal array into a poolvector2array
	#the polygon draw function uses poolvector2arrays to draw the polygon, so we converted it
	water_polygon_points = PoolVector2Array(water_polygon_points)
	
	#sets the points of our polygon, and also our UV in the case we want to give it a texture
	water_polygon.set_polygon(water_polygon_points)
	water_polygon_points = PoolVector2Array(water_polygon_points)
	for i in len(water_polygon_points):
		water_polygon_points.set(i, water_polygon_points[i]-Vector2(springs[0].position.x, 0))
	water_polygon.set_uv(water_polygon_points)

func new_border():
	#DRAW A NEW BORDER TO THE WATER
	
	#creates a new curve 2D
	var curve = Curve2D.new().duplicate()
	
	#creates a new array, that holds the positions of the surface points!!
	#we'll use those points to draw our border
	var surface_points = []
	for i in range(springs.size()):
		surface_points.append(springs[i].position)
	
	#adds the points to the curve
	for i in range(surface_points.size()):
		curve.add_point(surface_points[i])
	
	#puts the new curve into our border, smooths it out and then update the border drawing
	water_border.curve = curve
	water_border.smooth(true)
	water_border.update()
	water_line.points = water_border.curve.get_baked_points()
	pass

#this function adds a speed to a spring with this index
func splash(spring, speed):
	spring.velocity -= speed
	$Splash.position = spring.position
	$Splash.activate(speed >= 10)
