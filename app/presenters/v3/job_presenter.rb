require 'presenters/v3/base_presenter'

module VCAP::CloudController
  module Presenters
    module V3
      class JobPresenter < BasePresenter
        RESOURCE_LINKS = {
          app: '/v3/apps/',
          droplet: '/v3/droplets/',
          package: '/v3/packages/',
        }.freeze

        def to_hash
          {
            guid:       job.guid,
            created_at: job.created_at,
            updated_at: job.updated_at,

            operation:  job.operation,
            state:      job.state,

            links:      build_links
          }
        end

        private

        def job
          @resource
        end

        def build_links
          url_builder = VCAP::CloudController::Presenters::ApiUrlBuilder.new

          links = {
            self: { href: url_builder.build_url(path: "/v3/jobs/#{job.guid}") }
          }

          if job.resource_exists?
            resource_type = job.resource_type.to_sym
            path = RESOURCE_LINKS[resource_type]
            links[resource_type] = { href: url_builder.build_url(path: path + job.resource_guid) }
          end

          links
        end
      end
    end
  end
end
