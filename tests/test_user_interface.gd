extends GdUnitTestSuite

var game_manager: PackedScene = preload ("res://scenes/GameManager.tscn")

func test_ui_construction() -> void:
    var gm_instance: Node = game_manager.instantiate()
    add_child(gm_instance)
    assert_object(gm_instance).is_not_null()

    const expected_num_children: int = 1
    assert_int(gm_instance.get_child_count()).is_equal(expected_num_children)

    var ui_instance: Control = gm_instance.get_child(0) as Control
    assert_object(ui_instance).is_not_null()

func test_ui_panel_handling() -> void:
    var gm_instance: Node = game_manager.instantiate()
    add_child(gm_instance)

    var ui_instance: Control = gm_instance.get_child(0) as Control
    assert_object(ui_instance).is_not_null()
    var num_ui_children: int = ui_instance.get_child_count()
    assert_int(num_ui_children).is_equal(2)

    var menu: CanvasLayer = ui_instance.get_child(0)
    assert_object(menu).is_not_null()

    var how_to_play_section: CanvasLayer = ui_instance.get_child(1)
    assert_object(how_to_play_section).is_not_null()

    # Popping Menu should hide other sections
    ui_instance._pop_menu()
    assert_bool(menu.visible).is_true()
    assert_bool(how_to_play_section.visible).is_false()

    # Popping How To Play Section should hide menu
    ui_instance._pop_how_to_play()
    assert_bool(how_to_play_section.visible).is_true()
    assert_bool(menu.visible).is_false()

    ui_instance.hide_all()
    assert_bool(how_to_play_section.visible).is_false()
    assert_bool(menu.visible).is_false()
