module day14

import arrays
import strings

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	mut platform := parse_data(data)
	platform = update(platform)
	return load(platform)
}

fn part_2(data string) int {
	mut platform := parse_data(data)
	mut visited := [][][]Rock{}
	visited << platform
	for i := 1; i <= 1000; i++ {
		platform = cycle(platform)
		if visited.contains(platform) {
			cycle_start := arrays.index_of_first(visited, fn [platform] (__ int, pf [][]Rock) bool { return pf == platform })
			cycle_len := i - cycle_start
			shift := (1000000000 - i) % cycle_len
			return load(visited[cycle_start + shift])
		} else {
			visited << platform
		}
	}
	return 0
}

fn load(platform [][]Rock) int {
	row_count := platform.len
	mut sum := 0
	for i, row in platform {
		for c in row {
			match c {
				.rounded { sum += row_count-i}
				else { }
			}
		}
	}
	return sum
}

fn cycle(platform [][]Rock) [][]Rock {
	mut pf := update(platform)
	pf = rotate(pf)
	pf = update(pf)
	pf = rotate(pf)
	pf = update(pf)
	pf = rotate(pf)
	pf = update(pf)
	pf = rotate(pf)
	// show(pf)
	return pf
}

// rotate the platform 90° clockwise - Do not move rocks
fn rotate(platform [][]Rock) [][]Rock {
	mut rotated := [][]Rock{}
	for col := 0 ; col < platform[0].len; col++ {
		mut nrow := []Rock{}
		for row := platform.len - 1; row >= 0; row-- {
			nrow << platform[row][col]
		}
		rotated << nrow
	}
	return rotated
}

// move rocks to the north
fn update(platform [][]Rock) [][]Rock {
	mut updated := platform.clone()
	row_count := platform.len
	for col := 0 ; col < platform[0].len; col++ {
		mut rock_count := 0
		for row := row_count - 1; row >= 0; row-- {
			c := platform[row][col]
			match c {
				.rounded {
					rock_count++
					updated[row][col] = Rock.@none
				}
				.cube {
					// println("row=${row}, count=${rock_count}")
					for i:= 1; i <= rock_count; i++ {
						updated[row+i][col] = Rock.rounded
					}
					rock_count = 0
				}
				else {}
			}
		}
		// println("row=-1, count=${rock_count}")
		for i:= 0; i < rock_count; i++ {
			updated[i][col] = Rock.rounded
		}
		rock_count = 0
	}
	return updated
}

fn show(platform [][]Rock) {
	println(to_str(platform))
}

fn to_str(platform [][]Rock) string {
	mut sb := strings.new_builder(1000)
	for row in platform {
		for c in row {
			match c {
				.@none { sb.write_string('.') }
				.cube { sb.write_string('#') }
				.rounded { sb.write_string('O') }
			}
		}
		sb.write_string('\n')
	}
	return sb.str()
}

enum Rock {
	@none
	cube
	rounded
} 

fn parse_data(data string) [][]Rock {
	lines := data.split_into_lines()
	mut platform := [][]Rock{}

	for line in lines {
		mut row := []Rock{}
		for c in line {
			match c {
				`O` { row << Rock.rounded }
				`#` { row << Rock.cube }
				else { row << Rock.@none }
			}
		}
		platform << row
	}
	return platform
}
