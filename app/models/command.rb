class Command < ApplicationRecord
  enum status: {failure: -1, success: 0, not_started: 1, running: 2, killed: 3}

  has_many :outputs, dependent: :destroy
  belongs_to :user

  validates :text, presence: true

  broadcasts_to ->(command) { [:commands, command] }
  after_create_commit ->(command) { broadcast_prepend_to [command.user, :commands], partial: "commands/command_table" }
  after_update_commit ->(command) { broadcast_replace_to [command.user, :commands], partial: "commands/command_table" }
  after_destroy_commit ->(command) { broadcast_remove_to [command.user, :commands] }

  after_create :perform_async

  def perform_async
    runner = CommandRunnerJob.perform_later(self)
    update(job_id: runner.job_id)
  end

  def kill!
    CommandRunnerJob.cancel!(job_id)
  end

  def completed?
    success? || failure?
  end
end
