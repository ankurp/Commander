require "async"

class CommandRunnerJob < ApplicationJob
  def perform(command)
    @cmd = Cmd.new(command.text) do |out, err|
      command.outputs.create(
        text: (out.present? ? out : err) || "",
        type: out.present? ? :out : :err
      )
    rescue TTY::Command::ExitError => err
      command.outputs.create(
        text: err.to_s,
        type: :err
      )
    end

    Async::Reactor.run do
      Async do
        command.update(status: :running)
        while command.running?
          sleep 1.seconds
          break if CommandRunnerJob.cancelled?(command.job_id)
        end
        @cmd.terminate
      end

      @cmd.run do |status|
        if status.termsig.present?
          command.update(status: :killed)
        else
          command.update(status: status.exitstatus.zero? ? :success : :failure)
        end
      end
    end
  end

  def check_for_cancellation(command)
  end

  def self.cancelled?(jid)
    Sidekiq.redis { |c| c.exists?("cancelled-#{jid}") }
  end

  def self.cancel!(jid)
    Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 1.minute, 1) }
  end
end
