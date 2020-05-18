# frozen_string_literal: true

require 'rake'
require 'rspec/core/rake_task'
require_relative 'constants'

desc 'Run tests'
RSpec::Core::RakeTask.new('jenkins:test') do |t|
  ENV['DOCKER_IMAGE_ID'] = File.read(@image_id_path)
  t.pattern = 'spec/*_spec.rb'
end

desc 'Infrastructure Tests'
RSpec::Core::RakeTask.new('infra:test') do |t|
  ENV['DOCKER_IMAGE_ID'] = File.read(@image_id_path)
  t.pattern = 'spec/aws/*_spec.rb'
end
