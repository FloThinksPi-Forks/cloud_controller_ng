module VCAP::CloudController
  class FieldServiceInstanceSpaceDecorator
    def self.match?(fields)
      fields.is_a?(Hash) && fields[:space]&.to_set&.intersect?(self.allowed)
    end

    def self.allowed
      Set['guid', 'relationships.organization']
    end

    def initialize(fields)
      @fields = fields[:space].to_set.intersection(self.class.allowed)
    end

    def decorate(hash, service_instances)
      hash[:included] ||= {}
      spaces = service_instances.map(&:space).uniq

      hash[:included][:spaces] = spaces.sort_by(&:created_at).map do |space|
        temp = {}
        temp[:guid] = space.guid if @fields.include?('guid')
        if @fields.include?('relationships.organization')
          temp[:relationships] =
            {
              organization: {
                data: {
                  guid: space.organization.guid
                }
              }
            }
        end
        temp
      end

      hash
    end
  end
end
