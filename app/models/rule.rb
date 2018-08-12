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

  private

  def rule_specifics
    # Validates the numericality of Integer type
    if value_type == TYPES[:int]
      errors.add(:base, 'Please enter Integer number only') unless value == value.to_i.to_s
    end
  end
end
