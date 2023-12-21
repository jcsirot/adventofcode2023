module day20

import datatypes
import math

pub fn solve(data string) {
	// println('data:\n${data}')

	println('part 1: ${part_1(data)}')
	println('part 2: ${part_2(data)}')
}

fn part_1(data string) i64 {
	modules := parse_data(data)
	// println(modules)
	mut low := 0
	mut high := 0
	mut queue := datatypes.Queue[Step]{}
	for _ in 0..1000 {
		queue.push(Step{Pulse.low, 'button', 'broadcaster'})
		for {
			// println(queue)
			if queue.is_empty() {
				break
			}
			step := queue.pop() or { panic('FOO ${err}') }
			if step.pulse == Pulse.high {
				high++
			} else {
				low++
			}
			if !(step.to in modules) {
				continue
			}
			mut mod := modules[step.to] or { panic(step.to) }
			pulse := mod.handle(step.pulse, step.from)
			if pulse == Pulse.@none {
				continue
			}
			for output in mod.output {
				queue.push(Step{pulse, mod.name, output})
			}
		}
	}
	return low * high 
}

fn part_2(data string) i64 {
	// modules := parse_data(data)

	groups := parse_data_part_2(data)
	
	/*
	println('digraph G {')
	for mod in modules.values() {
		for out in mod.output {
			println('${mod.name} -> ${out};')
			match mod.typ() {
				'FlipFlop' { println('${mod.name} [shape=triangle];') }
				'Conjonction' { println('${mod.name} [shape=hexagon];') }
				else {}
			}
		}
	}
	println('}')
	*/
		
	mut cycles := i64(1)
	for modules in groups {
		cycles = math.lcm(cycles, compute_press_count(modules))
	}
	return cycles
}

fn compute_press_count(modules map[string]Module) int {
	mut queue := datatypes.Queue[Step]{}
	for counter := 1 ;; counter++ {
		queue.push(Step{Pulse.low, 'button', 'broadcaster'})
		for {
			// println(queue)
			if queue.is_empty() {
				break
			}
			step := queue.pop() or { panic(err) }
			if !(step.to in modules) {
				if step.to == 'rx' && step.pulse == Pulse.low {
					return counter
				}
				continue
			}
			mut mod := modules[step.to] or { panic(step.to) }
			pulse := mod.handle(step.pulse, step.from)
			if pulse == Pulse.@none {
				continue
			}
			for output in mod.output {
				queue.push(Step{pulse, mod.name, output})
			}
		}
	}
	return 0
}

enum Pulse {
	@none // for testing purpose
	low
	high
}

struct Step {
	pulse Pulse
	from string
	to string
}

interface Module {
	name string
	output []string
	typ() string
mut:
	handle(pulse Pulse, from string) Pulse
}

struct FlipFlop {
	name string
	output []string
mut:
	on bool
}

fn (m FlipFlop) typ() string {
	return 'FlipFlop'
}

fn (mut m FlipFlop) handle(pulse Pulse, from string) Pulse {
	if pulse == Pulse.low {
		m.on = !m.on
		return if m.on {Pulse.high} else {Pulse.low}
	}
	return Pulse.@none
}

struct Conjonction {
	name string
	output []string
mut:
	memory map[string]Pulse
}

fn (m Conjonction) typ() string {
	return 'Conjonction'
}

fn (mut m Conjonction) init(input []string) {
	for mod in input {
		m.memory[mod] = Pulse.low
	}
}

fn (mut m Conjonction) handle(pulse Pulse, from string) Pulse {
	m.memory[from] = pulse
	if m.memory.values().all(fn (p Pulse) bool { return p == Pulse.high }) {
		return Pulse.low
	}
	return Pulse.high
}

struct Broadcaster {
	name string
	output []string
}

fn (m Broadcaster) typ() string {
	return 'Broadcaster'
}

fn (m Broadcaster) handle(pulse Pulse, from string) Pulse {
	return pulse
}

fn parse_data(data string) map[string]Module {
	lines := data.split_into_lines()
	return parse_modules(lines)
}

fn parse_data_part_2(data string) []map[string]Module {
	lines := data.split_into_lines()

	mut module_map := map[string]string{}

	for line in lines {
		if line.starts_with('broadcaster ->') {
			module_map['broadcaster'] = line
		} else if line.starts_with('%') || line.starts_with('&') {
			name := line[1..].split( ' -> ')[0]
			module_map[name] = line
		}
	}

	roots := get_next_module_names(module_map['broadcaster'])
	mut groups := [][]string{}
	for root in roots {
		mut stack := datatypes.Stack[string]{}
		mut names := []string{}
		stack.push(root)
		for {
			if stack.is_empty() {
				break
			}
			name := stack.pop() or { panic(err) }
			if name == 'rx' {
				continue
			}
			if names.contains(name) {
				continue
			} else {
				names << name
			}
			for next in get_next_module_names(module_map[name]) {
				stack.push(next)
			}	
			// println(name)
			// println(stack)
			
		}
		names << 'broadcaster'
		groups << names.map(module_map[it])
	}

	return groups.map(parse_modules(it))
}


fn parse_modules(lines []string) map[string]Module {
	mut modules := map[string]Module{}
	for line in lines {
		output := get_next_module_names(line)
		if line.starts_with('broadcaster ->') {
			modules['broadcaster'] = Broadcaster{'broadcaster', output}
		} else if line.starts_with('%') {
			name := line[1..].split( ' -> ')[0]
			modules[name] = FlipFlop{name, output, false}	
		}  else if line.starts_with('&') {
			name := line[1..].split( ' -> ')[0]
			modules[name] = Conjonction{name, output, map[string]Pulse{}}	
		}
	}

	// init conjonction
	for line in lines {
		if line.starts_with('&') {
			mut input := map[string]Pulse{}
			name := line[1..].split( ' -> ')[0]
			for m in modules.values() {
				if m.output.contains(name) {
					input[m.name] = Pulse.low
				}
			}
			modules[name] = Conjonction{name, modules[name].output, input}
		}
	}

	return modules
}

fn get_next_module_names(line string) []string {
	return line.split(' -> ')[1].split(', ')
}
