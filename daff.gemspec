# coding: utf-8

# Relies on generated files - run "make rdist"

require 'json'
package = JSON.parse(IO.read("package.json"))

Gem::Specification.new do |spec|
  spec.name          = package["name"]
  spec.version       = package["version"]
  spec.authors       = ["James Smith", "Paul Fitzpatrick"]
  spec.email         = ["james@floppy.org.uk", "paul@robotrebuilt.com"]
  spec.description   = package["description"]
  spec.summary       = IO.read("README.md")
  spec.homepage      = package["url"]
  spec.license       = package["license"]

  spec.files         = Dir.glob("lib/**/*") + ["bin/daff.rb", "README.md"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
