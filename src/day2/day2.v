module day2

import math
import regex

type Accumulator = fn (int, int, int, int) int

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${execute_part(data, part_1_accumulator)}')
	println('part 2: ${execute_part(data, part_2_accumulator)}')
}

fn part_1_accumulator(index int, r int, g int, b int) int {
	return if r <= 12 && g <= 13 && b <= 14 { index } else { 0 }
}

fn part_2_accumulator(_ int, r int, g int, b int) int {
	return r * g * b
}

fn execute_part(data string, acc Accumulator) int {
	mut sum := 0 
	lines := data.split_into_lines()
	for i, line in lines {
		mut min_r := 0
		mut min_g := 0
		mut min_b := 0
		draws := line.split_any(':;')
		for draw in draws[1..] {
			r, g, b := get_draw_constraints(draw)
			min_r = math.max(min_r, r)
			min_g = math.max(min_g, g)
			min_b = math.max(min_b, b)
		}
		// println('${min_r}, ${min_g}, ${min_b}')
		sum += acc(i + 1, min_r, min_g, min_b)
	}
	return sum
}

fn get_draw_constraints(draw string) (int, int, int) {
	mut r := 0
	mut g := 0
	mut b := 0
	mut re := regex.regex_opt(r'[0-9]+|(red)|(green)|(blue)') or { panic(err) }
	parts := re.find_all_str(draw)
	for i := 1; i < parts.len; i+=2 {
		count := parts[i-1].int()
		if parts[i].contains('red') {
			r += count
		} else if parts[i].contains('blue') {
			b += count
		} else if parts[i].contains('green') {
			g += count
		}
	}
	return r, g, b
}

