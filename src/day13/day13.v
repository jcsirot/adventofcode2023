module day13

import math

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	patterns := parse_data(data)
	return compute_axis_summary(patterns, is_symmetrical)
}

fn part_2(data string) int {
	patterns := parse_data(data)
	return compute_axis_summary(patterns, is_almost_symmetrical)
}

fn compute_axis_summary(patterns []Pattern, cmp fn ([]int) bool) int {
	mut h_sum := 0
	mut v_sum := 0
	for pattern in patterns {
		// search for horizontal line
		h1, h2 := find_axis(pattern.p1, cmp)
		if h1 != 0 || h2 != 0 {
			h_x := ((h2 - h1 + 1) / 2) + h1
			// println('h_axis: ${h1}-${h2} => ${h_x}')
			h_sum += h_x
		}
		// search for vertical line
		v1, v2 := find_axis(pattern.p2, cmp)
		if v1 != 0 || v2 != 0 {
			v_x := ((v2 - v1 + 1) / 2) + v1
			// println('v_axis: ${v1}-${v2} => ${v_x}')
			v_sum += v_x
		}
	}
	return 100 * h_sum + v_sum
}

fn find_axis(m []int, cmp fn ([]int) bool) (int, int) {
	for i := 2; i < m.len; i+=2 {
		if cmp(m[0..i]) {
			return 0, i-1
		}
	}
	for i := 2; i < m.len ; i+=2 {
		if cmp(m[m.len-i..m.len]) {
			return m.len-i, m.len
		}
	}
	return 0, 0
}

fn find_axis_with_smudge(m []int) (int, int) {
	for i := 2; i < m.len; i+=2 {
		if is_almost_symmetrical(m[0..i]) {
			return 0, i-1
		}
	}
	for i := 2; i < m.len ; i+=2 {
		if is_almost_symmetrical(m[m.len-i..m.len]) {
			return m.len-i, m.len
		}
	}
	return 0, 0
}

fn is_symmetrical(array []int) bool {
	return array == array.reverse()
}

const pow_2 = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 536870912, 1073741824]

fn is_almost_symmetrical(array []int) bool {
	mut diff := []int{}
	for i := 0; i < array.len; i++ {
		diff << array[i] ^ array[array.len-i-1]
	}
	x := diff[0..diff.len/2].filter(it != 0)
	// println('diff=${diff}, x=${x}')
	return x.len == 1 && pow_2.contains(math.abs(x[0]))
}

struct Pattern {
	p1 []int
	p2 []int
}

fn parse_data(data string) []Pattern {
	lines := data.split_into_lines()
	mut patterns := []Pattern{}
	mut matrix := [][]bool{}

	for line in lines {
		if line == '' {
			patterns << matrix_to_pattern(matrix)
			matrix = [][]bool{}
		} else {
			mut row := []bool{}
			for c in line {
				row << (c == `#`)
			}
			matrix << row
		}
	}
	patterns << matrix_to_pattern(matrix)
	return patterns
}

/* transform the pattern into 2 lists of integers */
fn matrix_to_pattern(matrix [][]bool) Pattern {
	mut line := 0
	mut a1 := []int{}
	for r := 0 ; r < matrix.len; r++ {
		for c := 0 ; c < matrix[r].len; c++ {
			line = (line * 2) | (if matrix[r][c] { 1 } else { 0 })
		}
		a1 << line
		line = 0
	}

	mut a2 := []int{}
	for c := 0 ; c < matrix[0].len ; c++ {
		for r := 0 ; r < matrix.len ; r++ {
			line = (line * 2) | (if matrix[r][c] { 1 } else { 0 })
		}
		a2 << line
		line = 0
	}

	return Pattern{a1, a2}
}
