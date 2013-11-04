**Bézier Ruby Gem**
==

A Ruby gem for creating Bézier curves.
A Bézier curve is technically not a curve, but a series of discreet values (which might look like a curve if plotted with large enough resolution). Allows you to create a curve by its control points, get specific point on that curve or iterate the curve points by an Enumerator.

Installation
------------

    > gem install bezier

Sample application
------------------

    require 'bezier'
    
    bez = Bezier::Curve.new(Bezier::ControlPoint.new(40, 250), Bezier::ControlPoint.new(50, 150), Bezier::ControlPoint.new(90, 220))
    
    puts bez.point_on_curve(0.2)
