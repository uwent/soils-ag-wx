class SubscribersController < ApplicationController
  before_action :get_subscriber_from_session, only: %i[
    index
    manage
    update
    admin
    account
    destroy
    send_email
    enable_emails
    disable_emails
    add_site
    remove_site
    enable_site
    disable_site
    enable_subscription
    disable_subscription
    export
    unsubscribe
  ]

  before_action :fix_email, if: -> { params[:email].present? }

  before_action :check_editor, only: %i[
    enable_emails
    disable_emails
    add_site
    remove_site
    enable_site
    disable_site
    enable_subscription
    disable_subscription
    send_email
  ]

  rescue_from ActiveRecord::RecordNotFound, with: :index unless Rails.env.development?

  def index
    # remove_from_session
    return redirect_to manage_subscribers_path unless @subscriber.nil?
  end

  def new
    @subscriber = Subscriber.new(email: params[:email])
  end

  def create
    @subscriber = Subscriber.new(subscriber_params)

    if Subscriber.email_find(params[:subscriber][:email])
      @subscriber.errors.add(:email, "is already registered")
      render action: "new"
    elsif @subscriber.save
      SubscriptionMailer.confirm(@subscriber).deliver
      redirect_to confirm_notice_subscriber_path(@subscriber)
    else
      render action: "new"
    end
  end

  def confirm_notice
    @subscriber = Subscriber.find(params[:id])
    if @subscriber.nil?
      redirect_to subscribers_path
    elsif !@subscriber.confirmed_at.nil?
      redirect_to manage_subscribers_path
    end
  end

  def resend_confirmation
    @subscriber = Subscriber.find(params[:id])
    respond_to do |format|
      if @subscriber
        SubscriptionMailer.confirm(@subscriber).deliver
        format.json { render json: {message: "Resent"} }
      else
        format.json { render json: {message: "Error"} }
      end
    end
  end

  def confirm
    passed_token = params[:token]
    @subscriber = Subscriber.find(params[:id])
    if @subscriber.confirm!(passed_token)
      add_to_session(@subscriber.id)
      redirect_to action: :manage
    else
      redirect_to subscribers_path
    end
  end

  def validate
    @subscriber = Subscriber.find(params[:id])
    validation_code = params[:validation_code]&.strip
    # check the validation code....
    if @subscriber.is_validation_token_old?
      @subscriber.generate_validation_token
      @subscriber.errors.add(:validation_code, "is too old. We've sent a new one. Check your email.")
      render
    elsif !@subscriber.validation_token_valid?(validation_code)
      @subscriber.errors.add(:validation_code, "is incorrect.")
      render
    else
      # add it to the session
      add_to_session(@subscriber.id)
      redirect_to manage_subscribers_path
    end
  end

  def update
    return reject if @subscriber.nil? || !@subscriber.admin?
    subscriber = Subscriber.find(params[:id])
    subscriber.update!(subscriber_params.compact)
    render json: {message: "success"}
  rescue => e
    render json: {message: e}, status: 422
  end

  def destroy
    if @subscriber.nil? # not logged in
      redirect_to subscribers_path, alert: "You must be logged in to perform this action."
    elsif @subscriber.admin? # admin is logged in
      subscriber = Subscriber.find(params[:id])
      if subscriber != @subscriber
        # subscriber.sites.each { |s| s.delete }
        subscriber.destroy
        redirect_to admin_subscribers_path, notice: "Successfully deleted user #{subscriber.id}: #{subscriber.name} (#{subscriber.email})"
      end
    elsif params[:token] == @subscriber.auth_token
      @subscriber.destroy
      redirect_to subscribers_path, notice: "You successfully deleted your account."
    # @subscriber.sites.each { |s| s.delete }
    else
      redirect_to subscribers_path, alert: "Invalid token, check URL or try again."
    end
  end

  def admin
    return redirect_to subscribers_path if @subscriber.nil?
    return redirect_to manage_subscribers_path unless @subscriber.admin?
    @subscribers = Subscriber.order(:id).paginate(page: params[:page], per_page: 20)
  end

  def account
    return redirect_to subscribers_path if @subscriber.nil?
    @sites = @subscriber.sites
  end

  def manage
    # not logged in
    if @subscriber.nil?
      email = params[:email]
      return redirect_to subscribers_path if email.nil?

      @subscriber = Subscriber.email_find(email)

      # no matching subscriber with that email
      return redirect_to new_subscriber_path(email:) if @subscriber.nil?

      # render validation or confirmation notice
      if @subscriber.is_confirmed?
        @subscriber.generate_validation_token
        render :validate
      else
        render :confirm_notice
      end
    end

    @sites = @subscriber.sites
    @weather_subs = Subscription.weather
    @dd_subs = Subscription.degree_days
    @pest_subs = Subscription.pests

    # pre-fill for new site
    if params[:lat] && params[:long]
      @new_name = "My Site"
      @new_lat = params[:lat]
      @new_long = params[:long]
    end
  end

  def send_email
    if params[:token] != @subscriber.auth_token
      return redirect_to manage_subscribers_path, alert: "Unable to send test email, refresh page and try again."
    end

    if @subscriber.sites.enabled.size == 0
      return redirect_to manage_subscribers_path, alert: "You don't have any active sites, so we couldn't send an email."
    end

    Subscriber.send_subscriptions([@subscriber])
    redirect_to manage_subscribers_path, notice: "Test email sent!"
  end

  def add_site
    site_name = params[:site_name]
    lat = params[:latitude].to_f.round(1)
    long = params[:longitude].to_f.round(1)

    return if site_name.nil?
    site_name = site_name.gsub(/\r\n/m, "").strip

    # check for existing
    errors = []
    if @subscriber.sites.where(name: site_name).size > 0
      errors << "You already have a site named #{site_name}."
    end
    if @subscriber.sites.where(latitude: lat, longitude: long).size > 0
      errors << "You already have a site at #{lat}, #{long}."
    end
    return render json: {message: errors.join("\n"), status: 500} if errors.size > 0

    site = Site.new(name: site_name, latitude: lat, longitude: long)
    @subscriber.sites << site
    site.subscriptions << Subscription.select { |s| s.is_a? WeatherSub }

    render json: site
  rescue => e
    reject(e)
  end

  def remove_site
    site_id = params[:site_id]
    @subscriber.sites.find(site_id).destroy
    render json: {message: "success"}
  end

  def enable_emails
    @subscriber.update(emails_enabled: true)
    render json: {message: "enabled"}
  end

  def disable_emails
    @subscriber.update(emails_enabled: false)
    render json: {message: "disabled"}
  end

  def enable_site
    site_id = params[:site_id]
    @subscriber.sites.find(site_id).update(enabled: true)
    render json: {message: "enabled"}
  end

  def disable_site
    site_id = params[:site_id]
    @subscriber.sites.find(site_id).update(enabled: false)
    render json: {message: "disabled"}
  end

  # actually just disables all sites
  def unsubscribe
    @subscriber = Subscriber.find(params[:id])
    if params[:token] == @subscriber.auth_token
      @subscriber.update(emails_enabled: false)
      path = if session[:subscriber] && Subscriber.find(session[:subscriber]).admin?
        manage_subscribers_path(to_edit_id: @subscriber.id)
      else
        manage_subscribers_path
      end
      return redirect_to path, notice: "Successfully unsubscribed from daily emails for #{@subscriber.name} (#{@subscriber.email})."
    end
    redirect_to manage_subscribers_path, alert: "Unable to unsubscribe from daily emails, please refresh page and try again."
  end

  def enable_subscription
    site = Site.find(params[:site_id])
    subscription = Subscription.find(params[:sub_id])

    return reject if !@subscriber.sites.include?(site)
    unless site.subscriptions.include?(subscription)
      site.subscriptions << subscription
    end

    render json: {message: "enabled"}
  rescue => e
    reject(e)
  end

  def disable_subscription
    site = Site.find(params[:site_id])
    subscription = Subscription.find(params[:sub_id])

    return reject if !@subscriber.sites.include? site
    if site.subscriptions.include?(subscription)
      site.subscriptions.delete(subscription)
    end

    render json: {message: "disabled"}
  rescue => e
    reject(e)
  end

  def logout
    remove_from_session
    redirect_to subscribers_path
  end

  def export
    return redirect_to subscribers_path if @subscriber.nil?
    return redirect_to manage_subscribers_path unless @subscriber.admin?

    respond_to do |format|
      format.csv { send_data Subscriber.to_csv, filename: "ag-weather-users-#{Date.today}.csv" }
    end
  end

  private

  def check_editor
    if @subscriber.nil?
      redirect_to subscribers_path, alert: "You must be logged in to perform this action."
    end

    # if @subscriber.admin?
    #   if params[:to_edit_id]
    #     @subscriber = Subscriber.find(params[:to_edit_id])
    #   elsif params[:id]
    #     @subscriber = Subscriber.find(params[:id])
    #   end
    # end
  end

  def fix_email
    params[:email] = params[:email]&.downcase&.strip
  end

  def subscriber_params
    params[:subscriber][:email] = params[:subscriber][:email]&.downcase&.strip
    params.require(:subscriber).permit(:name, :email, :confirmed_at)
  end

  def add_to_session(id)
    session[:subscriber] = id
  end

  def remove_from_session
    session.delete(:subscriber)
  end
end
