#!/usr/local/bin/ruby

LEFT = -1
EQUAL = 0
RIGHT = 1
$seesaw_usage = 0

def generateIslanders(perpIndex, perpWeight)
	islanders = []

	Array(0..11).each do |i|
		islanders[i] = {'i': i, 'v': i != perpIndex ? 0 : perpWeight}
	end

	puts "with perp #{perpIndex}, weight: #{perpWeight}"
	return islanders
end

def seesaw(left, right) 
	$seesaw_usage += 1
	leftSum = left.kind_of?(Array) ? left.map{|x| x[:v]}.reduce(:+) : left[:v]
	rightSum = right.kind_of?(Array) ? right.map{|x| x[:v]}.reduce(:+) : right[:v]

	return EQUAL if leftSum == rightSum
	return LEFT if leftSum > rightSum
	return RIGHT if rightSum > leftSum
end

def investigate(islanders)
	$seesaw_usage = 0
	result = -1

	# split group into 3 of 4s (for easy understanding, a0~3, b0~3, c0~3) and compare a and b
	a = islanders[0..3]
	b = islanders[4..7]
	c = islanders[8..11]
	first_result = seesaw(a, b)

	if first_result == EQUAL
		# dude must be in c split group into c0,c1 and c2,a0 and compare
		second_result = seesaw([c[0],c[1]], [c[2], a[0]])
		if second_result == EQUAL
			# if second result is equal, the result can only be c3
			result = c[3]
		else
			# if second result is different, compare c0,c1
			third_result = seesaw(c[0], c[1])
			result = c[0] if second_result == third_result
			result = c[1] if second_result != third_result
			result = c[2] if third_result == EQUAL
		end
	else
		# if right side is heavier, swap a and b so that a is always heavier than b
		if first_result == RIGHT
			tmp_a = a
			a = b
			b = tmp_a
		end
		# split group into a0,b0,b1 | b2,b3,c8 | a1,a2,a3 and compare 1st two
		second_result = seesaw([a[0], b[0], b[1]], [b[2], b[3], c[0]])

		if second_result == EQUAL
			# result must be from a1,a2,a3 and must be heavier than the other
			third_result = seesaw(a[1], a[2])
			result = a[3] if third_result == EQUAL
			result = a[1] if third_result == LEFT
			result = a[2] if third_result == RIGHT
		else
			if second_result == LEFT
				# result must be a0 or lighter of b2,b3
				third_left = b[2]
				third_right = b[3]
			else
				# result must be lighter of b0,b1
				third_left = b[0]
				third_right = b[1]
			end
			third_result = seesaw(third_left, third_right)
			result = a[0] if third_result == EQUAL
			result = third_right if third_result == LEFT
			result = third_left if third_result == RIGHT
		end
	end

	puts "result: perp #{result[:i]}, seesaw usage #{$seesaw_usage}"
	return result[:i]
end

# test every permutation
Array(0..11).each do |i|
	result = investigate(generateIslanders(i, 1))
	if result != i
		puts "not working for heavy perp #{i}"
		return
	end

	result = investigate(generateIslanders(i, -1))
	if result != i
		puts "not working for light perp #{i}"
		return
	end

	puts "all correct!"
end