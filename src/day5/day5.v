module day5

import math { min }
import regex

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) u32 {
	seeds, almanac := parse_data(data)
	mut locations := []u32{}
	for seed in seeds {
		mut value := seed
		for almanac_map in almanac {
			x := almanac_map.to(value)
			value = x
		}
		locations << value
	}
	mut min_location := max_u32
	for location in locations {
		min_location = min(min_location, location)
	}
	return min_location
}

fn part_2(data string) u32 {
	seeds, almanac := parse_data(data)
	mut init_ranges := []Range{}
	mut final_ranges := []Range{}

	// init ranges
	for i := 0; i < seeds.len; i+=2 {
		init_ranges << Range{seeds[i], seeds[i+1]}
	}
	for init_range in init_ranges {
		mut ranges := [init_range]
		for almanac_map in almanac {
			mut new_ranges := []Range{}
			for range in ranges {
				new_ranges << almanac_map.to_range(range)
			}
			ranges = new_ranges.clone()
		}
		final_ranges << ranges
	}
	mut min_location := max_u32
	for location_range in final_ranges {
		min_location = min(min_location, location_range.start)
	}
	return min_location
}

struct MapEntry {
	src u32
	dest u32
	len u32
}

type AlmanacMap = []MapEntry

struct Range {
	start u32
	len u32
}

fn (m AlmanacMap) to(value u32) u32 {
	for entry in m {
		// println(entry)
		if value >= entry.src && value < entry.src + entry.len {
			return entry.dest + value - entry.src
		}
	}
	return value
}

fn (m AlmanacMap) to_range(range Range) []Range  {
	// println('mapping range ${range}')
	value := range.start
	len := range.len
	for entry in m {
		if value >= entry.src && value < entry.src + entry.len {
			if value + len <= entry.src + entry.len {
				// println('range completly in ${entry}')
				return [Range{entry.dest + value - entry.src, range.len}]
			} else {
				// println('range partially in ${entry}')
				mut arr := m.to_range(Range{entry.src + entry.len, len - (entry.src + entry.len - value)})
				arr << Range{entry.dest + value - entry.src, entry.src + entry.len - value}
				return arr
			}
		} else if value < entry.src {
			if value + len < entry.src {
				// println('range completly in unmapped entry')
				return [range]
			} else {
				// println('range partially in unmapped entry')
				mut arr := m.to_range(Range{entry.src, len - (entry.src - value)})
				arr << Range{value, entry.src - value}
				return arr
			}
		}
	}
	// println('range in unmapped')
	return [range]
}

fn parse_data(data string) ([]u32, []AlmanacMap) {
	mut almanac := []AlmanacMap{}
	lines := data.split_into_lines()
	seeds := lines[0]
	mut i := 3
	mut map_data := []string{}
	for i < lines.len {
		if lines[i].is_blank() {
			almanac << parse_almanac_map(map_data)
			//println(parse_almanac_map(map_data))
			map_data.clear()
		} else if !lines[i].ends_with('map:') {
			map_data << lines[i]
		}
		i++
	}
	return to_int_array(seeds.all_after('seeds :')), almanac
}

fn parse_almanac_map(lines []string) AlmanacMap {
	mut almanac_map := []MapEntry{} 
	for line in lines {
		values := to_int_array(line)
		almanac_map << MapEntry{values[1], values[0], values[2]}
	}
	almanac_map.sort_with_compare(fn (a &MapEntry, b &MapEntry) int {
		if a.src < b.src {
			return -1
		}
		if a.src > b.src {
			return 1
		}
		return 0
	})
	return almanac_map
}

fn to_int_array(str string) []u32 {
	mut re := regex.regex_opt(r'[0-9]+') or { panic(err) }
	return re.find_all_str(str).map(it.u32())
}