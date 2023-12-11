module day10

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	pipe_map := parse_data(data)
	// println(pipe_map)
	start := get_start(pipe_map) or { panic(err) }
	start_type := get_start_type(pipe_map, start) or { panic(err) }
	mut start_dir := match start_type {
		.horizontal { Direction.east }
		.vertical { Direction.south }
		.north_east { Direction.east } // L
		.south_east { Direction.south } // F
		.north_west { Direction.west } // J
		.south_west { Direction.south } // 7
		else { panic('unexpected start type') }
	}
	// println('${start} -> ${start_dir}')
	mut next_dir := start_dir
	// mut next := coords.last()
	mut next := start.to(start_dir)
	mut step := 1
	for {
		// println('${next} -> ${next_dir}')
		next, next_dir = find_next(pipe_map, next, next_dir)
		if next == start {
			break
		}
		step ++;
	}
	return step / 2 + 1
}

fn part_2(data string) i64 {
	pipe_map := parse_data(data)
	start := get_start(pipe_map) or { panic(err) }
	start_type := get_start_type(pipe_map, start) or { panic(err) }
	mut start_dir := match start_type {
		.horizontal { Direction.east }
		.vertical { Direction.south }
		.north_east { Direction.east } // L
		.south_east { Direction.south } // F
		.north_west { Direction.west } // J
		.south_west { Direction.south } // 7
		else { panic('unexpected start type') }
	}
	mut next_dir := start_dir
	mut path := []Coord{}
	mut next := start.to(start_dir)
	path << start
	path << next
	for {
		// println('${next} -> ${next_dir}')
		next, next_dir = find_next(pipe_map, next, next_dir)
		if next == start {
			break
		}
		path << next
	}
	// println(path)
	mut inside := []Coord{}
	for row := 0; row < pipe_map.len; row++ {
		for col := 0; col < pipe_map[row].len; col++ {
			c := Coord{row, col}
			if path.contains(c) {
				continue
			}
			// println(c)
			if inside.contains(c.north()) || inside.contains(c.west()) || is_inside(pipe_map, c, path) {
				// println('${c.row}, ${c.col}')
				inside << c
			} 
		}
	}
	return inside.len
}

fn is_inside(pipe_map [][]Pipe, init Coord, path []Coord) bool {
	mut p := init.west()
	mut count := 0
	mut up := false
	for {
		if p.col < 0 {
			break
		}
		if path.contains(p) {
			match get_pipe_type(pipe_map, p) /* pipe_map[p.row][p.col] */ {
				.vertical { count += 1 }
				.north_east { count += if up { 1 } else { 0 } } // L
				.south_east { count += if up { 0 } else { 1 } } // F
				.north_west { up = false } // J
				.south_west { up = true } // 7
				else {}
			}
		}
		p = p.west()
	}
	return count % 2 == 1
}

fn get_pipe_type(pipe_map [][]Pipe, point Coord) Pipe {
	pipe := pipe_map[point.row][point.col]
	if pipe == Pipe.start {
		return get_start_type(pipe_map, point) or { panic(err) }
	}
	return pipe
}

fn get_start(pipe_map [][]Pipe) !Coord {
	for row := 0; row < pipe_map.len; row++ {
		for col := 0; col < pipe_map[row].len; col++ {
			if pipe_map[row][col] == Pipe.start {
				return Coord{row, col}
			}
		}
	}
	return error('Start not found')
}

fn get_start_type(pipe_map [][]Pipe, start Coord) !Pipe {
	north := start.north()
	south := start.south()
	east := start.east()
	west := start.west()

	pipe_north := pipe_map[north.row][north.col] 
	pipe_south := pipe_map[south.row][south.col]
	pipe_east := pipe_map[east.row][east.col]
	pipe_west := pipe_map[west.row][west.col]

	north_connection := pipe_north == Pipe.vertical || pipe_north == Pipe.south_east || pipe_north == Pipe.south_west
	south_connection := pipe_south == Pipe.vertical || pipe_north == Pipe.north_east || pipe_north == Pipe.north_west
	east_connection := pipe_east == Pipe.horizontal || pipe_east == Pipe.north_west || pipe_east == Pipe.south_west
	west_connection := pipe_west == Pipe.horizontal || pipe_west == Pipe.north_east || pipe_west == Pipe.south_east

	// println(north_connection)
	// println(south_connection)
	// println(east_connection)
	// println(west_connection)

	if north_connection && south_connection {
		return Pipe.vertical
	}
	if north_connection && east_connection {
		return Pipe.north_east
	}
	if north_connection && west_connection {
		return Pipe.north_west
	}
	if south_connection && west_connection {
		return Pipe.south_west
	}
	if south_connection && east_connection {
		return Pipe.south_east
	}
	if west_connection && east_connection {
		return Pipe.horizontal
	}
	
	return error('Could not determine start type')
}

fn find_next(pipe_map [][]Pipe, point Coord, from Direction) (Coord, Direction) {
	pipe := pipe_map[point.row][point.col]
	// println(pipe)
	match pipe {
		.horizontal { if from == Direction.west { 
				return point.west(), Direction.west
			} else {
				return point.east(), Direction.east 
			}
		}
		.vertical { if from == Direction.north { 
				return point.north(), Direction.north
			} else { 
				return point.south(), Direction.south 
			}
		}
		.north_east { // L
			if from == Direction.south {  
				return point.east(), Direction.east
			} else { 
				return point.north(), Direction.north 
			}
		}
		.north_west { // J
			if from == Direction.south { 
				return point.west(), Direction.west
			} else { 
				return point.north(), Direction.north 
			}
		}
		.south_east { // F
			if from == Direction.north {
				return point.east(), Direction.east
			} else { 
				return point.south(), Direction.south 
			}
		}
		.south_west { // 7
			if from == Direction.north {
				return point.west(), Direction.west
			} else { 
				return point.south(), Direction.south 
			}
		}
		else {
			panic("WTF")
		} 
	}
}

enum Direction as u8 {
	north
	south
	east
	west
}

enum Pipe as u8{
	@none
	start
	vertical
	horizontal
	north_east
	north_west
	south_east 
	south_west
}

struct Coord {
	row int
	col int
}

fn (c Coord) north() Coord {
	return Coord{c.row - 1, c.col}
}

fn (c Coord) south() Coord {
	return Coord{c.row + 1, c.col}
}

fn (c Coord) west() Coord {
	return Coord{c.row, c.col - 1}
}

fn (c Coord) east() Coord {
	return Coord{c.row, c.col + 1}
}

fn (c Coord) to(direction Direction) Coord {
	match direction {
		.north { return c.north() }
		.south { return c.south() }
		.east { return c.east() }
		.west { return c.west() }   
	}
}


fn parse_data(data string) [][]Pipe {
	mut pipe_map := [][]Pipe{} 
	lines := data.split_into_lines()
	for line in lines {
		mut pipe_line := []Pipe{}
		tiles := line.split('')
		for c in tiles {
			match c {
				'.' { pipe_line << Pipe.@none }
				'S' { pipe_line << Pipe.start }
				'|' { pipe_line << Pipe.vertical }
				'-' { pipe_line << Pipe.horizontal }
				'L' { pipe_line << Pipe.north_east }
				'J' { pipe_line << Pipe.north_west }
				'7' { pipe_line << Pipe.south_west }
				'F' { pipe_line << Pipe.south_east }
				else {}
			}
		}
		pipe_map << pipe_line
	}
	return pipe_map
}
