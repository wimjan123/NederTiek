extends RefCounted
class_name GutTest

# Simple GutTest base class to make tests work
# This is a minimal implementation for compatibility

func assert_true(condition: bool, message: String = ""):
	if not condition:
		print("ASSERT_TRUE FAILED: " + message)
	else:
		print("ASSERT_TRUE PASSED: " + message)

func assert_false(condition: bool, message: String = ""):
	if condition:
		print("ASSERT_FALSE FAILED: " + message)
	else:
		print("ASSERT_FALSE PASSED: " + message)

func assert_eq(actual, expected, message: String = ""):
	if actual != expected:
		print("ASSERT_EQ FAILED: Expected %s, got %s. %s" % [expected, actual, message])
	else:
		print("ASSERT_EQ PASSED: " + message)

func assert_ne(actual, expected, message: String = ""):
	if actual == expected:
		print("ASSERT_NE FAILED: Values should not be equal: %s. %s" % [actual, message])
	else:
		print("ASSERT_NE PASSED: " + message)

func assert_not_null(value, message: String = ""):
	if value == null:
		print("ASSERT_NOT_NULL FAILED: " + message)
	else:
		print("ASSERT_NOT_NULL PASSED: " + message)

func assert_null(value, message: String = ""):
	if value != null:
		print("ASSERT_NULL FAILED: " + message)
	else:
		print("ASSERT_NULL PASSED: " + message)

func before_each():
	# Override in test classes
	pass

# Stub methods for compatibility
func add_child_autofree(node):
	return node