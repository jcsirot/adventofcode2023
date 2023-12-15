module day15

import arrays

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	strs := parse_data(data)
	return arrays.fold(strs, 0, fn(acc int, elem string) int { return acc + hash(elem) })
}

fn part_2(data string) int {
	strs := parse_data(data)
	mut boxes := map[int][]Lens{}
	for str in strs {
		label, focal_len := remove_or_insert(str)
		box := hash(label)
		if focal_len == -1 {
			remove_lens(mut boxes, box, label)
		} else {
			replace_or_insert(mut boxes, box, label, focal_len)
		}
		// println(boxes)
	}
	mut sum := 0
	for i := 0; i < 256; i++ {
		if i in boxes {
			box := boxes[i]
			for j, lens in box {
				sum += (i+1)*(j+1)*lens.focal_len
			}
		}
	}
	return sum
}

fn remove_lens(mut boxes map[int][]Lens, box int, label string) {
	for idx := 0; idx < boxes[box].len; idx++ {
		if boxes[box][idx].label == label {
			boxes[box].delete(idx)
		}
	}
}

fn replace_or_insert(mut boxes map[int][]Lens, box int, label string, focal_len int) {
	for idx := 0; idx < boxes[box].len; idx++ {
		if boxes[box][idx].label == label {
			boxes[box][idx] = Lens{label, focal_len}
			return
		}
	}
	boxes[box] << Lens{label, focal_len}
}

fn remove_or_insert(s string) (string, int) {
	return if s[s.len-1] == `-` { s[0..s.len-1], -1 } else { s[0..s.len-2], s[s.len-1..s.len].int() }
}

fn hash(s string) u8 {
	mut sum := u8(0)
	for c in s {
		sum += c
		sum = (sum << 4) + sum
	}
	return sum
}

struct Lens {
	label string
	focal_len int
}

fn parse_data(data string) []string {
	return data.split(',')
}
