module day11

import math

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) u64 {
	universe := parse_data(data)
	return compute_min_distances(universe, 2)
}

fn part_2(data string) u64 {
	universe := parse_data(data)
	return compute_min_distances(universe, 1000000)
}

fn compute_min_distances(universe Universe, expansion_factor int) u64 {
	galaxies := universe.expand(expansion_factor)
	mut sum := u64(0)
	for i := 0; i < galaxies.len - 1; i++ {
		for j := i+1; j < galaxies.len; j++ {
			sum += distance(galaxies[i], galaxies[j])
		}
	}
	return sum
}

fn distance(g1 Galaxy, g2 Galaxy) u64 {
	return math.max(g1.row, g2.row) - math.min(g1.row, g2.row) + math.max(g1.col, g2.col) - math.min(g1.col, g2.col)
}

struct Galaxy {
	row u64
	col u64
}

struct Universe {
	row int
	col int
	galaxies []Galaxy
}

fn (u Universe) is_row_empty(row u64) bool {
	return u.galaxies.filter(it.row == row).len == 0
}

fn (u Universe) is_col_empty(col u64) bool {
	return u.galaxies.filter(it.col == col).len == 0
}

fn (u Universe) empty_rows() []u64 {
	mut rows := []u64{}
	for row := 0; row < u.row; row++ {
		if u.is_row_empty(u64(row)) {
			rows << u64(row)
		}
	}
	return rows
}

fn (u Universe) empty_cols() []u64 {
	mut cols := []u64{}
	for col := 0; col < u.col; col++ {
		if u.is_col_empty(u64(col)) {
			cols << u64(col)
		}
	}
	return cols
}

fn (u Universe) expand(factor int) []Galaxy {
	mut galaxies := []Galaxy{}
	empty_rows := u.empty_rows()
	empty_cols := u.empty_cols()
	for galaxy in u.galaxies {
		galaxies << Galaxy{
						galaxy.row + u64((factor - 1)  * empty_rows.filter(it < galaxy.row).len), 
						galaxy.col + u64((factor - 1) * empty_cols.filter(it < galaxy.col).len)
					}
	}
	return galaxies
}

fn parse_data(data string) Universe {
	lines := data.split_into_lines()
	row_size := lines.len
	col_size := lines[O].len
	mut galaxies := []Galaxy{}
	for row, line in lines {
		for col, c in line.split('') {
			if c == '#' {
				galaxies << Galaxy{u64(row), u64(col)}
			}
		}
	}
	return Universe{row_size, col_size, galaxies}
}
