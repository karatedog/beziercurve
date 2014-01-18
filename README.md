**Bézier Ruby Gem**
==

A Ruby gem for creating and analyzing Bézier curves.
A Bézier curve is technically not a curve, but a series of discreet values (which might look like a curve if plotted with large enough resolution). Allows you to create a curve by its control points, get specific point on that curve or iterate the curve points by an Enumerator. Inspired by [A Primer on Bézier Curves](http://pomax.github.io/bezierinfo/).

History
-------

0.7.0 - De Casteljau algorithm is implemented


Installation
------------

    > gem install beziercurve

Sample
------------------

    > require 'beziercurve'
    > bez = Bezier::Curve.new(Bezier::ControlPoint.new(40, 250), Bezier::ControlPoint.new(50, 150), Bezier::ControlPoint.new(90, 220))
    > puts bez.point_on_curve(0.2).x;
    45.2
    > puts bez.point_on_curve(0.2).y;
    216.8

