module IdentifierMapperService
    class Endpoints
        include Singleton

        attr_reader :secret

        def initialize
            @secret || SecretManager.get_secret
        end

        def fetch(name, service=nil, identifier=nil)
            api_endpoint + case name
            when :get_powerschool_course_id
                "/pairs/?#{service}=#{identifier}"
            when :get_powerschool_school_id
                "/partners/#{ENV['CANVAS_DOMAIN'].split('.').first}"
            end
        end

        private 

        def api_endpoint
            secret['API_ENDPOINT'] + '/api/v1'
        end
    end
end
