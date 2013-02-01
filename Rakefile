require 'rubygems'
require 'rake'
require 'date'

#############################################################################
#
# Helper functions
#
#############################################################################

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  line = File.read("lib/#{name}.rb")[/^\s*VERSION\s*=\s*.*/]
  line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
end

def date
  Date.today.to_s
end

def rubyforge_project
  name
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

def replace_header(head, header_name)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{send(header_name)}'"}
end

#############################################################################
#
# Standard tasks
#
#############################################################################

unless ENV['BUILD']
  # Determine where the RSpec plugin is by loading the boot
  unless defined? RADIANT_ROOT
    ENV["RAILS_ENV"] = "test"
    case
    when ENV["RADIANT_ENV_FILE"]
      require File.dirname(ENV["RADIANT_ENV_FILE"]) + "/boot"
    when File.dirname(__FILE__) =~ %r{vendor/radiant/vendor/extensions}
      require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../")}/config/boot"
    else
      require "#{File.expand_path(File.dirname(__FILE__) + "/../../../")}/config/boot"
    end
  end

  require 'rake'
  require 'rdoc/task'
  require 'rake/testtask'

  rspec_base = File.expand_path(RADIANT_ROOT + '/vendor/plugins/rspec/lib')
  $LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)
  require 'spec/rake/spectask'
  require 'cucumber'
  require 'cucumber/rake/task'

  # Cleanup the RADIANT_ROOT constant so specs will load the environment
  Object.send(:remove_const, :RADIANT_ROOT)

  extension_root = File.expand_path(File.dirname(__FILE__))

  task :default => [:spec, :features]
  task :stats => "spec:statsetup"

  desc "Run all specs in spec directory"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_opts = ['--options', "\"#{extension_root}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  task :features => 'spec:integration'

  namespace :spec do
    desc "Run all specs in spec directory with RCov"
    Spec::Rake::SpecTask.new(:rcov) do |t|
      t.spec_opts = ['--options', "\"#{extension_root}/spec/spec.opts\""]
      t.spec_files = FileList['spec/**/*_spec.rb']
      t.rcov = true
      t.rcov_opts = ['--exclude', 'spec', '--rails']
    end
    
    desc "Print Specdoc for all specs"
    Spec::Rake::SpecTask.new(:doc) do |t|
      t.spec_opts = ["--format", "specdoc", "--dry-run"]
      t.spec_files = FileList['spec/**/*_spec.rb']
    end

    [:models, :controllers, :views, :helpers].each do |sub|
      desc "Run the specs under spec/#{sub}"
      Spec::Rake::SpecTask.new(sub) do |t|
        t.spec_opts = ['--options', "\"#{extension_root}/spec/spec.opts\""]
        t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
      end
    end
    
    desc "Run the Cucumber features"
    Cucumber::Rake::Task.new(:integration) do |t|
      t.fork = true
      t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty')]
      # t.feature_pattern = "#{extension_root}/features/**/*.feature"
      t.profile = "default"
    end

    # Setup specs for stats
    task :statsetup do
      require 'code_statistics'
      ::STATS_DIRECTORIES << %w(Model\ specs spec/models)
      ::STATS_DIRECTORIES << %w(View\ specs spec/views)
      ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers)
      ::STATS_DIRECTORIES << %w(Helper\ specs spec/views)
      ::CodeStatistics::TEST_TYPES << "Model specs"
      ::CodeStatistics::TEST_TYPES << "View specs"
      ::CodeStatistics::TEST_TYPES << "Controller specs"
      ::CodeStatistics::TEST_TYPES << "Helper specs"
      ::STATS_DIRECTORIES.delete_if {|a| a[0] =~ /test/}
    end

    namespace :db do
      namespace :fixtures do
        desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
        task :load => :environment do
          require 'active_record/fixtures'
          ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
          (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'spec', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
            Fixtures.create_fixtures('spec/fixtures', File.basename(fixture_file, '.*'))
          end
        end
      end
    end
  end

  desc 'Generate documentation for the CK Editor filter extension.'
  RDoc::Task.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title    = 'Radiant CK Editor filter extension'
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('README')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end

  # Load any custom rakefiles for extension
  Dir[File.dirname(__FILE__) + '/tasks/*.rake'].sort.each { |f| require f }
end

#############################################################################
#
# Custom tasks (add your own tasks here)
#
#############################################################################



#############################################################################
#
# Packaging tasks
#
#############################################################################

desc "Create tag v#{version} and build and push #{gem_file} to Rubygems"
task :release => :build do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag v#{version}"
  sh "git push origin master"
  sh "git push origin v#{version}"
  sh "gem push pkg/#{name}-#{version}.gem"
end

desc "Build #{gem_file} into the pkg directory"
task :build => :gemspec do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end

desc "Generate #{gemspec_file}"
task :gemspec => :validate do
  # read spec file and split out manifest section
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")

  # replace name version and date
  replace_header(head, :name)
  replace_header(head, :version)
  replace_header(head, :date)
  #comment this out if your rubyforge_project has a different name
  replace_header(head, :rubyforge_project)

  # determine file list from git ls-files
  files = `git ls-files`.
    split("\n").
    sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg)/ }.
    map { |file| "    #{file}" }.
    join("\n")

  # piece file back together and write
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w') { |io| io.write(spec) }
  puts "Updated #{gemspec_file}"
end

desc "Validate #{gemspec_file}"
task :validate do
  libfiles = Dir['lib/*'] - ["lib/#{name}.rb", "lib/#{name}"]
  unless libfiles.empty?
    puts "Directory `lib` should only contain a `#{name}.rb` file and `#{name}` dir."
    #exit!
  end
  unless Dir['VERSION*'].empty?
    puts "A `VERSION` file at root level violates Gem best practices."
    exit!
  end
end
