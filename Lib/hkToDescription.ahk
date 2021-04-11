; *********************************** hkToDescription.ahk ******************************
; TODO

hkToDescription(c) {
	s := c
	if (c == "^") {
		s := "[CTRL]"
	}
	if (c == "!") {
		s := "[ALT]"
	}
	if (c == "#") {
		s := "[WIN]"
	}
	if (c == "+") {
		s := "[SHIFT]"
	}
	if (c == "o") {
		s := "o"
	}
	if (c == ">") {
		s := "Right"
	}
	if (c == "<") {
		s := "Left"
	}
	return s
}

