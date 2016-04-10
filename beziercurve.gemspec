Gem::Specification.new do |s|
  s.name        = 'beziercurve'
  s.version     = '0.8.4'
  s.date        = '2016-04-10'
  s.summary     = "Create and analyze Bézier curves"
  s.description = "Creates a Bézier curve by its control points. Implemented with de Casteljau method."
  s.required_ruby_version = '>= 2.0.0'  
  s.authors     = ["Földes László"]
  s.email       = 'foldes.laszlo2@gmail.com'
  s.files       = Dir["{lib,test}/**/*.{rb,md}"] + Dir["*.{md,rdoc}"]
  s.homepage    = 'https://github.com/karatedog/beziercurve'
  s.license	    = "MIT"
end
