
class ControlPoint
	# maybe replace the accessors and initialization with Struct
	attr_accessor :x, :y
	def initialize(x,y)
		@x = x
		@y = y
	end
	def - (b)
		self.class.new(self.x - b.x, self.y - b.y)
	end
	def + (b)
		self.class.new(self.x + b.x, self.y + b.y)
	end
	def inspect
		return @x, @y
	end
end

class Bezier
	attr_accessor :hullpoints

	def initialize(hullpoints)
		# need at least 3 control points
		if hullpoints.length < 3 then
			raise "Cannot create Bézier curve with less than 3 control points" 
		end

		# check for rogue value
		if hullpoints.find {|p| p.class != ControlPoint} == nil
			@hullpoints = hullpoints
		end
	end

	def add(point)
		if point.class == ControlPoint
			@hullpoints << point
		else
			raise TypeError, "Point should be type of ControlPoint"
		end
	end

	def point_on_line(point1, point2, t)
		if (point1.class != ControlPoint) or (point2.class != ControlPoint)
			raise TypeError, "Both points should be type of ControlPoint"
		end
		new_x = (point1.x - point2.x) * t
		new_y = (point1.y - point2.y) * t
		return ControlPoint.new(new_x, new_y)
	end

	def display_points # just a helper, for quickly put coords to STDOUT in a gnuplottable format
		@hullpoints.map{|point| puts "#{point.x} #{point.y}"}
	end

	def curve_point(t)
		# imperatively ugly but works, refactor later
		ary = @hullpoints
		return ary if ary.length <= 1 # zero or one element as argument, return unmodified

		while ary.length > 1
			temp = []
			0.upto(ary.length-2) do |index|
				memoize1 = point_on_line(ary[index], ary[index+1], t) 
				temp += [ ary[index+0] - memoize1 ]
			end
			ary = temp
		end
		return temp[0]
	end
end

bezier = Bezier.new([ControlPoint.new(40,250),
					 ControlPoint.new(35,100),
					 ControlPoint.new(150,70),
					 ControlPoint.new(210,120)]) # cubic curve, 4 coordinates


puts "#{bezier.curve_point(0.013).x} #{bezier.curve_point(0.013).y}"
