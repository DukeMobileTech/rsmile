class ParticipantsController < ApplicationController
  def index
    render json: Participant.summary_stats
  end

  def sgm_groups
    render json: Participant.sgm_stats(params[:country])
  end

  def grouped
    render json: Participant.weekly_statistics(params[:country])
  end

  def blank_stats
    render json: Participant.blank_stats(params[:country])
  end

  def source_timeline
    render json: Participant.source_timeline(params[:country], params[:source])
  end

  def weekly_stats
    render json: Participant.all_sources_timeline(params[:country])
  end
end
