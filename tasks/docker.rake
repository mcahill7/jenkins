# frozen_string_literal: true

require 'docker-api'
require 'aws-sdk'
require_relative 'constants'

desc 'Build Docker Image'
task 'docker:build' do
  image = Docker::Image.build_from_dir('.', 't' => 'jenkins:latest')
  # sh = `docker build -t jenkins:latest .`

  File.write(@image_id_path, image.id)

  puts 'Docker Image: demo built.'
end

desc 'Tag Demo image'
task 'docker:tag' do
  image = Docker::Image.get(File.read(@image_id_path))

  # Authentication is required for this step
  if Docker.creds.nil?
    Rake::Task['ecr:authenticate'].reenable
    Rake::Task['ecr:authenticate'].invoke
  end

  # bump version number
  old_version = File.read(@version_url_path).to_f
  version = old_version + 0.001
  File.write(@version_url_path, version)

  ecr_repo = "#{File.read(@ecr_repo_url_path)}/jenkins"

  image.tag(repo: ecr_repo, tag: version)

  puts "Image: #{image.id} has been tagged: #{image.info['RepoTags'].last}."
end

desc 'Push demo image'
task 'docker:push' do
  image = Docker::Image.get(File.read(@image_id_path))
  ecr_repo = "#{File.read(@ecr_repo_url_path)}/jenkins"
  version = File.read(@version_url_path).to_s
  repo_tag = "#{ecr_repo}:#{version}"

  # Authentication is required for this step
  if Docker.creds.nil?
    Rake::Task['ecr:authenticate'].reenable
    Rake::Task['ecr:authenticate'].invoke
  end

  image.push(nil, repo_tag: repo_tag)

  puts "Tag: #{repo_tag} pushed to ECR."
end

desc 'Authenticate with ECR'
task 'ecr:authenticate' do
  ecr_client = Aws::ECR::Client.new

  # Grab your authentication token from AWS ECR
  token = ecr_client.get_authorization_token(
    registry_ids: [ENV['AWS_ACCOUNT_ID']]
  ).authorization_data.first

  # Remove the https:// to authenticate
  ecr_repo_url = token.proxy_endpoint.gsub('https://', '')

  # Authorization token is given as username:password, split it out
  user_pass_token = Base64.decode64(token.authorization_token).split(':')

  # Call the authenticate method with the options
  Docker.authenticate!('username' => user_pass_token.first,
                       'password' => user_pass_token.last,
                       'email' => 'none',
                       'serveraddress' => ecr_repo_url)

  File.write(@ecr_repo_url_path, ecr_repo_url)

  puts "Authenticated: #{ecr_repo_url} with with Docker on this machine."
end

desc 'Create ECR repository'
task 'ecr:create' do
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.create_stack(
    stack_name: @ecr_name,
    template_body: File.read('infrastructure/ecr.yaml').to_s
  )

  cloudformation_client.wait_until(:stack_create_complete,
                                   stack_name: @ecr_name)

  puts "Cloudformation Stack: #{@stack_name} created."
end
