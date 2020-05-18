# frozen_string_literal: true

@image_id_path = 'jenkins-image-id'
@ecr_name = 'jenkins-ecr'
@ecr_repo_url_path = 'jenkins-ecr-repo'
@version_url_path = 'version'
@cluster_name = 'jenkins'
@container = Docker::Container.create(
  'Image' => 'demo:latest',
  'ExposedPorts' => { '8080/tcp' => {} },
  'HostConfig' => {
    'PortBindings' => {
      '8080/tcp' => [{ 'HostPort' => '8080' }]
    }
  }
)
