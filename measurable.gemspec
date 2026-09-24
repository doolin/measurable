$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'measurable/version'

Gem::Specification.new do |gem|
  gem.name = 'measurable'
  gem.version = Measurable::VERSION
  gem.license = 'MIT'
  gem.summary = %(A Ruby gem with a lot of distance measures for your projects.)
  gem.description = 'Distance and similarity measures over arrays and other ' \
                    'enumerables: Euclidean, Minkowski, Chebyshev, cosine, ' \
                    'Jaccard, Tanimoto, Hamming, Levenshtein, Haversine, ' \
                    'max-min, Kullback-Leibler divergence, MVDM, and ' \
                    'weighted overlap.'

  gem.authors = ['Carlos Agarie', 'generall', 'David Doolin']
  gem.email = 'david.doolin@gmail.com'
  gem.homepage = 'https://github.com/doolin/measurable'

  gem.files         = `git ls-files`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 4.0'

  gem.add_dependency 'matrix'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rdoc', '~> 8.0'
  gem.add_development_dependency 'rspec', '~> 3.2'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-performance'
  gem.add_development_dependency 'rubocop-rspec'
  gem.metadata['rubygems_mfa_required'] = 'true'
end
