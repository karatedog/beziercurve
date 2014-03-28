**Bézier Ruby Gem**
==

A Ruby gem for creating and analyzing Bézier curves.
Allows you to create a Bézier curve by its control points, get specific point on that curve or iterate the curve points by an Enumerator. Inspired by [A Primer on Bézier Curves](http://pomax.github.io/bezierinfo/).

History
-------

0.7 - implemented the De Casteljau algorithm
0.8 - defined minimum Ruby version (2.0.0)


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

    or a nicer way:

    > bez = Bezier::Curve.new([40, 250], [50, 150], [90, 220])
    > puts bez.point_on_curve(0.2).x;
    45.2
    > puts bez.point_on_curve(0.2).y;
    216.8

