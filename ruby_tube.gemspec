# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby_tube}
  s.version = "0.2.2"
	
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

	s.add_dependency("gdata", ">= 1.1.0")
	s.add_dependency("httparty", ">= 0.4.3")
	s.add_dependency("hpricot", ">= 0.8.1")

  s.authors = ["Mike Green"]
  s.date = %q{2009-07-13}
  s.email = %q{mike.is.green@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/ruby_tube.rb",
     "lib/yt_client.rb",
     "lib/yt_comment.rb",
     "lib/yt_rating.rb",
     "lib/yt_video.rb",
     "test/josh_walking.mp4",
     "test/ruby_tube_test.rb",
     "test/test_helper.rb",
     "test/yt_client_test.rb"
  ]
  s.homepage = %q{http://github.com/mikedamage/ruby_tube}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Simple Ruby library for uploading and finding YouTube videos.}
  s.test_files = [
    "test/ruby_tube_test.rb",
     "test/test_helper.rb",
     "test/yt_client_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
