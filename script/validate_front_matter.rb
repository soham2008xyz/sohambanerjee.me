#!/usr/bin/env ruby
# Validates that every post in _posts/ has the required front matter
# documented in AGENTS.md, and that its image/image2 files exist on disk.

require 'yaml'

# 'categories' is required by convention but is always left blank on this
# blog (see AGENTS.md) - a blank key still counts as present.
REQUIRED_KEYS = %w[layout title date categories tags image image2].freeze
KEYS_ALLOWING_BLANK_VALUE = %w[categories].freeze

def front_matter(path)
  content = File.read(path)
  return nil unless content.start_with?('---')

  _, raw, _ = content.split(/^---\s*$/, 3)
  YAML.safe_load(raw, permitted_classes: [Time, Date], aliases: true) || {}
end

errors = []

Dir.glob('_posts/*.md').sort.each do |path|
  data = front_matter(path)

  if data.nil?
    errors << "#{path}: missing front matter block"
    next
  end

  REQUIRED_KEYS.each do |key|
    next if data.key?(key) && (data[key] != nil || KEYS_ALLOWING_BLANK_VALUE.include?(key))

    errors << "#{path}: missing required front matter key '#{key}'"
  end

  %w[image image2].each do |key|
    value = data[key]
    next if value.nil?

    image_path = value.to_s.sub(%r{\A/}, '')
    errors << "#{path}: #{key} '#{value}' does not exist" unless File.exist?(image_path)
  end
end

if errors.empty?
  puts "All #{Dir.glob('_posts/*.md').size} posts have valid front matter."
else
  errors.each { |e| warn "FAIL: #{e}" }
  warn "\n#{errors.size} front matter issue(s) found."
  exit 1
end
