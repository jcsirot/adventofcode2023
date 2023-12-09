module day9

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) int {
	series := parse_data(data)
	mut sum := 0
	for serie in series {
		sum += compute_next_value(serie)
	}
	return sum
}

fn part_2(data string) i64 {
	series := parse_data(data)
	mut sum := 0
	for serie in series {
		sum += compute_previous_value(serie)
	}
	return sum
}

fn compute_next_value(serie []int) int {
	mut sum := 0;
	mut current := serie.clone()
	for {
		sum += current.last()
		mut diffs := []int{}
		for i := 0; i < current.len - 1; i++ {
			diffs << current[i+1] - current[i]
		}
		if diffs.all(it == 0) {
			break
		}
		current = diffs.clone()
	}
	return sum
}

fn compute_previous_value(serie []int) int {
	mut sum := 0;
	mut factor := 1;
	mut current := serie.clone()
	for {
		sum += factor * current.first()
		factor *= -1
		mut diffs := []int{}
		for i := 0; i < current.len - 1; i++ {
			diffs << current[i+1] - current[i]
		}
		if diffs.all(it == 0) {
			break
		}
		current = diffs.clone()
	}
	return sum
}

fn parse_data(data string) [][]int {
	lines := data.split_into_lines()
	mut series := [][]int{}
	for line in lines {
		serie := line.split(' ')
		series << serie.map(it.int())
	}
	return series
}
