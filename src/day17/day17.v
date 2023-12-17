module day17

import datatypes

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	grid := parse_data(data)
	return dijkstra(Node{0, 0, Direction.east, 0}, grid, neighbours_part_1, stop_condition_part_1)
}

fn part_2(data string) int {
	grid := parse_data(data)
	return dijkstra(Node{0, 0, Direction.east, 0}, grid, neighbours_part_2, stop_condition_part_2)
}

struct Node {
	row int
	col int
	move Direction
	forward_count int // max 3
}

fn (n Node) str() string {
	return '${n.row}-${n.col}-${n.move}-${n.forward_count}'
}

struct NodeWithDistance {
	Node
	distance int
}

fn (n1 NodeWithDistance) < (n2 NodeWithDistance) bool {
	return n1.distance < n2.distance
}

fn (n1 NodeWithDistance) == (n2 NodeWithDistance) bool {
	return n1.distance == n2.distance
}

fn neighbours_part_1(node Node, width int, height int) []Node {
	mut neighbours := []Node{}
	for d in [node.move, node.move.left(), node.move.right()] {
		c_row, c_col := d.forward(node.row, node.col)
		if c_row < 0 || c_row >= height || c_col < 0 || c_col >= width {
			continue
		} 
		if d == node.move {
			if node.forward_count < 3 {
				neighbours << Node{c_row, c_col, d, node.forward_count+1}
			}
		} else {
			neighbours << Node{c_row, c_col, d, 1}
		}
	}
	// println(neighbours)
	return neighbours
}

fn stop_condition_part_1(node Node, width int, height int) bool {
	return node.row == height-1 && node.col == width-1
}

fn neighbours_part_2(node Node, width int, height int) []Node {
	mut neighbours := []Node{}
	for d in [node.move, node.move.left(), node.move.right()] {
		c_row, c_col := d.forward(node.row, node.col)
		if c_row < 0 || c_row >= height || c_col < 0 || c_col >= width {
			continue
		} 
		if d == node.move {
			if node.forward_count < 10 {
				neighbours << Node{c_row, c_col, d, node.forward_count+1}
			}
		} else if node.forward_count < 4 {
			continue
		} else {
			neighbours << Node{c_row, c_col, d, 1}
		}
	}
	// println(neighbours)
	return neighbours
}

fn stop_condition_part_2(node Node, width int, height int) bool {
	return node.row == height-1 && node.col == width-1 && node.forward_count >= 4 
}

fn dijkstra(start Node, grid Grid, neighbour_nodes fn(Node, int, int) []Node, stop_condition fn(Node, int, int) bool) int {
	mut visited := datatypes.Set[string]{}
	mut queue := datatypes.MinHeap[NodeWithDistance]{}
	queue.insert(NodeWithDistance{start, 0})
	for {
		if queue.len() == 0 {
			break
		}
		cur := queue.pop() or { panic(err) }
		if stop_condition(cur.Node, grid.width, grid.height) { // cur.Node.row == grid.height-1 && cur.Node.col == grid.width-1 && cur.Node.forward_count >= 4 {
			return cur.distance
		}
		if visited.exists(cur.Node.str()) {
			continue
		}
		visited.add(cur.Node.str())
		for n in neighbour_nodes(cur.Node, grid.width, grid.height) {
			if visited.exists(n.str()) {
				continue
			}
			distance := cur.distance + grid.data[n.row][n.col]
			queue.insert(NodeWithDistance{n, distance})
		}
		//println(queue)
	}
	return -1
}

enum Direction {
	north
	south
	east
	west
}

fn (d Direction) forward(row int, col int) (int, int) {
	match d {
		.north { return row-1, col }
		.south { return row+1, col }
		.east { return row, col+1 }
		.west { return row, col-1 }
	}
}

fn (d Direction) left() Direction {
	match d {
		.north { return Direction.west }
		.south { return Direction.east }
		.east { return Direction.north }
		.west { return Direction.south }
	}
}

fn (d Direction) right() Direction {
	match d {
		.north { return Direction.east }
		.south { return Direction.west }
		.east { return Direction.south }
		.west { return Direction.north }
	}
}

struct Grid {
	data [][]int
	height int
	width int
}

fn parse_data(data string) Grid {
	lines := data.split_into_lines()
	mut grid := [][]int{}
	for line in lines {
		mut row := []int{}
		values := line.split('')
		for value in values {
			row << value.int()
		}
		grid << row
	}
	return Grid{grid, grid.len, grid[0].len}
}
