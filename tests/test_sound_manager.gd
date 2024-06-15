extends GdUnitTestSuite

var sound_manager: PackedScene = preload ("res://scenes/SoundManager.tscn")

func test_sound_effects_handling():
    var sm_instance: Node = sound_manager.instantiate()
    add_child(sm_instance)
    assert_object(sm_instance).is_not_null()

    sm_instance.sfx_pool_size = 1
    var audio_plyer: AudioStreamPlayer = sm_instance._get_available_sfx_player()
    assert_object(audio_plyer).is_not_null()
