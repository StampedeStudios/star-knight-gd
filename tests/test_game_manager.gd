extends UnitTest

var game_manager: PackedScene = preload ("res://scenes/GameManager.tscn")

static func name() -> StringName:
    return "Game Manager Test"

func run() -> bool:
    var outcome: bool = instantiated_game_manager_should_have_ui_child()
    # TODO: Add more tests
    return outcome

func instantiated_game_manager_should_have_ui_child() -> bool:
    var gm_instance: Node = game_manager.instantiate()
    assert_not_null(gm_instance, "Game manager should have been instantiated")

    const expected_num_children: int = 1
    var result: bool = assert_equals(expected_num_children, gm_instance.get_child_count(), "A UI scene object should have been found as GM child")

    var ui_instance: Control = gm_instance.get_child(0) as Control
    result = result and assert_not_null(ui_instance, "User Interface Control should have been instantiated")
    var num_ui_children: int = ui_instance.get_child_count()
    result = result and assert_equals(2, num_ui_children, "Exactly two children should have been present as children of User Interface")

    var menu: CanvasLayer = ui_instance.get_child(0)
    result = assert_not_null(menu, "Menu CanvasLayer should have been instantiated")
    var how_to_play_section: CanvasLayer = ui_instance.get_child(1)
    result = result and assert_not_null(how_to_play_section, "How To Play CanvasLayer should have been instantiated")

    # if (ui_instance.has_method("_pop_menu")):
    #     print("Calling pop_menu method on %s" % [ui_instance])
    #     ui_instance._pop_menu()

    return result