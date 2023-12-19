module day18

import math
import strconv

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) i64 {
	points := parse_data(data)
	return compute_area(points)
}

fn part_2(data string) i64 {
	points := parse_data_part_2(data)
	return compute_area(points)
}

fn compute_area(points []Point) i64 {
	/* Use Gauss formula and Pick Theorem */
	mut area1 := i64(0)
	mut border_len := i64(0)
	for i := 0; i < points.len-1; i++ {
		area1 += points[i].col * points[i+1].row
		border_len += math.abs(points[i].row - points[i+1].row) + math.abs(points[i].col - points[i+1].col)
	}
	area1 += points[points.len - 1].col * points[0].row
	border_len += math.abs(points[points.len - 1].row - points[0].row) + math.abs(points[points.len - 1].col - points[0].col)
	mut area2 := i64(0)
	for i := 0; i < points.len-1; i++ {
		area2 += points[i].row * points[i+1].col
	}
	area2 += points[points.len - 1].row * points[0].col

	return math.abs(area1 - area2) / 2 + border_len / 2 + 1
} 

struct Point {
	row i64
	col i64
}

fn parse_data(data string) []Point {
	lines := data.split_into_lines()
	mut points := []Point{}
	mut cur_row := 0
	mut cur_col := 0
	for line in lines {
		elts := line.split(' ')
		dir := elts[0]
		steps := elts[1].int()
		match dir {
			'U' { cur_row -= steps }
			'D' { cur_row += steps }
			'R' { cur_col += steps }
			'L' { cur_col -= steps }
			else {}
		}
		points << Point{cur_row, cur_col}
	}
	return points
}


fn parse_data_part_2(data string) []Point {
	lines := data.split_into_lines()
	mut points := []Point{}
	mut cur_row := 0
	mut cur_col := 0
	for line in lines {
		code := line.split(' ')[2][2..8]
		steps := int(strconv.parse_int(code[0..5], 16, 32) or { panic(err) })
		match code[5..6] {
			'3' { cur_row -= steps } // U
			'1' { cur_row += steps } // D
			'0' { cur_col += steps } // R
			'2' { cur_col -= steps } // L
			else {}
		}
		points << Point{cur_row, cur_col}
	}
	return points
}
