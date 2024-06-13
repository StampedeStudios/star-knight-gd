class_name UnitTest extends Node

static func name() -> StringName:
    return "Base test"

func assert_equals(expected, actual, message: String) -> bool:
    if (expected == actual):
        return true
    else:
        push_error(message)
        return false

func assert_true(expected, message: String):
    if (expected):
        return true
    else:
        push_error(message)
        return false

func assert_false(expected, message):
    if (expected == false):
        return true
    else:
        push_error(message)
        return false

func assert_null(expected, message: String):
    if (expected == null):
        return true
    else:
        push_error(message)
        return false

func assert_not_null(expected, message: String):
    if (expected != null):
        return true
    else:
        push_error(message)
        return false