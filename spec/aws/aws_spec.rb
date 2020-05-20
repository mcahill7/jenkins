# frozen_string_literal: true

require_relative '../spec_helper'

describe ecs_cluster('jenkins-cluster') do
  it { should exist }
end

describe alb('jenkins-alb') do
  it { should exist }
  its(:scheme) { should eq 'internet-facing' }
  its(:type) { should eq 'application' }
  its(:ip_address_type) { should eq 'ipv4' }
end
