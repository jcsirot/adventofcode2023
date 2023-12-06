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

	match day {
		1 { day1.solve(content) }
		2 { day2.solve(content) }
		3 { day3.solve(content) }
		4 { day4.solve(content) }
		5 { day5.solve(content) }
		6 { day6.solve(content) }
		else { return error('Day ${day} Not Yet Implemented') }
	}
}
