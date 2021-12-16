# frozen_string_literal: true

class Admin::Reports::Es::ReportController < ApplicationController
  skip_before_action :verify_authenticity_token

  def four_oh_three
    @four_oh_three = ElasticsearchService.new.get_four_oh_three
    respond_to do |format|
      format.json { render json: @four_oh_three }
      format.html { render :four_oh_three }
    end
  end

  def four_twenty_nine
    @four_twenty_nine = ElasticsearchService.new.get_four_twenty_nine
    respond_to do |format|
      format.json { render json: @four_twenty_nine }
      format.html { render :four_twenty_nine }
    end
  end

  def users
    @users = User.kept.select { |user| user.consumer.present? }
    respond_to do |format|
      format.json { render json: @users }
      format.html { render :list_consumers }
    end
  end

  def consumer_four_twenty_nine
    @user = User.find(params[:id])
    if @user.consumer.present? && @user.consumer.sandbox_gateway_ref
      @consumer_twenty_nine = ElasticsearchService.new.get_consumer_twenty_nine(@user.consumer.sandbox_gateway_ref)
    end
    respond_to do |format|
      format.json { render json: @consumer_twenty_nine }
      format.html { render :consumer_four_twenty_nine }
    end
  end

  def consumer_four_oh_three
    @user = User.find(params[:id])
    if @user.consumer.present? && @user.consumer.sandbox_gateway_ref
      @consumer_twenty_nine = ElasticsearchService.new.get_consumer_four_oh_three(@user.consumer.sandbox_gateway_ref)
    end
    respond_to do |format|
      format.json { render json: @consumer_twenty_nine }
      format.html { render :consumer_four_oh_three, @consumer_twenty_nine }
    end
  end
end
