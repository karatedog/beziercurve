module Bezier

	class ControlPoint
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
		def to_curve
			CurvePoint.new(self.x, self.y)
		end
	end
	class CurvePoint < ControlPoint
		# @return [ControlPoint] the object converted into the expected format.
		def to_control
			ControlPoint.new(self.x, self.y)
		end
	end
	class Curve
		attr_accessor :controlpoints

		def initialize(*controlpoints)
			# need at least 3 control points
			if controlpoints.length < 3
				raise 'Cannot create Bézier curve with less than 3 control points'
			end

			# check for proper types
			if controlpoints.find {|p| p.class != ControlPoint} == nil
				@controlpoints = controlpoints
			end
		end

		def add(point)
			if point.class == ControlPoint
				@controlpoints << point
			else
				raise TypeError, 'Point should be type of ControlPoint'
			end
		end

		def point_on_curve(t)

			def point_on_hull(point1, point2, t) # making this local
				if (point1.class != ControlPoint) or (point2.class != ControlPoint)
					raise TypeError, 'Both points should be type of ControlPoint'
				end
				new_x = (point1.x - point2.x) * t
				new_y = (point1.y - point2.y) * t
				return ControlPoint.new(new_x, new_y)
			end

			# imperatively ugly but works, refactor later. point_on_curve and point_on_hull should be one method
			ary = @controlpoints
			return ary if ary.length <= 1 # zero or one element as argument, return unmodified

			while ary.length > 1
				temp = []
				0.upto(ary.length-2) do |index|
					memoize1 = point_on_hull(ary[index], ary[index+1], t)
					temp << ary[index+0] - memoize1
				end
				ary = temp
			end
			return temp[0].to_curve
		end

		def display_points # just a helper, for quickly put CotrolPOints to STDOUT in a gnuplottable format
			@controlpoints.map{|point| puts "#{point.x} #{point.y}"}
		end

		def enumerated(start_t, delta_t)
	  		Enumerator.new do |yielder|
	  			point_position = start_t.to_f
	    		number = point_on_curve(point_position)
	    		loop do
	      			yielder.yield(number)
	      			point_position += delta_t.to_f
	      			raise StopIteration if point_position > 1
	      			number = point_on_curve(point_position)
	    		end
	  		end
		end

		def order
			@controlpoints.length
		end
	end
end
