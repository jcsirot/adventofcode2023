module day3

import encoding.utf8 { is_number }
import math { min, max }

pub fn solve(data string) {
	engine, parts := read_schematic(data)
	println('part 1: ${part_1(engine, parts)}')
	println('part 2: ${part_2(engine, parts)}')
}

struct Part {
	x_start int
	x_end int
	row int
	value int
}

fn read_schematic(data string) ([][]string, []Part) {
	mut engine := [][]string{}
	lines := data.split_into_lines()
	for line in lines {
		engine << line.split('')
	}
	mut parts := []Part{} 
	for y, row in engine {
		add_parts(row, y, mut &parts)
	}
	return engine, parts
}

fn part_1(engine [][]string, parts []Part) int {
	mut sum := 0
	for part in parts {
		sum += if is_engine_part(part, engine) { part.value } else { 0 }
	}
	return sum
}

fn part_2(engine [][]string, parts []Part) int {
	mut sum := 0
	for y, row in engine {
		for x, str in row {
			if str == '*' {
				sum += get_gear_ratio(x, y, parts)
			}
		}
	}
	return sum
}

fn add_parts(row []string, y int, mut parts []Part) {
	mut x_start := -1
	mut value := 0
	for x, c in row {
		if is_number(c[0]) {
			value = 10 * value + c.int()
			if x_start == -1 {
				x_start = x
			}
		} else if x_start != -1 {
			parts << Part{x_start, x-1, y, value}
			value = 0
			x_start = -1
		}
	}
	if x_start != -1 {
		parts << Part{x_start, row.len-1, y, value}
	}
}

fn is_engine_part(part Part, engine [][]string) bool {
	y_max := engine.len - 1
	x_max := engine[0].len - 1
	for x := max(part.x_start - 1, 0) ; x <= min(part.x_end + 1, x_max); x++ {
		for y := max(part.row - 1, 0) ; y <= min(part.row + 1, y_max); y++ {
			if engine[y][x] != '.' && !is_number(engine[y][x][0]) {
				return true
			}
		}
	}
	return false
}

fn get_gear_ratio(x int, y int, parts []Part) int {
	mut adjacent_parts := []Part{}
	for part in parts {
		if x >= part.x_start-1 && x <= part.x_end + 1 && y >= part.row - 1 && y <= part.row + 1 {
			adjacent_parts << part
		}
	}
	// println('${x},${y} : ${adjacent_parts}')
	return if adjacent_parts.len == 2 { adjacent_parts[0].value * adjacent_parts[1].value } else { 0 }
}
