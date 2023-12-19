module main

import cli { Command, Flag }
import os
import strconv { atoi }
import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import day9
import day10
import day11
import day12
import day13
import day14
import day15
import day16
import day17
import day18
import day19

fn main() {
	mut cmd := Command{
		name: 'aoc'
		description: 'Advent of Code 2023 CLI.'
		version: '1.0.0'
		required_args: 1
		execute: aoc_func
	}

	cmd.add_flag(Flag{
		flag: .string
		required: false
		name: 'data-file'
		abbrev: 'f'
		description: 'Puzzle data file.'
	})

	cmd.setup()
	cmd.parse(os.args)
}

fn aoc_func(cmd Command) ! {
	day := atoi(cmd.args[0]) or {
		return error('The day must be an integer between 1 and 25. ${err}')
	}

	if day < 1 || day > 25 {
		return error('The day must be an integer between 1 and 25.')
	}

	filepath := cmd.flags.get_all_found().get_string('data-file') or { 'puzzles/${day}.txt' }

	content := os.read_file(filepath) or {
      	return error('Could not read data file: $err')
    }

	println('Solving day ${day}')
	match day {
		1 { day1.solve(content) }
		2 { day2.solve(content) }
		3 { day3.solve(content) }
		4 { day4.solve(content) }
		5 { day5.solve(content) }
		6 { day6.solve(content) }
		7 { day7.solve(content) }
		8 { day8.solve(content) }
		9 { day9.solve(content) }
		10 { day10.solve(content) }
		11 { day11.solve(content) }
		12 { day12.solve(content) }
		13 { day13.solve(content) }
		14 { day14.solve(content) }
		15 { day15.solve(content) }
		16 { day16.solve(content) }
		17 { day17.solve(content) }
		18 { day18.solve(content) }
		19 { day19.solve(content) }
		else { return error('Day ${day} Not Yet Implemented') }
	}
}
