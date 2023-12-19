module day19

import datatypes

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) i64 {
	workflows, parts := parse_data(data)
	mut sum := 0
	mut workflow := ''
	for part in parts {
		 workflow = 'in'
		for {
			rules := workflows[workflow]
			mut target := ''
			for rule in rules {
				applied, tg := rule.apply(part)
				if applied {
					target = tg
					break
				}
			}
			if target == 'A' {
				// println('ACCEPTED ${part}')
				sum += part.sum()
				break
			} else if target == 'R' {
				// println('REJECTED ${part}')
				break
			} else {
				workflow = target
			}
		}
	}
	return sum
}

fn part_2(data string) u64 {
	workflows, _ := parse_data(data)
	mut sum := u64(0)
	mut stack := datatypes.Stack[RangeState]{}
	stack.push(RangeState{PartRanges{Range{1, 4000}, Range{1, 4000}, Range{1, 4000}, Range{1, 4000}}, 'in'})
	for {
		if stack.is_empty() {
			break
		}
		state := stack.pop() or { panic(err) }
		rules := workflows[state.target]
		// println(state.target)

		mut new_state := state
		mut dual_ranges := state.PartRanges
		for rule in rules {
			new_state, dual_ranges = rule.apply_range(dual_ranges)
			// println(new_state)
			// println(dual_ranges)
			if new_state.PartRanges.is_valid() {
				if new_state.target == 'A' {
					sum += new_state.PartRanges.count();
				} else if new_state.target != 'R' {
					stack.push(new_state)
				}
			}
		}
	}
	return sum
}

interface Rule {
	apply(p Part) (bool, string)
	apply_range(p PartRanges) (RangeState, PartRanges)
}

struct Unconditional {
	target string
}

fn (r Unconditional) apply(p Part) (bool, string) {
	return true, r.target
}

fn (r Unconditional) apply_range(p PartRanges) (RangeState, PartRanges) {
	return RangeState{p, r.target}, PartRanges{}
}

struct GreaterThan {
	cat string
	value int
	target string
}

fn (r GreaterThan) apply(p Part) (bool, string) {
	mut part_value := 0;
	match r.cat {
		'x' { part_value = p.x }
		'm' { part_value = p.m }
		'a' { part_value = p.a }
		's' { part_value = p.s }
		else { panic ('part category does not exist: ${r.cat}') }
	}
	return if part_value > r.value { true, r.target } else { false, '' }
}

fn (r GreaterThan) apply_range(p PartRanges) (RangeState, PartRanges) {
	match r.cat {
		'x' { return RangeState{PartRanges{Range{r.value+1, p.x.max}, p.m, p.a, p.s}, r.target }, PartRanges{Range{p.x.min, r.value}, p.m, p.a, p.s}}
		'm' { return RangeState{PartRanges{p.x, Range{r.value+1, p.m.max}, p.a, p.s}, r.target }, PartRanges{p.x, Range{p.m.min, r.value}, p.a, p.s}}
		'a' { return RangeState{PartRanges{p.x, p.m, Range{r.value+1, p.a.max}, p.s}, r.target }, PartRanges{p.x, p.m, Range{p.a.min, r.value}, p.s}}
		's' { return RangeState{PartRanges{p.x, p.m, p.a, Range{r.value+1, p.s.max}}, r.target }, PartRanges{p.x, p.m, p.a, Range{p.s.min, r.value}}}
		else { panic ('part category does not exist: ${r.cat}') }
	}
}

struct LowerThan {
	cat string
	value int
	target string
}

fn (r LowerThan) apply(p Part) (bool, string) {
	mut part_value := 0;
	match r.cat {
		'x' { part_value = p.x }
		'm' { part_value = p.m }
		'a' { part_value = p.a }
		's' { part_value = p.s }
		else { panic ('part category does not exist: ${r.cat}') }
	}
	return if part_value < r.value { true, r.target } else { false, '' }
}

fn (r LowerThan) apply_range(p PartRanges) (RangeState, PartRanges) {
	match r.cat {
		'x' { return RangeState{PartRanges{Range{p.x.min, r.value-1}, p.m, p.a, p.s}, r.target }, PartRanges{Range{r.value, p.x.max}, p.m, p.a, p.s}}
		'm' { return RangeState{PartRanges{p.x, Range{p.m.min, r.value-1}, p.a, p.s}, r.target }, PartRanges{p.x, Range{r.value, p.m.max}, p.a, p.s}}
		'a' { return RangeState{PartRanges{p.x, p.m, Range{p.a.min, r.value-1}, p.s}, r.target }, PartRanges{p.x, p.m, Range{r.value, p.a.max}, p.s}}
		's' { return RangeState{PartRanges{p.x, p.m, p.a, Range{p.s.min, r.value-1}}, r.target }, PartRanges{p.x, p.m, p.a, Range{r.value, p.s.max}}}
		else { panic ('part category does not exist: ${r.cat}') }
	}
}

struct Part {
	x int
	m int
	a int
	s int
}

fn (p Part) sum() int {
	return p.x + p.m + p.a + p.s
}

struct Range {
	min int
	max int
}

fn (r Range) len() int {
	return r.max-r.min+1
}

fn (r Range) is_valid() bool {
	return r.min < r.max
}

struct PartRanges {
	x Range
	m Range
	a Range
	s Range
}

fn (p PartRanges) is_valid() bool {
	return p.x.is_valid() && p.m.is_valid() && p.a.is_valid() && p.s.is_valid() 
}

fn (p PartRanges) count() u64 {
	return u64(p.x.len()) * u64(p.m.len()) * u64(p.a.len()) * u64(p.s.len()) 
}

struct RangeState {
	PartRanges
	target string
}

fn parse_data(data string) (map[string][]Rule, []Part) {
	lines := data.split_into_lines()

	for i, line in lines {
		if line == '' {
			return parse_rules(lines[..i]), parse_parts(lines[i+1..lines.len])
		}
	}
	panic('Could not parse data')
}

fn parse_rules(lines []string) map[string][]Rule {
	mut workflows := map[string][]Rule{}

	for line in lines {
		mut rules := []Rule{}
		mut i := line.index('{') or { panic(err) }
		name := line[0..i]
		rules_str := line[i+1..line.len-1].split(',')
		last_rule := rules_str.last()
		for rule_str in rules_str[..rules_str.len-1] {
			condition := rule_str.split(':')[0]
			target := rule_str.split(':')[1]
			if condition.contains('>') {
				rules << GreaterThan{condition[0..1], condition[2..].int(), target}
			} else if condition.contains('<') {
				rules << LowerThan{condition[0..1], condition[2..].int(), target}
			}
		}
		rules << Unconditional{last_rule}
		workflows[name] = rules
	}
	 return workflows
}

fn parse_parts(lines []string) []Part {
	mut parts := []Part{}

	for line in lines {
		categories := line[1..line.len-1].split(',')
		parts << Part{
			categories[0].split('=')[1].int(),
			categories[1].split('=')[1].int(), 
			categories[2].split('=')[1].int(), 
			categories[3].split('=')[1].int()
		}
	}
	return parts
}
