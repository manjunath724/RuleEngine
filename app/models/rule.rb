class Rule < ActiveRecord::Base
  TYPES = {
    int: 'Integer',
    str: 'String',
    dt: 'Datetime'
  }.freeze

  OPERATORS = [
    '==',
    '!=',
    '>',
    '<',
    '>=',
    '<='
  ].freeze

  COMPONENTS = %w(second minute hour day month year).freeze

  belongs_to :user

  validates :user_id, :signal, :value_type, :comparison_operator, :value, presence: true
  validate :rule_specifics

  def self.parse_incoming_signal_data(user_id, file_path)
    failure_list = []
    rules = where(user_id: user_id).group_by(&:signal)
    rule_keys = rules.keys
    data_hash = JSON.parse(File.read(file_path)).uniq
    applicable_data = data_hash.select { |a| rule_keys.include? a["signal"] }.uniq
    applicable_data.each do |data|
      relevant_rules = rules[data["signal"]].select { |r| r.value_type == data["value_type"] }.uniq
      relevant_rules.each do |rule|
        if rule.value_type == data["value_type"]
          lhs = data["value"]
          rhs = rule.value
          if rule.value_type == TYPES[:dt]
            rhs = rule.relative ? eval(rhs) : rhs.to_time
          elsif rule.value_type == TYPES[:int]
            lhs = lhs.to_i
            rhs = rhs.to_i
          end
          next if lhs.method(rule.comparison_operator).(rhs)
        end
        failure_list << data
      end
    end
    failure_list.uniq
  end

  private

  def rule_specifics
    # Validates the numericality of Integer type
    if value_type == TYPES[:int]
      errors.add(:base, 'Please enter Integer number only') unless value == value.to_i.to_s
    end
  end
end
