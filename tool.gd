extends Node

onready var validex = Mutex.new()

const multiClaimLimit = 8

var physicsQueue = []
var physicsIdleQueue = []

var freeque = {}
var count = {}
var freeAfterRelease = {}
var globalLock = 0

signal physicsIsIdle()

func _ready():
	pause_mode = PAUSE_MODE_PROCESS

func ov(o):
	validex.lock()
	var valid = ovnolock(o)
	validex.unlock()
	return valid
	
func multiClaimWhatYouCanAndReturnIt(nodes: Array) -> Array:
	validex.lock()
	var valid = []
	for i in nodes:
		if ovnolock(i):
			valid.append(i)
	globalLock += 1
	if globalLock > 16:
		print("Global lock leak!")
	validex.unlock()
	return valid
	
func multiReleaseGlobal():
	validex.lock()
	globalLock -= 1
	if globalLock < 0:
		print("Global lock leak!")
	if globalLock == 0:
		for h in freeAfterRelease:
			var node = freeAfterRelease[h]
			freeque[h] = node
		freeAfterRelease.clear()
	validex.unlock()
		
func multiClaim(nodes: Array) -> bool:
	validex.lock()
	if nodes.size() >= multiClaimLimit:
		for i in nodes:
			if not ovnolock(i):
				validex.unlock()
				return false
		globalLock += 1
		if globalLock > 16:
			print("Global lock leak!")
		validex.unlock()
		return true
	else:
		var claimed = []
		for node in nodes:
			if claim(node):
				claimed.append(node)
			else:
				break
		if claimed.size() == nodes.size():
			validex.unlock()
			return true
		multiRelease(claimed)
	validex.unlock()
	return false
		
func multiRelease(nodes: Array):
	validex.lock()
	if nodes.size() >= multiClaimLimit:
		multiReleaseGlobal()
	else:
		for node in nodes:
			release(node)
	validex.unlock()
	
		
func claim(node: Node) -> bool:
	if node == null:
		return false
	validex.lock()
	if ovnolock(node):
		var h = hash(node)
		if h in count:
			count[h] += 1
		else:
			count[h] = 1
		if count[h] > 16:
			if node is Node:
				print("Lock leak with node %s/%s" % [node, node.name])
			else:
				print("Lock leak with non-node %s" % [node])
		validex.unlock()
		return true
	else:
		validex.unlock()
		return false
		
func claimCount(node: Node):
	var h = hash(node)
	return count.get(h, 0)
	
func release(node: Node):
	validex.lock()
	var h = hash(node)
	if h in count:
		count[h] -= 1
		if count[h] == 0:
			count.erase(h)
			if h in freeAfterRelease:
				freeAfterRelease.erase(h)
				freeque[h] = node
	else:
		print("Trying to release unlocked node %s" % [node])
	validex.unlock()
		
func ovnolock(o):
	return is_instance_valid(o) and not (hash(o) in freeque) and not o.is_queued_for_deletion() and not freeque.has(o)
	
func objectValid(o):
	return ov(o) and o is Object and o.is_inside_tree()
		
func disableProcess(on: Node):
	on.set_physics_process(false)
	on.set_process(false)
	for c in on.get_children():
		disableProcess(c)

func remove(o: Node):
	validex.lock()
	if ovnolock(o):
		if o.has_signal("removal"):
			o.emit_signal("removal")
	if globalLock > 0:
		var h = hash(o)
		freeAfterRelease[h] = o
	else:
		if ovnolock(o):
			var h = hash(o)
			if count.get(h, 0) <= 0 and claim(o):
				freeAfterRelease[h] = o
				release(o)
			else:
				freeAfterRelease[h] = o
	validex.unlock()

var overdrawTime = 0
export (float, 0, 1, 0.1) var physicsIdleTarget = 0.5
func _physics_process(delta):
	var start = OS.get_ticks_usec()
	var idleTime = floor((1000000.0 * physicsIdleTarget) / float(Settings.getFps()))
	var idleLimit = start + idleTime - overdrawTime
	var idleEnd = start + idleTime
	var idleNotify = start + (idleTime - overdrawTime) / 2
	didStuffThisFrame = 0
	if not freeque.empty():
		validex.lock()
		for h in freeque:
			var s = freeque[h]
			if is_instance_valid(s):
				if not s.is_queued_for_deletion():
					s.queue_free()

		freeque.clear()
		validex.unlock()
		
	var atLeastOneIdle = true
	while physicsQueue.size() > 0:
		var call = physicsQueue.pop_front()
		if ov(call[0]):
			var xstart = OS.get_ticks_msec()
			call[0].callv(call[1], call[2])
			var xtook = OS.get_ticks_msec() - xstart
			if xtook > 100:
				print("Long execution %0f ms of %s(%s).%s(%s)" % [xtook, call[0], call[0].get_path(), call[1], call[2]])
			atLeastOneIdle = false
		else:
			print("Call on invalid object: %s(%s)" % [call[1], call[2]])
			
	if physicsIdleQueue:
		while OS.get_ticks_usec() < idleLimit or atLeastOneIdle:
			atLeastOneIdle = false
			var call = physicsIdleQueue.pop_front()
			if call:
				if ov(call[0]):
					call[0].callv(call[1], call[2])
					if call[0] is Node2D and not call[0].is_visible_in_tree():
						idleLimit = idleNotify
				else:
					print("Call [idle] on invalid object: %s(%s)" % [call[1], call[2]])
			else:
				break
		overdrawTime = max(0, OS.get_ticks_usec() - idleEnd)
		if OS.get_ticks_usec() < idleNotify:
			emit_signal("physicsIsIdle")
	else:
		overdrawTime = 0
		emit_signal("physicsIsIdle")
			
func angularDistance(drot, rot):
	return Vector2(0, 1).rotated(rot).angle_to(Vector2(0, 1).rotated(drot))

func makeTimer(time, where):
	if where is Node:
		
		var timer = Timer.new()
		timer.wait_time = time
		deferCallInPhysics(where, "add_child", [timer])
		timer.connect("timeout", self, "remove", [timer])
		timer.autostart = true
		return timer
	else:
		return get_tree().create_timer(time)

func readableTimeSpan(seconds: float, skipZero = false):
	if seconds < 60:
		return "%ds" % seconds
	if seconds < 3600:
		if skipZero and int(seconds) % 60 == 0:
			return "%dm" % [seconds / 60]
		return "%dm:%ds" % [seconds / 60, int(seconds) % 60]
	if seconds < 3600 * 24:
		if skipZero and int(seconds / 60) % 60 == 0:
			return "%dh" % [seconds / 3600]
		return "%dh:%dm" % [seconds / 3600, int(seconds / 60) % 60]
	
	if skipZero and int(seconds / 3600) % 24 == 0:
		return "%dd" % [seconds / (24 * 3600)]
	return "%dd %dh" % [seconds / (24 * 3600), int(seconds / 3600) % 24]
	
func deferCallInPhysics(callOn: Object, method: String, params: Array = []):
	physicsQueue.append([callOn, method, params])

func deferCallWhenIdle(callOn: Object, method: String, params: Array = [], once = false):
	var call = [callOn, method, params]
	if not once or not physicsIdleQueue.has(call):
		physicsIdleQueue.append(call)
	
var didStuffThisFrame = 0
export var perFrameTickLimit = 1

func claimTimeToDoThings():
	if didStuffThisFrame >= perFrameTickLimit:
		return false
	else:
		didStuffThisFrame += 1
		return true

func accelerationCurve(p: float) -> float:
	if p < 0:
		return 0.0
	if p > 1:
		return 1.0
	if p < 0.5:
		return pow(p * 2, 2) / 2
	return - 2 * pow(p, 2) + 4 * p - 1

signal unique(node)
func signalUnique(node):
	emit_signal("unique", node)

func globalMousePositionFor(item: CanvasItem) -> Vector2:
	var viewport = item.get_viewport()
	if "mouseProxyNode" in viewport and viewport.mouseProxyNode:
		var localMousePosition = viewport.mouseProxyNode.get_local_mouse_position()
		var transform = item.get_canvas_transform().affine_inverse()
		var globalMousePosition = transform.xform(localMousePosition)
		return globalMousePosition
	else:
		return item.get_global_mouse_position()
	
