# frozen_string_literal: true

require 'docker'
require 'serverspec'

describe 'Dockerfile' do
  before(:all) do
    set :os, family: :debian
    set :backend, :docker
    set :docker_image, ENV['DOCKER_IMAGE_ID']
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
    # it { should belong_to_group 'nobody' }
  end

  describe port(8080) do
    it { should be_listening }
  end
end
