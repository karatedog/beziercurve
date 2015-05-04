# Curve == series of ControlPoints

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

		# @param point [ControlPoint]
		#
    # @return [ControlPoint] Moves a ControlPoint
    # Moves Self by the 'point' as relative coordinates
    def movepoint (point)
			self.class.new(self.x + point.x, self.y + point.y)
		end

		def inspect
			return @x, @y
		end

		# @return [CurvePoint] Returns a ControlPoint, converted to CurvePoint (this is only a naming difference).
		def to_curvepoint
			CurvePoint.new(self.x, self.y)
		end

    # @return [Array] Returns an Array. The Array is fit to be as argument to Curve.new
    def to_a
			[self.x, self.y]
		end
	end

	class CurvePoint < ControlPoint
		# @return [ControlPoint] point coordinates on the Bézier curve.
		def to_controlpoint
			ControlPoint.new(self.x, self.y)
		end
	end

	class Curve
		# Returns the Bezier curve control points
		#
		# @return [Array<ControlPoints>]
		attr_accessor :controlpoints

		# @param controlpoints [Array<ControlPoints>, Array<(Fixnum, Fixnum)>] list of ControlPoints defining the hull for the Bézier curve. A point can be of class ControlPoint or an Array containig 2 Fixnums, which will be converted to ControlPoint.
		# @return [Curve] a Bézier curve object. The minimum number of control points is 3.
		# @example
		#    initialize(p1, p2, p3)
		#    initialize(p1, [20, 30], p3)
		def initialize(*controlpoints)
			
			# need at least 3 control points
			# this constraint has to be lifted, to allow adding Curves together like a 1 point curve to a 3 point curve
			if controlpoints.size < 3
				raise ArgumentError, 'Cannot create Bézier curve with less than 3 control points'
			end

			@controlpoints = controlpoints.map { |e|
				if e.class == Array
					ControlPoint.new(*e[0..1]) # make sure ControlPoint.new gets no more than 2 arguments. 'e' should contain at least 2 elements here
				elsif e.class == ControlPoint
					e
				else
					raise 'Control points should be type of ControlPoint or Array'
				end
			  }
		end

		# Adds a new control point to the Bezier curve as endpoint.
		#
		# @param [ControlPoint] point
		def add(point)
			if point.class == ControlPoint
				@controlpoints << point
			else
				raise TypeError, 'Point should be type of ControlPoint'
			end
		end

		# @param [CurvePoint] t
		def point_on_curve(t) # calculates the 'x,y' coordinates of a point on the curve, at the ratio 't' (remember, 0 <= t <= 1)

			def point_on_hull(point1, point2, t) # making this method local
				if (point1.class != ControlPoint) or (point2.class != ControlPoint)
					raise TypeError, 'Both points should be type of ControlPoint'
				end
				new_x = (point1.x - point2.x) * t
				new_y = (point1.y - point2.y) * t
				return ControlPoint.new(new_x, new_y)
			end

			# imperatively ugly, but works, refactor later. point_on_curve and point_on_hull should be one method
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
			temp[0].to_curvepoint
		end

		# Ye' olde factorial function
		#
		# @param n [Fixnum] 
		# @todo this is slow, should be rewritten
		# @example
		#   > fact(5)
		def self.fact(n)
			(1..n).reduce(:*)
		end

		# @param n [Fixnum]
		# @param k [Fixnum]
		# standard 'n choose k'
		def self.binomial(n,k) 
			return 1 if n-k <= 0
			return 1 if k <= 0
			fact(n) / ( fact(k) * fact( n - k ) )
		end

		# Returns the specified line from the Pascal triangle as an Array
		# @todo memoize already created lines or precalculate a few ten lines
		# @return [Array] A line from the Pascal triangle
		def self.pascaltriangle(nth_line) # Classic Pascal triangle
			(0..nth_line).map { |e| binomial(nth_line, e) }
		end

		def point_on_curve_binom(t)

			# locally scoped, we don't need it outside of point_on_curve_binom

			coeffs = self.class.pascaltriangle(self.order)
			coeffs.reduce { |memo, obj|
				memo += t**obj * (1-t)** (n - obj)
			}
		end

		def display_points # just a helper, for quickly put ControlPoints to STDOUT in a gnuplottable format
			@controlpoints.map{|point| puts "#{point.x} #{point.y}"}
		end

		# returns a new Enumerator that iterates over the Bezier curve from [start_t] to 1 by [delta_t] steps.
		def enumerated(start_t, delta_t)
	  		Enumerator.new do |yielder|
	  			point_position = start_t.to_f
	    		number = point_on_curve(point_position)
	    		loop do
	      			yielder.yield(number)
	      			point_position += delta_t.to_f
	      			raise StopIteration if point_position > 1.0
	      			number = point_on_curve(point_position)
	    		end
	  		end
		end

		# returns the order of the Bezier curve, aka the number of control points.
		def order
			@controlpoints.size
		end
	end
end