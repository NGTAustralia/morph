# Run API used by the morph command-line client
class ApiController < ApplicationController
  include ActionController::Live

  # The run_remote method will be secured with a key so shouldn't need csrf
  # token authentication
  skip_before_filter :verify_authenticity_token, only: [:run_remote]
  before_filter :authenticate_api_key
  before_filter :can_run

  # Receive code from a remote client, run it and return the result.
  # This will be a long running request
  # TODO: Document this API
  def run_remote
    response.headers['Content-Type'] = 'text/event-stream'
    run = Run.create(queued_at: Time.now, auto: false, owner: current_user)
    # TODO: Shouldn't need to untar here because it just gets retarred
    Archive::Tar::Minitar.unpack(params[:code].tempfile, run.repo_path)
    runner = Morph::Runner.new(run)
    runner.go { |s, text| stream_message(s, text) }
  ensure
    # Cleanup run
    response.stream.close
    # Don't want to leave any containers hanging around
    container = runner.container_for_run
    container.delete if container
    FileUtils.rm_rf(run.data_path)
    FileUtils.rm_rf(run.repo_path)
  end

  private

  def can_run
    return if current_user.ability.can? :create, Run

    render json: {
      stream: 'internalerr',
      text: "You currently can't start a scraper run." \
            ' See https://morph.io for more details'
    }
  end

  def stream_message(stream, text)
    response.stream.write({ stream: stream, text: text }.to_json + "\n")
  end

  def authenticate_api_key
    render(text: 'API key is not valid', status: 401) if current_user.nil?
  end

  def current_user
    @current_user ||= User.find_by_api_key(params[:api_key])
  end
end
