require 'gchart'
class HomeController < ApplicationController
  def index
    @users = User.all

    @event_summary_chart_data = []
    @event_summary_chart_labels = []
    @processing_chart_label = RULES_ENG::last_processing_duration_history

    Event.select(:source).uniq.each do |sources|
      @current_event = Event.where(source: sources.source).count
      @event_summary_chart_data << @current_event
      @event_summary_chart_labels << "#{sources.source} (#{@current_event})"
    end


    #@stuff = Rule.find_by_id(1).events.all
    @notification_pie_chart = Gchart.pie(:use_ssl => true, :size => '350x150', :data => [Record.sum(:email_notify), Record.sum(:boxcar_notify), Record.sum(:nma_notify), Record.sum(:nmwp_notify), Record.sum(:prowl_notify), Record.sum(:mobile_ph_notify)], :labels => ["Email " + Record.sum(:email_notify).to_s, "Boxcar " + Record.sum(:boxcar_notify).to_s, "Notify My Android " + Record.sum(:nma_notify).to_s, "Notify My Windows Phone " + Record.sum(:nmwp_notify).to_s, "Prowl " + Record.sum(:prowl_notify).to_s, "SMS " + Record.sum(:mobile_ph_notify).to_s])
    @count_bar_chart = Gchart.bar(:use_ssl => true, :size => '350x150', :bar_width_and_spacing => '85,30', :data => @event_summary_chart_data, :labels => @event_summary_chart_labels, :bar_colors => ['0066CC', '003366', '006699', '3399CC', '66CCFF', '0099FF'])
    @processing_line_chart = Gchart.line(:use_ssl => true, :data => @processing_chart_label, :axis_with_labels => ['y'])
  end
end
