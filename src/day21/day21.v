module day21

import datatypes

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	garden, start_row, start_col := parse_data(data)
	// println(garden)
	mut points := []string{}
	points << to_str(start_row, start_col)
	for _ in 0..64 {
		points = walk(points, garden)
	}
	return points.len
}

fn part_2(data string) i64 {
	garden, start_row, start_col := parse_data(data)
	// println(garden)
	
	mut points := []string{}
	points << to_str(start_row, start_col)
	mut v := []int{}
	for i in 1..2 * garden.size + (garden.size / 2) + 1 {
		points = walk_part_2(points, garden)
		if i%131 == 65 {
			v << points.len
		}
	}

	// Build Interpolation Polynom
	// P(X) = aX^2 + bX + c
	// => a = (v[2] + v[0] - 2v[1]) / 2
	//    b = (v[2] - v[0]) / 2
	//    c = v[0]

	a := (v[2] + v[0] - 2*v[1]) / 2
	b := (v[2] - v[0]) / 2
	c := v[0]

	x := i64(26501365 / garden.size)

	return  x*x*a + x*b + c
}

fn walk(points []string, g Garden) []string {
	// println(points)
	mut new_points := map[string]bool{}
	for p in points {
		row, col := to_point(p)
		if g.is_walkable(row+1, col) && ! (to_str(row+1, col) in new_points) {
			new_points[to_str(row+1, col)] = true
		}
		if g.is_walkable(row-1, col) && ! (to_str(row-1, col) in new_points) {
			new_points[to_str(row-1, col)] = true
		}
		if g.is_walkable(row, col+1) && ! (to_str(row, col+1) in new_points) {
			new_points[to_str(row, col+1)] = true
		}
		if g.is_walkable(row, col-1) && ! (to_str(row, col-1) in new_points) {
			new_points[to_str(row, col-1)] = true
		}
	}
	return new_points.keys()
}

fn walk_part_2(points []string, g Garden) []string {
	// println(points)
	mut new_points := map[string]bool{}
	for p in points {
		row, col := to_point(p)
		if g.is_walkable_infinite(row+1, col) && ! (to_str(row+1, col) in new_points) {
			new_points[to_str(row+1, col)] = true
		}
		if g.is_walkable_infinite(row-1, col) && ! (to_str(row-1, col) in new_points) {
			new_points[to_str(row-1, col)] = true
		}
		if g.is_walkable_infinite(row, col+1) && ! (to_str(row, col+1) in new_points) {
			new_points[to_str(row, col+1)] = true
		}
		if g.is_walkable_infinite(row, col-1) && ! (to_str(row, col-1) in new_points) {
			new_points[to_str(row, col-1)] = true
		}
	}
	return new_points.keys()
}

struct Garden{
	size int
	rocks datatypes.Set[string]
}

fn to_point(str string) (int, int) {
	v := str.split(',')
	return v[0].int(), v[1].int()
}

fn to_str(row int, col int) string {
	return '${row},${col}'
}

fn (g Garden) is_walkable(row int, col int) bool {
	if row < 0 || row > g.size || col < 0 || col > g.size {
		return false
	}
	if g.rocks.exists('${row},${col}') {
		return false
	}
	return true
}

fn (g Garden) is_walkable_infinite(row int, col int) bool {
	mut r := row
	mut c := col
	for {
		if r < 0 {
			r += g.size
		} else if r >= g.size {
			r -= g.size
		} else {
			break
		}
	}
	for {
		if c < 0 {
			c += g.size
		} else if c >= g.size {
			c -= g.size
		} else {
			break
		}
	}
	//println('${row},${col} -> ${r},${c}')
	if g.rocks.exists('${r},${c}') {
		return false
	}
	return true
}

fn parse_data(data string) (Garden, int, int) {
	lines := data.split_into_lines()
	mut rocks := datatypes.Set[string]{}
	mut start_row := 0
	mut start_col := 0
	for row, line in lines {
		for col, c in  line {
			match c {
				`S` {
					start_row = row
					start_col = col
				}
				`#` {
					rocks.add('${row},${col}')
				}
				else {}
			}
		}
	} 
	return Garden{lines.len, rocks}, start_row, start_col
}
