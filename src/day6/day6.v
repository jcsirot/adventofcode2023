module day6

import regex
import math

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) i64 {
	times, distances := parse_data(data)
	mut product := i64(1)
	for i := 0; i < times.len; i++ {
		time := times[i]
		distance := distances[i]
		t1, t2 := compute_solutions(time, distance)
		product = product * (t2 - t1 + 1)
	}
	return product
}

fn part_2(data string) i64 {
	time, distance := parse_data_part_2(data)
	t1, t2 := compute_solutions(time, distance)
	return t2 - t1 + 1
}

fn parse_data(data string) ([]int, []int) {
	lines := data.split_into_lines()
	return to_int_array(lines[0]), to_int_array(lines[1])
}

fn fun(time i64, distance i64) (fn (i64)  i64) {
	return fn [time, distance] (x i64) i64 {
		return time*x - x*x - distance
	}
}

fn compute_solutions(time i64, distance i64) (i64, i64) {
	y := fun(time, distance)
	delta := time*time - 4*distance
	mut t1 := i64(math.ceil((time - math.sqrt(delta))/2))
	t1 = if y(t1) == 0 {t1+1} else {t1}
	mut t2 := i64(math.floor((time + math.sqrt(delta))/2))
	t2 = if y(t2) == 0 {t2-1} else {t2}
	return t1, t2
} 

fn to_int_array(str string) []int {
	mut re := regex.regex_opt(r'[0-9]+') or { panic(err) }
	return re.find_all_str(str).map(it.int())
}

fn parse_data_part_2(data string) (i64, i64) {
	lines := data.split_into_lines()
	mut re := regex.regex_opt(r'[0-9]+') or { panic(err) }
	return re.find_all_str(lines[0]).join('').i64(), re.find_all_str(lines[1]).join('').i64()
}
