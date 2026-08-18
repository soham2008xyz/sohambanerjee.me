require 'html-proofer'

task :build do
  sh 'bundle exec jekyll build'
end

namespace :test do
  desc 'Validate required front matter on all posts'
  task :frontmatter do
    ruby 'script/validate_front_matter.rb'
  end

  desc 'Check an already-built _site/ for broken links, images, and missing alt text'
  task :html_only do
    HTMLProofer.check_directory(
      './_site',
      disable_external: ENV['HTMLPROOFER_EXTERNAL'] != '1'
    ).run
  end

  desc 'Build then check the site for broken links, images, and missing alt text'
  task html: [:build, :html_only]
end

desc 'Run all local checks'
task test: ['test:frontmatter', 'test:html']
