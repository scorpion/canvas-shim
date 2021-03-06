require 'forwardable'
module SettingsService
  class StudentAssignmentRepository < RepositoryBase
    def get(table_name:, id:)
      assignment = ::Assignment.find(id[:assignment_id])
      migration_id = assignment.migration_id
      student_assignment_id = "#{migration_id}:#{id[:student_id]}"

      dynamodb.query(
        table_name: table_name,
        key_condition_expression: "#id = :id",
        expression_attribute_names: { "#id" => "id" },
        expression_attribute_values: { ":id" => student_assignment_id }
      ).items.inject({}) do |newhash, setting|
        newhash[setting['setting']] = setting['value']
        newhash
      end
    end

    def put(table_name:, id:, setting:, value:)
      return unless value == 'increment'

      assignment = ::Assignment.find(id[:assignment_id])
      return unless assignment.migration_id
      migration_id = assignment.migration_id
      student_assignment_id = "#{migration_id}:#{id[:student_id]}"

      value = SettingsService.get_settings(
        object: 'assignment',
        id: migration_id
      )["max_attempts"]

      return unless value

      student_attempts = SettingsService.get_settings(
        object: 'student_assignment',
        id: id
      )['max_attempts']

      value = student_attempts if student_attempts

      dynamodb.put_item(
        table_name: table_name,
        item: {
          id: student_assignment_id,
          setting: setting,
          value: value.to_i + 1
        }
      )
    end

    private

    def table_params(name)
      {
        table_name: name,
        key_schema: [
          { attribute_name: 'id', key_type: 'HASH' },
          { attribute_name: 'setting', key_type: 'RANGE'},
        ],
        attribute_definitions: [
            { attribute_name: 'id', attribute_type: 'S' },
            { attribute_name: 'setting', attribute_type: 'S' },
        ],
        provisioned_throughput: {
            read_capacity_units: 10,
            write_capacity_units: 10
        }
      }
    end

  end
end
