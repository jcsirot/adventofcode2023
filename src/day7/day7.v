module day7

import arrays

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	return compute_total_winnings(data, compare_hands_part1)
}

fn part_2(data string) int {
	return compute_total_winnings(data, compare_hands_part2)
}

fn compute_total_winnings(data string, hand_comparator fn (&Draw, &Draw) int) int {
	mut draws := parse_data(data)
	mut sum := 0
	draws = sort_draws(draws, hand_comparator)
	for i, draw in draws {
		sum += (i+1) * draw.bid
	}
	return sum
}

struct Draw {
	hand string
	bid int
}

fn parse_data(data string) []Draw {
	lines := data.split_into_lines()
	mut draws := []Draw{}
	for line in lines {
		str := line.split(' ')
		draws << Draw{str[0], str[1].int()}
	}
	return draws
}

fn sort_draws(draws []Draw, hand_compare fn (&Draw, &Draw) int) []Draw {
	mut cloned_array := draws.clone()
	cloned_array.sort_with_compare(hand_compare)
	return cloned_array
}

fn compare_hands_part1(a &Draw, b &Draw) int {
	h1 := a.hand
	h2 := b.hand
	type_cmp := compare_types(h1, h2, get_type)
	if type_cmp != 0 {
		return type_cmp
	}
	return compare_value(h1, h2, card_to_int)
}

fn compare_hands_part2(a &Draw, b &Draw) int {
	h1 := a.hand
	h2 := b.hand
	type_cmp := compare_types(h1, h2, compute_best_type)
	if type_cmp != 0 {
		return type_cmp
	}
	return compare_value(h1, h2, card_to_int_part2)
}

const card_to_int := {
	`A`: 12
	`K`: 11
	`Q`: 10
	`J`: 9
	`T`: 8
	`9`: 7
	`8`: 6
	`7`: 5
	`6`: 4
	`5`: 3
	`4`: 2
	`3`: 1
	`2`: 0
}

const card_to_int_part2 := {
	`A`: 12
	`K`: 11
	`Q`: 10
	`T`: 9
	`9`: 8
	`8`: 7
	`7`: 6
	`6`: 5
	`5`: 4
	`4`: 3
	`3`: 2
	`2`: 1
	`J`: 0
}

fn compare_value(h1 string, h2 string, mapper map[rune]int) int {
	return hand_to_int(h1, mapper) - hand_to_int(h2, mapper)
}

fn hand_to_int(hand string, mapper map[rune]int) int {
	return mapper[hand[4]] | 
		mapper[hand[3]] << 4 |
		mapper[hand[2]] << 8 | 
		mapper[hand[1]] << 12 | 
		mapper[hand[0]] << 16
}

fn compare_types(h1 string, h2 string, mapper fn (string) int) int {
	return mapper(h1) - mapper(h2)
}

fn get_type(hand string) int {
	mut m := map[rune]int{}
	for c in hand {
		m[c] += 1
	}
	if m.values().len == 1 {
		return 6
	} else if m.values().contains(4) {
		return 5
	} else if m.values().contains(3) && m.values().contains(2) {
		return 4
	} else if m.values().contains(3) {
		return 3
	} else if m.values().len == 3 && m.values().contains(2) {
		return 2
	} else if m.values().contains(2) {
		return 1
	} else {
		return 0
	}
}

fn compute_best_type(hand string) int {
	mut types := map[int]string{}
	evaluate_hands([hand], mut &types)
	return arrays.max(types.keys()) or { panic('key not found') }
}

fn evaluate_hands(hands []string, mut types &map[int]string) {
	for hand in hands {
		if hand.contains('J') {
			evaluate_hands(emit_hands(hand), mut &types)
		} else {
			typ := get_type(hand)
			types[typ] = hand
		}
	}
}

fn emit_hands(hand string) []string {
	mut arr := []string{}
	for c in ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2'] {
		arr << hand.replace_once('J', c)
	}
	return arr
}
