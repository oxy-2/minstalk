extends Node
## walkable grid around map collision (static polygon / tiles).
## autoload singleton "navgrid". enemies call find_path / is_los_blocked.

var cellsize := 32.0

var _grid: AStarGrid2D
var _built := false
var _origin := Vector2(-1000, -1000)
var _cells := Vector2i(160, 70)

func ensure_ready(host: Node = null) -> void:
	if _built:
		return
	var who = host if host != null else self
	if who.get_world_2d() == null:
		return
	_build(who)

func find_path(from: Vector2, to: Vector2, host: Node = null) -> PackedVector2Array:
	ensure_ready(host)
	var out := PackedVector2Array()
	if _grid == null:
		return out
	var a = _snap_open(_world_to_cell(from))
	var b = _snap_open(_world_to_cell(to))
	if a == null or b == null:
		return out
	var ids = _grid.get_id_path(a, b, true)
	for i in range(ids.size()):
		out.append(_cell_to_world(ids[i]))
	return out

func is_los_blocked(from: Vector2, to: Vector2, exclude: Array, host: Node = null) -> bool:
	ensure_ready(host)
	var who = host if host != null else self
	var world = who.get_world_2d()
	if world == null:
		return false
	var q = PhysicsRayQueryParameters2D.create(from, to)
	q.exclude = exclude
	q.collide_with_areas = false
	q.collide_with_bodies = true
	var hit = world.direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return false
	var col = hit.get("collider")
	if col is CharacterBody2D:
		return false
	return true

func _build(host: Node) -> void:
	var c0 = _world_to_cell(_origin)
	var c1 = c0 + _cells - Vector2i.ONE
	_grid = AStarGrid2D.new()
	_grid.region = Rect2i(c0, _cells)
	_grid.cell_size = Vector2(cellsize, cellsize)
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_grid.update()

	var space = host.get_world_2d().direct_space_state
	var blocked := 0
	for y in range(c0.y, c1.y + 1):
		for x in range(c0.x, c1.x + 1):
			var cell = Vector2i(x, y)
			if _cell_blocked(space, cell):
				_grid.set_point_solid(cell, true)
				blocked += 1
	_built = true
	print("navgrid built, blocked=", blocked, "/", _cells.x * _cells.y)

func _cell_blocked(space: PhysicsDirectSpaceState2D, cell: Vector2i) -> bool:
	var center = _cell_to_world(cell)
	var pad = cellsize * 0.32
	var samples = [
		center,
		center + Vector2(pad, 0),
		center + Vector2(-pad, 0),
		center + Vector2(0, pad),
		center + Vector2(0, -pad),
	]
	for s in samples:
		if _point_blocked(space, s):
			return true
	return false

func _point_blocked(space: PhysicsDirectSpaceState2D, pos: Vector2) -> bool:
	var q = PhysicsPointQueryParameters2D.new()
	q.position = pos
	q.collide_with_bodies = true
	q.collide_with_areas = false
	var hits = space.intersect_point(q, 8)
	for h in hits:
		var col = h.get("collider")
		if col is CharacterBody2D:
			continue
		return true
	return false

func _world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / cellsize)), int(floor(pos.y / cellsize)))

func _cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell) * cellsize + Vector2(cellsize, cellsize) * 0.5

func _snap_open(cell: Vector2i) -> Variant:
	if _grid == null:
		return null
	if _grid.is_in_boundsv(cell) and not _grid.is_point_solid(cell):
		return cell
	for r in range(1, 14):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if abs(dx) != r and abs(dy) != r:
					continue
				var n = cell + Vector2i(dx, dy)
				if _grid.is_in_boundsv(n) and not _grid.is_point_solid(n):
					return n
	return null
