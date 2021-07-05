# Curve == series of ControlPoints

module Bezier
	class ControlPoint
		attr_accessor :x, :y

    # @param x [Numeric]
    # @param y [Numeric]
    #
    # Creates a new control point for the Bézier curve
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
    # @return [ControlPoint] A ControlPoint in a new position
    # Moves a controlpoint with relative distance
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

    # @return [Array]
    # Returns the control point as an array => [x, y]. The Array is fit to be as argument for ControlPoint.new
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
    # defaults
    DeCasteljau = :decasteljau
    Bernstein = :bernstein

    # this should have been instance variable in the first place, correcting '@@...'
    @calculation_method = Bernstein

		@@fact_memoize = Hash.new
		@@binomial_memoize = Hash.new
		@@pascaltriangle_memoize = Hash.new

		# Ye' olde factorial function
		#
		# @param n [Fixnum]
		# @example
		#   > fact(5)
		def self.fact(n)
			@@fact_memoize[n] ||= (1..n).reduce(:*)
    end

		# @param n [Fixnum]
		# @param k [Fixnum]
		# standard 'n choose k'
		def self.binomial(n,k)
			return 1 if n-k <= 0
			return 1 if k <= 0
			@@binomial_memoize[[n,k]] ||= fact(n) / ( fact(k) * fact( n - k ) )
    end

		# Returns the specified line from the Pascal triangle as an Array
		# @return [Array] A line from the Pascal triangle
		# @example
		#   > pascaltriangle(6)
		def self.pascaltriangle(nth_line) # Classic Pascal triangle
			@@pascaltriangle_memoize[nth_line] ||= (0..nth_line).map { |e| binomial(nth_line, e) }
    end

		# Returns the Bezier curve control points
		#
		# @return [Array<ControlPoints>]

		attr_accessor :controlpoints

		# @param controlpoints [Array<ControlPoints>, Array<(Fixnum, Fixnum)>] list of ControlPoints defining the hull for the Bézier curve. A point can be of class ControlPoint or an Array containig 2 Numerics, which will be converted to ControlPoint.
		# @return [Curve] Creates a new Bézier curve object. The minimum number of control points is currently 3.
		# @example
		#    initialize(p1, p2, p3)
		#    initialize(p1, [20, 30], p3)
		def initialize(*controlpoints)

			# need at least 3 control points
			# this constraint has to be lifted, to allow adding Curves together like a 1 point curve to a 3 point curve
			if controlpoints.size < 3
				raise ArgumentError, 'Cannot create curve with less than 3 control points'
			end

			@controlpoints = controlpoints.map { |point|
				if point.class == Array
					ControlPoint.new(*point[0..1]) # ControlPoint.new gets no more than 2 arguments, excess values are ignored
				elsif point.class == ControlPoint
					point
				else
					raise 'Control points should be type of ControlPoint or Array'
				end
			  }
		end

		# Adds a new control point to the Bezier curve as endpoint.
		#
		# @param [ControlPoint, Array] point
		def add(point)
      @controlpoints << case point
                        when ControlPoint
                          point
                        when Array
                          ControlPoint.new(*point[0..1])
                        else
                          raise(TypeError, 'Point should be type of ControlPoint')
                        end

			# if point.class == ControlPoint
			# 	@controlpoints << point
   #    elsif point.class == Array
   #      @controlpoints << ControlPoint.new(*point[0..1])
			# else
			# 	raise TypeError, 'Point should be type of ControlPoint'
			# end
		end

		# @param [CurvePoint] t
		def point_on_curve(t) # calculates the 'x,y' coordinates of a point on the curve, at the ratio 't' (0 <= t <= 1)
      case
        when @calculation_method == DeCasteljau
          poc_with_decasteljau(t)
        when @calculation_method == Bernstein
          poc_with_bernstein(t)
        else
          poc_with_bernstein(t) # default
      end
    end
    alias_method :poc, :point_on_curve

		def poc_with_bernstein(t)
			n = @controlpoints.size-1
      sum = [0,0]
      for k in 0..n
      	sum[0] += @controlpoints[k].x * self.class.binomial(n,k) * (1-t)**(n-k) * t**k
      	sum[1] += @controlpoints[k].y * self.class.binomial(n,k) * (1-t)**(n-k) * t**k
      end
      return ControlPoint.new(*sum)
      #poc_with_decasteljau(t)
    end

    def point_on_hull(point1, point2, t) # just realized this was nested (geez), Jörg.W.Mittag would have cried. So it is moved out from poc_with_decasteljau()
      if (point1.class != ControlPoint) or (point2.class != ControlPoint)
        raise TypeError, 'Both points should be type of ControlPoint'
      end
      new_x = (1-t) * point1.x + t * point2.x
      new_y = (1-t) * point1.y + t * point2.y
      return ControlPoint.new(new_x, new_y)
    end

    def poc_with_decasteljau(t)
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

		def point_on_curve_binom(t)
			coeffs = self.class.pascaltriangle(self.order)
			coeffs.reduce do |memo, obj|
				memo += t**obj * (1-t)** (n - obj)
			end
		end


		def gnuplot_hull # was recently 'display_points'. just a helper, for quickly put ControlPoints to STDOUT in a gnuplottable format
			@controlpoints.map{|point| [point.x, point.y] }
		end

		def gnuplot_points(precision)
		end

		# returns a new Enumerator that iterates over the Bezier curve from [start_t] to 1 by [delta_t] steps.
		def enumerated(start_t, delta_t)
	  		Enumerator.new do |yielder|
	  			#TODO only do the conversion if start_t is not Float, Fractional or Bigfloat
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

# Bernstein calculation is finished, that is the default
# DeCasteljau still has bugs 
# renamed display_points to gnuplot_hull (this displays Hull coordinates)
# created gnuplot_points (this displays Curve points, uses the enumerated method to iterate over the curve)
# TODO: make sure the original CurvePoint argument type won't get converted. If someone created a new Bezier instance with Bigfloat as CurvePoints, it should stay Bigfloat during the entire calculation
