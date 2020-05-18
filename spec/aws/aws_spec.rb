# frozen_string_literal: true

require_relative '../spec_helper'

describe ecs_cluster('jenkins-cluster') do
  it { should exist }
end
