# frozen_string_literal: true

require 'aws-sdk'
require_relative 'constants'

desc 'Deploy Jenkins Service'
task 'deploy:service' do
  cloudformation_client = Aws::CloudFormation::Client.new
  begin
    cloudformation_client.describe_stacks({
                                            stack_name: @service_name
                                          })
    begin
      Rake::Task['update:service'].invoke
    rescue StandardError
      puts 'No Updates'
    end
  rescue StandardError
    Rake::Task['create:service'].invoke
  end
end

desc 'Deploy Jenkins Service'
task 'deploy:cluster' do
  cloudformation_client = Aws::CloudFormation::Client.new
  begin
    cloudformation_client.describe_stacks({
                                            stack_name: @cluster_name
                                          })
    begin
      Rake::Task['update:cluster'].invoke
    rescue StandardError
      puts 'No Updates'
    end
  rescue StandardError
    Rake::Task['create:cluster'].invoke
  end
end

desc 'Create Jenkins ECS'
task 'create:service' do
  version = File.read(@version_url_path).to_s
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.create_stack(
    stack_name: @service_name,
    template_body: File.read('infrastructure/service.yaml').to_s,
    capabilities: ['CAPABILITY_IAM'],
    parameters: [
      {
        parameter_key: 'ImageUrl',
        parameter_value: "#{File.read(@ecr_repo_url_path)}/jenkins:#{version}"
      },
      {
        parameter_key: 'ParentStackName',
        parameter_value: @cluster_name
      },
      {
        parameter_key: 'ServiceName',
        parameter_value: @service_name
      }
    ]
  )

  cloudformation_client.wait_until(:stack_create_complete,
                                   stack_name: @service_name)

  puts "Cloudformation Stack: #{@service_name} created."
end

desc 'Update Jenkins ECS Service'
task 'update:service' do
  version = File.read(@version_url_path).to_s
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.update_stack(
    stack_name: @service_name,
    template_body: File.read('infrastructure/service.yaml').to_s,
    capabilities: ['CAPABILITY_IAM'],
    parameters: [
      {
        parameter_key: 'ImageUrl',
        parameter_value: "#{File.read(@ecr_repo_url_path)}/jenkins:#{version}"
      },
      {
        parameter_key: 'ParentStackName',
        parameter_value: @cluster_name
      },
      {
        parameter_key: 'ServiceName',
        parameter_value: @service_name
      }
    ]
  )

  cloudformation_client.wait_until(:stack_update_complete,
                                   stack_name: @service_name)

  puts "Cloudformation Stack: #{@service_name} updated."
end

desc 'Create Jenkins Infra'
task 'create:cluster' do
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.create_stack(
    stack_name: @cluster_name,
    template_body: File.read('infrastructure/cluster.yaml').to_s,
    capabilities: ['CAPABILITY_IAM']
  )

  cloudformation_client.wait_until(:stack_create_complete,
                                   stack_name: @cluster_name)

  puts "Cloudformation Stack: #{@cluster_name} created."
end

desc 'Update Jenkins ECS Cluster'
task 'update:cluster' do
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.update_stack(
    stack_name: @cluster_name,
    template_body: File.read('infrastructure/cluster.yaml').to_s,
    capabilities: ['CAPABILITY_IAM']
  )

  cloudformation_client.wait_until(:stack_update_complete,
                                   stack_name: @cluster_name)

  puts "Cloudformation Stack: #{@cluster_name} updated."
end
