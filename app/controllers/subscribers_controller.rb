class SubscribersController < ApplicationController
  before_action :get_subscriber_from_session, only: [
    :manage,
    :update,
    :admin,
    :destroy,
    :send_email,
    :add_subscription,
    :remove_subscription,
    :enable_subscription,
    :disable_subscription,
    :export_emails
  ]

  def index
    remove_from_session
  end

  def manage
    # is there a subscriber in the session? If so they have already validated.
    if !@subscriber.nil?
      if params[:email_address] && params[:email_address] != @subscriber.email
        remove_from_session
        redirect_to manage_subscribers_path(email_address: params[:email_address])
      else
        @admin = @subscriber.admin?
        if @subscriber.admin? && params[:to_edit_id]
          @subscriber = Subscriber.find(params[:to_edit_id])
        end
        render
      end
    elsif params[:email_address].nil?
      redirect_to subscribers_path
    elsif (@subscriber = Subscriber.email_find(params[:email_address]))
      if @subscriber.is_confirmed?
        @subscriber.generate_validation_token
        render :validate
      else
        render :confirm_notice
      end
    else
      @email_address = params[:email_address]
      redirect_to new_subscriber_path(email: @email_address)
    end
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
      redirect_to confirm_notice_subscriber_path(@subscriber), notice: "Subscriber was successfully created."
    else
      render action: "new"
    end
  end

  def validate
    @subscriber = Subscriber.find(params[:id])
    validation_code = params[:validation_code]
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
      redirect_to manage_subscribers_path, notice: "Subscriber was successfully created."
    end
  end

  def confirm_notice
    @subscriber = Subscriber.find(params[:id])
    return redirect_to subscribers_path if @subscriber.nil?
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
      render :manage
    else
      redirect_to subscribers_path
    end
  end

  def send_email
    return render json: {message: "error"} if @subscriber.nil?
    token = params[:token]
    if token == @subscriber.confirmation_token
      Subscriber.send_subscriptions(@subscriber)
    end
    redirect_to action: :manage
  end

  def add_subscription
    return render json: {message: "error"} if @subscriber.nil?

    if @subscriber.admin? && params[:to_edit_id]
      @subscriber = Subscriber.find(params[:to_edit_id])
    end

    site_name = params[:site_name]
    lat = params[:latitude]
    long = params[:longitude]

    # check for existing
    if @subscriber.subscriptions.where(latitude: lat, longitude: long).size > 0
      return render json: {
        message: "Subscription already exists for a site at #{lat}, #{long}."
      }
    end

    # product = Product.where(name: "Evapotranspiration").first
    respond_to do |format|
      subscription = Subscription.new(
        name: site_name,
        latitude: lat,
        longitude: long,
        product_id: 1
      )
      @subscriber.subscriptions << subscription
      format.json { render json: subscription }
    end
  end

  def remove_subscription
    return render json: {message: "error"} if @subscriber.nil?

    if @subscriber.admin? && params[:to_edit_id]
      @subscriber = Subscriber.find(params[:to_edit_id])
    end
    subscription_id = params[:subscription_id]
    @subscriber.subscriptions.where(id: subscription_id).first.delete
    respond_to do |format|
      format.json { render json: {message: "success"} }
    end
  end

  def enable_subscription
    return render json: {message: "error"} if @subscriber.nil?

    if @subscriber.admin? && params[:to_edit_id]
      @subscriber = Subscriber.find(params[:to_edit_id])
    end
    subscription_id = params[:subscription_id]
    @subscriber.subscriptions.where(id: subscription_id).first.update(enabled: true)
    respond_to do |format|
      format.json { render json: {message: "enabled"} }
    end
  end

  def disable_subscription
    return render json: {message: "error"} if @subscriber.nil?

    if @subscriber.admin? && params[:to_edit_id]
      @subscriber = Subscriber.find(params[:to_edit_id])
    end
    subscription_id = params[:subscription_id]
    @subscriber.subscriptions.where(id: subscription_id).first.update(enabled: false)
    respond_to do |format|
      format.json { render json: {message: "disabled"} }
    end
  end

  def unsubscribe
    @subscriber = Subscriber.find(params[:id])
    token = params[:token]
    @unsubscribed = false
    if token == @subscriber.confirmation_token
      @subscriber.subscriptions.all.update(enabled: false)
      @unsubscribed = true
    end
    redirect_to action: :manage
  end

  def logout
    remove_from_session
    redirect_to root_path
  end

  def admin
    return redirect_to subscribers_path if @subscriber.nil?
    return redirect_to manage_subscribers_path unless @subscriber.admin?

    @subscribers = Subscriber.order(:email).paginate(page: params[:page], per_page: 20)
  end

  def export_emails
    return redirect_to subscribers_path if @subscriber.nil?
    return redirect_to manage_subscribers_path unless @subscriber.admin?

    respond_to do |format|
      format.csv { send_data Subscriber.to_csv, filename: "ag-weather-users-#{Date.today}.csv" }
    end
  end

  def update
    return render json: {message: "error"} if @subscriber.nil? || !@subscriber.admin?

    subscriber = Subscriber.find(params[:id])
    subscriber.update(subscriber_params)
    respond_to do |format|
      format.json { render json: {message: "success"} }
    end
  end

  def destroy
    return redirect_to subscribers_path if @subscriber.nil?

    if @subscriber.admin?
      subscriber = Subscriber.find(params[:id])
      if subscriber != @subscriber
        subscriber.subscriptions.each { |s| s.delete }
        subscriber.destroy
      end
      return redirect_to admin_subscribers_path
    elsif params[:token] == @subscriber.confirmation_token
      @subscriber.subscriptions.each { |s| s.delete }
      @subscriber.destroy
      return redirect_to subscribers_path
    end
    return redirect_to manage_subscribers_path
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:name, :email, :confirmed_at)
  end

  def add_to_session(id)
    session[:subscriber] = id
  end

  def remove_from_session
    session.delete(:subscriber)
  end

  def get_subscriber_from_session
    @subscriber = Subscriber.where(id: session[:subscriber]).first
  end
end
