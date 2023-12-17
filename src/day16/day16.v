module day16

import datatypes
import math

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	contraption := parse_data(data)
	start := Vector{Position{0, 0}, Direction.east}
	return energize(start, contraption)
}

fn part_2(data string) int {
	contraption := parse_data(data)
	mut energized_max := 0
	for col := 0; col < contraption.col_len; col ++ {
		energized_count := energize(Vector{Position{0, col}, Direction.south}, contraption);
		energized_max = math.max(energized_count, energized_max)
	}
	for col := 0; col < contraption.col_len; col ++ {
		energized_count := energize(Vector{Position{contraption.row_len-1, col}, Direction.north}, contraption);
		energized_max = math.max(energized_count, energized_max)
	}
	for row := 0; row < contraption.row_len; row ++ {
		energized_count := energize(Vector{Position{row, 0}, Direction.east}, contraption);
		energized_max = math.max(energized_count, energized_max)
	}
	for row := 0; row < contraption.row_len; row ++ {
		energized_count := energize(Vector{Position{row, contraption.col_len-1}, Direction.west}, contraption);
		energized_max = math.max(energized_count, energized_max)
	}
	return energized_max
}

fn energize(start Vector, c Contraption) int {
	mut visited := datatypes.Set[string]{}
	mut visited_positions := datatypes.Set[string]{}
	mut stack := datatypes.Stack[Vector]{}
	visited.add(start.str())
	visited_positions.add(start.Position.str())
	stack.push(start)
	for {
		if stack.is_empty() {
			break
		}
		vec := stack.pop() or { panic (err) }
		next := compute_next(vec, c)
		//println('next = ${next}')
		for v in next {
			if !visited.exists(v.str()) {
				visited.add(v.str())
				visited_positions.add(v.Position.str())
				stack.push(v)
			}
		}
	}
	return visited_positions.size()
}

fn compute_next(vec Vector, contraption Contraption) []Vector {
	mut next := []Vector{}

	match contraption.tile(vec.Position.row, vec.Position.col) {
		.@none {
			v_next := vec.forward()
			if contraption.is_valid(v_next) {
				next << v_next
			}
		}
		.horizontal {
			match vec.direction {
				.east {
					v_next := vec.forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.west {
					v_next := vec.forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.north {
					v_next_1 := vec.left().forward()
					if contraption.is_valid(v_next_1) {
						next << v_next_1
					}
					v_next_2 := vec.right().forward()
					if contraption.is_valid(v_next_2) {
						next << v_next_2
					}
				}
				.south {
					v_next_1 := vec.left().forward()
					if contraption.is_valid(v_next_1) {
						next << v_next_1
					}
					v_next_2 := vec.right().forward()
					if contraption.is_valid(v_next_2) {
						next << v_next_2
					}
				}
			}
		}
		.vertical {
			match vec.direction {
				.north {
					v_next := vec.forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.south {
					v_next := vec.forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.west {
					v_next_1 := vec.left().forward()
					if contraption.is_valid(v_next_1) {
						next << v_next_1
					}
					v_next_2 := vec.right().forward()
					if contraption.is_valid(v_next_2) {
						next << v_next_2
					}
				}
				.east {
					v_next_1 := vec.left().forward()
					if contraption.is_valid(v_next_1) {
						next << v_next_1
					}
					v_next_2 := vec.right().forward()
					if contraption.is_valid(v_next_2) {
						next << v_next_2
					}
				}
			}
		}
		.slash {
			match vec.direction {
				.north {
					v_next := vec.right().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.south {
					v_next := vec.right().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.west {
					v_next := vec.left().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.east {
					v_next := vec.left().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
			}
		}
		.backslash {
			match vec.direction {
				.north {
					v_next := vec.left().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.south {
					v_next := vec.left().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.west {
					v_next := vec.right().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
				.east {
					v_next := vec.right().forward()
					if contraption.is_valid(v_next) {
						next << v_next
					}
				}
			}
		}
	}
	return next
}

enum Tile {
	@none
	horizontal
	vertical
	slash
	backslash
}

enum Direction {
	north
	south
	east
	west
}

fn (d Direction) left() Direction {
	match d {
		.north { return Direction.west }
		.west { return Direction.south }
		.south { return Direction.east }
		.east { return Direction.north }
	}
}

fn (d Direction) right() Direction {
	match d {
		.north { return Direction.east }
		.east { return Direction.south }
		.south { return Direction.west }
		.west { return Direction.north }
	}
}

struct Position {
	row int
	col int
}

struct Vector {
	Position
	direction Direction
}

struct Contraption {
	tiles [][]Tile
	row_len int
	col_len int
}

fn (v Vector) forward() Vector {
	return Vector{v.Position.apply(v.direction), v.direction}
}

fn (v Vector) left() Vector {
	return Vector{v.Position, v.direction.left()}
}

fn (v Vector) right() Vector {
	return Vector{v.Position, v.direction.right()}
}

fn (v Vector) str() string {
	return '${v.Position}-${v.direction}'
}

fn (p Position) apply(direction Direction) Position {
	match direction {
		.north { return Position{p.row-1, p.col} }
		.south { return Position{p.row+1, p.col} }
		.west { return Position{p.row, p.col-1} }
		.east { return Position{p.row, p.col+1} }
	}
}

fn (p Position) is_valid(row_len int, col_len int) bool {
	return p.row >= 0 && p.row < row_len && p.col >= 0 && p.col < col_len
}

fn (p Position) str() string {
	return '${p.row}-${p.col}'
}

fn (c Contraption) is_valid(v Vector) bool {
	return v.Position.is_valid(c.row_len, c.col_len)
}

fn (c Contraption) tile(row int, col int) Tile {
	return c.tiles[row][col]
}

fn parse_data(data string) Contraption {
	lines := data.split_into_lines()
	mut tiles := [][]Tile{}
	for line in lines {
		mut row := []Tile{}
		for c in line {
			match c {
				`.` { row << Tile.@none }
				`-` { row << Tile.horizontal }
				`|` { row << Tile.vertical }
				`\\` { row << Tile.backslash }
				`/` { row << Tile.slash }
				else {}
			}
		}
		tiles << row
	}
	return Contraption{tiles, tiles.len, tiles[0].len}
}
