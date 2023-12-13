module day12

import arrays

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) i64 {
	rows := parse_data(data)
	mut sum := i64(0)
	mut cache := map[string]i64{}
	for row in rows {
		sum += enumerate_row(row.springs, row.report, mut cache)
	}
	return sum
}

fn part_2(data string) i64 {
	rows := parse_data(data)
	mut sum := i64(0)
	mut cache := map[string]i64{}
	for row in rows {
		unfold_springs := row.springs + '?' + row.springs + '?' + row.springs + '?' + row.springs + '?' + row.springs
		unfold_report := row.report.repeat(5)
		sum += enumerate_row(unfold_springs, unfold_report, mut cache)
	}
	return sum
}

fn enumerate_row(row string, report []int, mut cache map[string]i64) i64 {
	// println('${row} - ${report}')
	key := row + report.str()
	if key in cache {
		return cache[key]
	}

	str := row.trim_left('.')

	if report == [] {
		return if str.contains('#') { 0 } else { 1 }
	}  

	if str == '' {
		return if report == [] { 1 } else { 0 }
	}

	mut v := i64(0)
	if str[0] == `?` {
		v = enumerate_row('#' + str[1..], report, mut cache) + enumerate_row(str[1..], report, mut cache)
	} else if str.len == report[0] {
		v = if report.len == 1 { 1 } else { 0 }
	} else if str.len < report[0] || 
			str[0..report[0]].contains('.') ||  // not enough remaining space
			str[report[0]] == `#` { // too long
		v = 0
	} else { // remaining ? must be #
		v = enumerate_row(str[report[0]+1..] /* skip group separator */, report[1..], mut cache)
	}

	cache[key] = v
	return v
}

struct SpringRow {
	springs string
	report []int
}

fn parse_data(data string) []SpringRow {
	lines := data.split_into_lines()
	mut rows := []SpringRow{}
	for line in lines {
		strs := line.split(' ')
		rows << SpringRow{strs[0], strs[1].split(',').map(it.int())}
	}
	return rows
}
