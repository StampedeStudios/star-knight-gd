@tool
extends EditorScript

## Execute test suite composed by every test under folder [code]res://tests[/code]
var tests = [
    preload ("res://tests/test_game_manager.gd"),
]

func _run():
    print("Running %s tests..." % [tests.size()])
    var overall_outcome: bool = false
    var test_index: int = 0
    for test_case in tests:
        var instance = test_case.new()
        overall_outcome = instance.run()
        if (overall_outcome):
            print("Test %d - %s -> ✓" % [test_index, test_case.name()])
        else:
            push_error("Test %d %s -> ✕" % [test_index, test_case.name()])
        test_index += 1

    if overall_outcome:
        print("All %s tests completed" % [tests.size()])
    else:
        push_warning("Some tests have failed")