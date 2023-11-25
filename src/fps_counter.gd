extends Label

@onready var viewport1 = get_node("../Cameras/SubViewport")
@onready var viewport2 = get_node("../Cameras/SubViewport")

func _ready():
	RenderingServer.viewport_set_measure_render_time(viewport1.get_viewport_rid(), true)
	RenderingServer.viewport_set_measure_render_time(viewport2.get_viewport_rid(), true)

	Clock.clock_tick.connect(_on_clock_tick);
	Clock.start_new_timer(13, 1.0);

func _process(_delta):
	var cpu_time = RenderingServer.viewport_get_measured_render_time_cpu(viewport1.get_viewport_rid()) +\
		RenderingServer.viewport_get_measured_render_time_cpu(viewport2.get_viewport_rid()) +\
		RenderingServer.get_frame_setup_time_cpu();
		
	var gpu_time = RenderingServer.viewport_get_measured_render_time_gpu(viewport1.get_viewport_rid()) +\
		RenderingServer.viewport_get_measured_render_time_gpu(viewport2.get_viewport_rid());
	
	text = "FPS:" + str(Engine.get_frames_per_second()) + " | CPU:" + "%.3f"%cpu_time + "ms | GPU:" + "%.3f"%gpu_time + "ms | Total:" + "%.3f"%(cpu_time + gpu_time) + "ms";


func _on_clock_tick(parcel: int):
	print("--- %s" % parcel);