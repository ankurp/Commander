class Output < ApplicationRecord
  belongs_to :command

  self.inheritance_column = "type_class"

  enum type: [:out, :err]

  broadcasts_to ->(output) { [:commands, output.command] }
end
