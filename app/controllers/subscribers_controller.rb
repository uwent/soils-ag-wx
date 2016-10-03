class SubscribersController < ApplicationController
  
  def index
  end

  def manage
    # is there a subscriber in the session? If so they have already validated.
    if !session[:subscriber].nil?
      @subscriber = Subscriber.find(session[:subscriber])
      if params[:email_address] && params[:email_address] != @subscriber.email
        remove_from_session
        redirect_to manage_subscribers_path(email_address: params[:email_address])
      else
        render
      end
    elsif params[:email_address].nil? 
      redirect_to subscribers_path
    elsif @subscriber = Subscriber.email_find(params[:email_address])
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
    else
      if @subscriber.save
        SubscriptionMailer.confirm(@subscriber).deliver
        # send email
        # add to session
        redirect_to confirm_notice_subscriber_path(@subscriber),
                    notice: 'Subscriber was successfully created.'
      else
        render action: "new"
      end
    end
  end

  def validate
    @subscriber = Subscriber.find(params[:id])
    validation_code = params[:validation_code]
    #check the validation code....
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
      redirect_to manage_subscribers_path,notice: 'Subscriber was successfully created.'
    end
  end

  def confirm_notice
    @subscriber = Subscriber.find(params[:id])
  end

  def resend_confirmation
    @subscriber = Subscriber.find(params[:id])
    respond_to do |format|
      if @subscriber
        SubscriptionMailer.confirm(@subscriber).deliver
        format.json { render json: { message: "Resent" } }
      else
        format.json { render json: { message: "Error" } }
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
      redirect_to confirm_notice_subscriber_path(@subcriber)
    end
  end

  def add_subscription
    @subscriber = Subscriber.find(params[:id])
    site_name = params[:site_name]
    lat = params[:latitude]
    long = params[:longitude]
    product = Product.where(name: 'Evapotranspiration').first
    respond_to do |format| 
      subscription = Subscription.new(name: site_name, 
                                       latitude: lat, 
                                       longitude: long,
                                       product_id: product.id)
                                              
      @subscriber.subscriptions << subscription
      format.json { render json: subscription }
    end
  end

  def remove_subscription
    @subscriber = Subscriber.find(params[:id])
    subscription_id = params[:subscription_id]
    @subscriber.subscriptions.where(id: subscription_id).first.delete
    respond_to do |format| 
      format.json { render json: {message: "success"} }
    end    
  end

  private
    def subscriber_params
      params.require(:subscriber).permit(:name, :email, :confirmed)
    end

    def add_to_session(id)
      session[:subscriber] = id
    end

    def remove_from_session
      session.delete(:subscriber)
    end
end    
