# frozen_string_literal: true

require_relative '../spec_helper'

describe ecs_cluster('jenkins-cluster-ECSCluster-oGlvtt5TDJK2') do
  it { should exist }
end
