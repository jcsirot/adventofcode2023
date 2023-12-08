module day8

import math
import regex

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	directions, node_map := parse_data(data)
	return compute_path_to_z('AAA', fn(node string) bool { return node == 'ZZZ' }, directions, node_map)
}

fn part_2(data string) i64 {
	directions, node_map := parse_data(data)
	mut lcm := i64(1)
	for node in node_map.keys().filter(it.ends_with('A')) {
		lcm = math.lcm(lcm, i64(compute_path_to_z(
			node, fn(node string) bool { return node.ends_with('Z') }, directions, node_map)))
	}
	return lcm
}

fn compute_path_to_z(start string, stop_condition fn (string) bool, directions string, node_map map[string]Node) int {
	mut node := start
	mut steps := 0
	for {
		direction := directions[steps++ % directions.len]
		node = if direction == `L` { node_map[node].left } else { node_map[node].right }
		// println(node)
		if stop_condition(node) {
			break
		}
	}
	return steps
}

struct Node {
	left string
	right string
}

fn parse_data(data string) (string, map[string]Node) {
	lines := data.split_into_lines()
	directions := lines[0]
	mut node_map := map[string]Node{}
	mut re := regex.regex_opt(r'(?P<node>\w+) = \((?P<left>\w+), (?P<right>\w+)\)') or { panic(err) }
	for line in lines[2..] {
		re.match_string(line)
		g_node_start, g_node_end := re.get_group_bounds_by_name('node')
		g_left_start, g_left_end := re.get_group_bounds_by_name('left')
		g_right_start, g_right_end := re.get_group_bounds_by_name('right')
		node_map[line[g_node_start..g_node_end]] =
			Node{line[g_left_start..g_left_end], line[g_right_start..g_right_end]}
	}
	return directions, node_map
}
