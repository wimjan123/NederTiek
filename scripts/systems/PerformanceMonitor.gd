extends Node
class_name GamePerformanceMonitor

# PerformanceMonitor - Ensures 60 FPS and <3 sec scene loads
# Monitors performance during new game setup flow

signal performance_warning(metric: String, value: float, threshold: float)
signal performance_critical(metric: String, value: float, threshold: float)

# Performance thresholds from requirements
const TARGET_FPS = 60.0
const MIN_FPS_THRESHOLD = 45.0  # Warning threshold
const CRITICAL_FPS_THRESHOLD = 30.0  # Critical threshold
const MAX_SCENE_LOAD_TIME = 3.0  # seconds
const WARNING_SCENE_LOAD_TIME = 2.0  # seconds
const MAX_MEMORY_USAGE = 500.0  # MB
const WARNING_MEMORY_USAGE = 400.0  # MB

var scene_load_start_time: float = 0.0
var frame_times: Array[float] = []
var max_frame_samples = 120  # Track last 2 seconds at 60 FPS

var performance_data = {
	"current_fps": 0.0,
	"average_fps": 0.0,
	"min_fps": 999.0,
	"max_fps": 0.0,
	"memory_usage_mb": 0.0,
	"last_scene_load_time": 0.0,
	"frame_drops": 0,
	"warnings_count": 0,
	"critical_events": 0
}

func _ready():
	# Enable monitoring
	set_process(true)
	print("PerformanceMonitor: Monitoring started (Target: %d FPS, Scene loads: <%d sec)" % [TARGET_FPS, MAX_SCENE_LOAD_TIME])

func _process(delta):
	_update_fps_monitoring(delta)
	_update_memory_monitoring()

func _update_fps_monitoring(delta: float):
	var current_fps = 1.0 / delta if delta > 0 else 0.0

	# Add to frame time tracking
	frame_times.append(current_fps)
	if frame_times.size() > max_frame_samples:
		frame_times.pop_front()

	# Update performance data
	performance_data.current_fps = current_fps
	performance_data.min_fps = min(performance_data.min_fps, current_fps)
	performance_data.max_fps = max(performance_data.max_fps, current_fps)

	# Calculate average FPS over recent frames
	if frame_times.size() > 0:
		var total = 0.0
		for fps in frame_times:
			total += fps
		performance_data.average_fps = total / frame_times.size()

	# Check for performance issues
	if current_fps < CRITICAL_FPS_THRESHOLD:
		performance_data.critical_events += 1
		performance_critical.emit("fps", current_fps, CRITICAL_FPS_THRESHOLD)
		print("CRITICAL: FPS dropped to %.1f (threshold: %.1f)" % [current_fps, CRITICAL_FPS_THRESHOLD])
	elif current_fps < MIN_FPS_THRESHOLD:
		performance_data.warnings_count += 1
		performance_warning.emit("fps", current_fps, MIN_FPS_THRESHOLD)

	# Track frame drops (significant FPS decrease)
	if frame_times.size() > 1:
		var prev_fps = frame_times[frame_times.size() - 2]
		if prev_fps > MIN_FPS_THRESHOLD and current_fps < MIN_FPS_THRESHOLD:
			performance_data.frame_drops += 1

func _update_memory_monitoring():
	# Get memory usage (Godot 4.x API)
	var total_memory = OS.get_static_memory_usage()

	var memory_mb = total_memory / (1024.0 * 1024.0)
	performance_data.memory_usage_mb = memory_mb

	# Check memory thresholds
	if memory_mb > MAX_MEMORY_USAGE:
		performance_data.critical_events += 1
		performance_critical.emit("memory", memory_mb, MAX_MEMORY_USAGE)
		print("CRITICAL: Memory usage %.1f MB exceeds limit of %.1f MB" % [memory_mb, MAX_MEMORY_USAGE])
	elif memory_mb > WARNING_MEMORY_USAGE:
		performance_data.warnings_count += 1
		performance_warning.emit("memory", memory_mb, WARNING_MEMORY_USAGE)

func start_scene_load_timing():
	"""Call this when starting to load a new scene."""
	scene_load_start_time = Time.get_time_dict_from_system()["unix"] * 1000.0  # milliseconds

func end_scene_load_timing(scene_name: String = ""):
	"""Call this when scene loading is complete."""
	if scene_load_start_time == 0.0:
		print("Warning: end_scene_load_timing called without start_scene_load_timing")
		return

	var end_time = Time.get_time_dict_from_system()["unix"] * 1000.0
	var load_time = (end_time - scene_load_start_time) / 1000.0  # Convert to seconds
	performance_data.last_scene_load_time = load_time

	print("Scene load time for '%s': %.2f seconds" % [scene_name, load_time])

	# Check scene load performance
	if load_time > MAX_SCENE_LOAD_TIME:
		performance_data.critical_events += 1
		performance_critical.emit("scene_load", load_time, MAX_SCENE_LOAD_TIME)
		print("CRITICAL: Scene load time %.2f sec exceeds limit of %.2f sec" % [load_time, MAX_SCENE_LOAD_TIME])
	elif load_time > WARNING_SCENE_LOAD_TIME:
		performance_data.warnings_count += 1
		performance_warning.emit("scene_load", load_time, WARNING_SCENE_LOAD_TIME)

	scene_load_start_time = 0.0

func get_performance_report() -> Dictionary:
	"""Get a comprehensive performance report."""
	var report = performance_data.duplicate(true)

	# Add status assessment
	report["status"] = "good"
	if performance_data.critical_events > 0:
		report["status"] = "critical"
	elif performance_data.warnings_count > 5:  # More than 5 warnings
		report["status"] = "warning"

	# Add recommendations
	report["recommendations"] = []
	if performance_data.average_fps < TARGET_FPS:
		report["recommendations"].append("Consider reducing UI complexity or scene detail")
	if performance_data.memory_usage_mb > WARNING_MEMORY_USAGE:
		report["recommendations"].append("Monitor memory usage - approaching limits")
	if performance_data.frame_drops > 3:
		report["recommendations"].append("Multiple frame drops detected - check for performance bottlenecks")

	return report

func print_performance_summary():
	"""Print a formatted performance summary to console."""
	print("=== Performance Summary ===")
	print("FPS: Current=%.1f, Average=%.1f, Min=%.1f, Max=%.1f" % [
		performance_data.current_fps,
		performance_data.average_fps,
		performance_data.min_fps,
		performance_data.max_fps
	])
	print("Memory: %.1f MB (Limit: %.1f MB)" % [performance_data.memory_usage_mb, MAX_MEMORY_USAGE])
	print("Last Scene Load: %.2f sec (Limit: %.2f sec)" % [performance_data.last_scene_load_time, MAX_SCENE_LOAD_TIME])
	print("Issues: %d warnings, %d critical events" % [performance_data.warnings_count, performance_data.critical_events])

	var report = get_performance_report()
	if report["recommendations"].size() > 0:
		print("Recommendations:")
		for rec in report["recommendations"]:
			print("  - " + rec)

func reset_monitoring():
	"""Reset all performance counters."""
	frame_times.clear()
	performance_data = {
		"current_fps": 0.0,
		"average_fps": 0.0,
		"min_fps": 999.0,
		"max_fps": 0.0,
		"memory_usage_mb": 0.0,
		"last_scene_load_time": 0.0,
		"frame_drops": 0,
		"warnings_count": 0,
		"critical_events": 0
	}
	print("PerformanceMonitor: Counters reset")

# Static helper for easy access
static func create_monitor() -> GamePerformanceMonitor:
	var monitor = GamePerformanceMonitor.new()
	monitor.name = "PerformanceMonitor"
	return monitor

# Integration helper for NewGameFlow
func integrate_with_scene_loader(scene_loader):
	"""Connect to scene loading signals for automatic timing."""
	if scene_loader.has_signal("scene_load_started"):
		scene_loader.scene_load_started.connect(start_scene_load_timing)
	if scene_loader.has_signal("scene_load_completed"):
		scene_loader.scene_load_completed.connect(end_scene_load_timing)