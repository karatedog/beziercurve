**Bézier Ruby Gem** {#welcome}
==

A Ruby gem for creating Bézier curves.
A Bézier curve is technically not a curve, but a series of discreet values (which might look like a curve if plotted with large enough resolution). Allows you to create a curve by its control points, get specific point on that curve or iterate the curve points by an Enumerator.

Installation
------------

    > gem install bezier

Sample application
------------------

    require 'bezier'
    
    b = Bezier.new(ControlPoint.new([40, 250]), ControlPoint.new([50, 150]), ControlPoint.new([90, 220]))
    
    puts b.point_on_curve(0.2)
