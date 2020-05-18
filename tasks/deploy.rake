# frozen_string_literal: true

require 'aws-sdk'
require_relative 'constants'

desc 'Build and Deploy Jenkins'
task 'jenkins:e2e' do
  if ENV['AWS_ACCOUNT_ID'].nil?
    raise 'Set environment variable AWS_ACCOUNT_ID and try again.'
  end

  %w[
    ecr:create
    docker:build
    jenkins:test
    docker:tag
    docker:push
    service:create
    infra:test
  ].each do |task_name|
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke
  end
end

desc 'Deploy Jenkins Service'
task 'deploy:service' do
  cloudformation_client = Aws::CloudFormation::Client.new
  begin
    cloudformation_client.describe_stacks({
                                            stack_name: @service_name
                                          })
    Rake::Task['update:service'].invoke
  rescue StandardError => e
    Rake::Task['create:service'].invoke
  else
  end
end

desc 'Deploy Jenkins Service'
task 'deploy:cluster' do
  cloudformation_client = Aws::CloudFormation::Client.new
  begin
    cloudformation_client.describe_stacks({
                                            stack_name: @service_name
                                          })
    Rake::Task['update:cluster'].invoke
  rescue StandardError => e
    Rake::Task['create:service'].invoke
  else
  end
end

desc 'Create Jenkins ECS'
task 'create:service' do
  version = File.read(@version_url_path).to_s
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.create_stack(
    stack_name: @service_name,
    template_body: File.read('infrastructure/service.yaml').to_s,
    parameters: [
      {
        parameter_key: 'AppImage',
        parameter_value: "#{File.read(@ecr_repo_url_path)}/jenkins:#{version}"
      },
      {
        parameter_key: 'AppPort',
        parameter_value: '8080'
      },
      {
        parameter_key: 'AppCommand',
        parameter_value: ''
      }
    ]
  )

  cloudformation_client.wait_until(:stack_create_complete,
                                   stack_name: @service_name)

  puts "Cloudformation Stack: #{@service_name} created."
end

desc 'Update Jenkins ECS' Service
task 'update:service' do
  version = File.read(@version_url_path).to_s
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.update_stack(
    stack_name: @service_name,
    template_body: File.read('infrastructure/service.yaml').to_s,
    parameters: [
      {
        parameter_key: 'AppImage',
        parameter_value: "#{File.read(@ecr_repo_url_path)}/jenkins:#{version}"
      },
      {
        parameter_key: 'AppPort',
        parameter_value: '8080'
      },
      {
        parameter_key: 'AppCommand',
        parameter_value: ''
      }
    ]
  )

  cloudformation_client.wait_until(:stack_update_complete,
                                   stack_name: @service_name)

  puts "Cloudformation Stack: #{@service_name} updated."
end


desc 'Create Jenkins Infra'
task 'create:cluster' do
  version = File.read(@version_url_path).to_s
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.create_stack(
    stack_name: @service_name,
    template_body: File.read('infrastructure/cluster.yaml').to_s
  )

  cloudformation_client.wait_until(:stack_create_complete,
                                   stack_name: @service_name)

  puts "Cloudformation Stack: #{@service_name} created."
end

desc 'Update Jenkins ECS' Service
task 'update:service' do
  version = File.read(@version_url_path).to_s
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.update_stack(
    stack_name: @service_name,
    template_body: File.read('infrastructure/service.yaml').to_s
  )

  cloudformation_client.wait_until(:stack_update_complete,
                                   stack_name: @service_name)

  puts "Cloudformation Stack: #{@service_name} updated."
end
