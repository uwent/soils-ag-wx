class SubscribersController < ApplicationController
  before_action :get_subscriber_from_session
  before_action :fix_email, if: -> { params[:email].present? }
  before_action :require_session, only: %i[
    update
    enable_emails
    disable_emails
    add_site
    remove_site
    enable_site
    disable_site
    enable_subscription
    disable_subscription
  ]

  rescue_from ActiveRecord::RecordNotFound do |e|
    redirect_to subscribers_path, alert: "Something went wrong, please try again."
  end

  ### STANDARD ###

  def index
    # only show the index page when logged out
    return redirect_to(action: :manage) unless @subscriber.nil?
  end

  def new
    @subscriber = Subscriber.new(email: params[:email])
  end

  def manage
    # not logged in
    if @subscriber.nil?
      email = params[:email]
      if email.nil?
        return redirect_to subscribers_path, alert: "You must be logged in to view that page."
      end

      # look for existing subscriber
      @subscriber = Subscriber.find_by_email(email)

      # ask to create subscriber if none found
      if @subscriber.nil?
        return redirect_to new_subscriber_path(email:)
      end

      # render validation or confirmation notice
      if @subscriber.is_confirmed?
        @subscriber.generate_validation_token
        return render :validate
      else
        return render :confirm
      end
    end

    @sites = @subscriber.sites
    @weather_subs = Subscription.weather
    @dd_subs = Subscription.degree_days
    @pest_subs = Subscription.pests

    # pre-fill for new site
    if params[:lat] && params[:long]
      @new_name = params[:name] || "My Site"
      @new_lat = params[:lat]
      @new_long = params[:long]
    end
  end

  def send_email
    if @subscriber.nil?
      return redirect_to subscribers_path, alert: "You must be logged in to perform that action."
    elsif @subscriber.sites.enabled.size == 0
      return redirect_to manage_subscribers_path, alert: "You don't have any active sites, so we couldn't send an email."
    end

    Subscriber.send_subscriptions([@subscriber])
    redirect_to manage_subscribers_path, notice: "Test email sent!"
  end

  def account
    if @subscriber.nil?
      return redirect_to subscribers_path, alert: "You must be logged in to view that page."
    end

    # Handle email change initiation
    if params[:email]
      @new_email = params[:email]&.strip
      if Subscriber.find_by_email(@new_email)
        @subscriber.errors.add(:email, "is already registered")
      else
        @validation_sent = true
        @subscriber.generate_validation_token
        @email_notice = "We sent an email with a validation code to #{params[:email]}. Please enter that code here to confirm your email change. The code will be valid for one hour."
      end
    end

    # Handle email change validation
    if params[:new_email] && params[:validation_code]
      if @subscriber.validation_token == params[:validation_code]&.strip
        @subscriber.update!(email: params[:new_email])
        @email_changed = true
        @email_notice = "Email successfully changed!"
      else
        @subscriber.errors.add(:validation_code, "did not match the code sent to your new email address. Please try again.")
      end
    end

    @sites = @subscriber.sites
  end

  def logout
    remove_from_session
    redirect_to subscribers_path
  end

  def admin
    if @subscriber.nil?
      return redirect_to subscribers_path, alert: "You must be logged in to view that page."
    elsif !@admin
      return redirect_to manage_subscribers_path, alert: "You must be an admin to view that page."
    end

    @subscribers = Subscriber.order(:id).paginate(page: params[:page], per_page: 20)
  end

  def export
    return redirect_to subscribers_path unless @admin

    respond_to do |format|
      format.csv { send_data Subscriber.to_csv, filename: "ag-weather-users-#{Date.today}.csv" }
    end
  end

  ### ACCOUNT ACTIONS ###

  # create new account
  def create
    @subscriber = Subscriber.new(subscriber_params)

    if Subscriber.find_by_email(params[:subscriber][:email])
      @subscriber.errors.add(:email, "is already registered")
      render action: :new
    elsif @subscriber.save
      SubscriptionMailer.confirm(@subscriber).deliver
      redirect_to confirm_subscriber_path(@subscriber)
    else
      render action: :new
    end
  end

  # confirm email
  def confirm
    @subscriber = Subscriber.find(params[:id])
    return redirect_to action: :manage if @subscriber.is_confirmed?
  end

  # handle link from confirmation email
  def confirm_account
    @subscriber = Subscriber.find(params[:id])

    passed_token = params[:token]
    if @subscriber.confirm!(passed_token)
      add_to_session(@subscriber.id)
      redirect_to action: :manage
    else
      redirect_to action: :index
    end
  end

  # resend confirmation email
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

  # handle logging in with code or link
  def validate
    @subscriber = Subscriber.find(params[:id])

    # log in from the email link
    if params[:token]
      if params[:token] == @subscriber.auth_token
        add_to_session(@subscriber.id)
        return redirect_to manage_subscribers_path, notice: "Successfully logged in as #{@subscriber.name} (#{@subscriber.email})"
      else
        @subscriber.generate_validation_token
        flash.now[:alert] = "The link you clicked is no longer valid. We just emailed you a new six-digit sign-in code, please enter it below to finish signing in."
      end
    end

    validation_code = params[:validation_code]&.strip
    if validation_code
      if @subscriber.is_validation_token_old?
        @subscriber.generate_validation_token
        @subscriber.errors.add(:validation_code, "is too old. We've sent a new one. Check your email.")
      elsif @subscriber.validation_token_valid?(validation_code)
        add_to_session(@subscriber.id)
        redirect_to manage_subscribers_path
      else
        @subscriber.errors.add(:validation_code, "is incorrect.")
      end
    end
  end

  ### JSON SUBSCRIBER ACTIONS ###

  def update
    subscriber = Subscriber.find(params[:id])
    if @subscriber.nil?
      reject("You must be logged in to perform this action.")
    elsif subscriber == @subscriber || @admin
      subscriber.update!(subscriber_params.compact)
      render json: {message: "success"}
    else
      reject("You are not authorized to do that.")
    end
  rescue => e
    render json: {message: e}, status: 422
  end

  def destroy
    if @subscriber.nil? # not logged in
      redirect_to subscribers_path, alert: "You must be logged in to perform this action."
    elsif @subscriber.admin? # admin is logged in
      subscriber = Subscriber.find(params[:id])
      if subscriber != @subscriber
        subscriber.destroy
        redirect_to admin_subscribers_path, notice: "Successfully deleted user #{subscriber.id}: #{subscriber.name} (#{subscriber.email})"
      end
    elsif params[:token] == @subscriber.auth_token
      @subscriber.destroy
      redirect_to subscribers_path, notice: "You successfully deleted your account."
    else
      redirect_to subscribers_path, alert: "Invalid token, check URL or try again."
    end
  end

  def reset_token
    if @subscriber
      @subscriber.update!(auth_token: SecureRandom.hex(10))
      return redirect_to account_subscribers_path, notice: "Successfully reset your authentication token. Some links in previously-sent emails will no longer work."
    end
    redirect_to account_subscribers_path, alert: "Unable to reset your authentication token."
  end

  ### SITES ###

  def add_site
    site_name = params[:site_name]
    lat = params[:lat].to_f.round(1)
    long = params[:long].to_f.round(1)

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

  ### SUBSCRIPTIONS ###

  def unsubscribe
    @subscriber = Subscriber.find(params[:id])
    if params[:token] == @subscriber.auth_token
      @subscriber.update!(emails_enabled: false)
      path = if session[:subscriber] && Subscriber.find(session[:subscriber]).admin?
        manage_subscribers_path(to_edit_id: @subscriber.id)
      else
        manage_subscribers_path
      end
      return redirect_to path, notice: "Successfully unsubscribed from daily emails for #{@subscriber.name} (#{@subscriber.email})."
    end
    redirect_to subscribers_path, alert: "Unable to unsubscribe from daily emails, please refresh page and try again."
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

  private

  def require_session
    return reject("You must be logged in to perform this action.") if session[:subscriber].nil?
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
