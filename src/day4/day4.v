module day4

import math
import regex
import datatypes { Set }

pub fn solve(data string) {
	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	mut sum := 0 
	lines := data.split_into_lines()
	for line in lines {
		numbers := line.split_any(':|')
		winning_numbers := get_numbers(numbers[1])
		my_numbers := get_numbers(numbers[2])
		intersection := winning_numbers.intersection(my_numbers)
		sum += if intersection.is_empty() { 0 } else { 1 << (intersection.size() - 1) }
	}
	return sum
}

fn part_2(data string) int {
	lines := data.split_into_lines()
	mut cards := map[int]int{}
	cards_count := lines.len
	for i, _ in lines {
		cards[i] = 1
	}
	for i, line in lines {
		numbers := line.split_any(':|')
		winning_numbers := get_numbers(numbers[1])
		my_numbers := get_numbers(numbers[2])
		intersection := winning_numbers.intersection(my_numbers)
		won := intersection.size()
		for j := i+1; j <= math.min(i + won, cards_count - 1) ; j++ {
			cards[j] += cards[i]
		}
	}
	return reduce(cards.values(), fn (a int, b int) int { return a+b }, 0) 
}

fn get_numbers(number_list string) Set[int] {
	mut re := regex.regex_opt(r'[0-9]+') or { panic(err) }
	mut set := Set[int]{}
	set.add_all(re.find_all_str(number_list).map(it.int())	)
	return set
}

fn reduce(arr []int, op fn (int, int) int, init int) int {
    mut value := init
    for num in arr {
        value = op(value, num)
    }
    return value
}
