class CommandsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  before_action :set_command, only: %i[show kill]

  # GET /commands or /commands.json
  def index
    @commands = Command.order(created_at: :desc).page(params[:page])
  end

  # GET /commands/1 or /commands/1.json
  def show
  end

  # GET /commands/new
  def new
    @command = current_user.commands.build
  end

  # POST /commands or /commands.json
  def create
    @command = current_user.commands.build(command_params)

    respond_to do |format|
      if @command.save
        format.html { redirect_to @command, notice: "Command is queued to run..." }
        format.json { render :show, status: :created, location: @command }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @command.errors, status: :unprocessable_entity }
      end
    end
  end

  def kill
    @command.kill!
    respond_to do |format|
      format.html { redirect_to commands_path, notice: "Kill command sent." }
      format.json { render :show, status: :created, location: @command }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_command
    @command = Command.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def command_params
    params.require(:command).permit(:text)
  end
end
