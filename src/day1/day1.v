module day1

import encoding.utf8 { is_number }
import regex

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	query := r'[0-9]'
	lines := data.split('\n')
	mut sum := 0;
	for line in lines {
		mut re := regex.regex_opt(query) or { panic(err) }
		matches := re.find_all_str(line)
		sum += '${matches.first()}${matches.last()}'.int();

	}
	return sum
}

fn part_2(data string) int {
	lines := data.split('\n')
	mut sum := 0
	for line in lines {
		sum += 10 * find_first_digit_part2(line, ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'])
		sum += find_first_digit_part2(line.reverse(), ['eno', 'owt', 'eerht', 'ruof', 'evif', 'xis', 'neves', 'thgie', 'enin'])
	}
	return sum
}

fn find_first_digit_part2(str string, digits []string) int {
	runes := str.runes()
	for i, r in runes {
		if is_number(r) {
			mut arr := []rune{}
			arr << r
			return arr.string().int()
		} else {
			for j, d in digits {
				if str_compare(str, d, i) {
					return j + 1
				}
			}
		}
	}
	return 0
}

fn str_compare(str string, test string, index int) bool {
	if index + test.len > str.len {
		return false
	}
	return str[index..index+test.len] == test
}