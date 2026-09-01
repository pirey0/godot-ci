extends SceneTree

func _init():
	print("RENDERER_CHECK: video_adapter_name=", RenderingServer.get_video_adapter_name())
	print("RENDERER_CHECK: video_adapter_vendor=", RenderingServer.get_video_adapter_vendor())
	print("RENDERER_CHECK: video_adapter_type=", RenderingServer.get_video_adapter_type())
	print("RENDERER_CHECK: rendering_device_present=", RenderingServer.get_rendering_device() != null)
	quit()
