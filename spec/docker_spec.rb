# frozen_string_literal: true

require 'docker'
require 'serverspec'

describe 'Dockerfile' do
  before(:all) do
    image = Docker::Image.build_from_dir('.')
    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image.id
  end

  [
    '/var/jenkins_home/plugins.txt'
  ].each do |file|
    describe file(file.to_s) do
      it { should exist }
      it { should be_file }
    end
  end

  describe user('jenkins') do
    it { should exist }
    it { should belong_to_group 'jenkins' }
  end
end
