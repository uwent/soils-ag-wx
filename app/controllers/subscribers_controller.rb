class SubscribersController < ApplicationController
  
  def index
  end

  def manage
    # is there a subscriber in the session? If so they have already validated.
    if !session[:subscriber].nil?
      @subscriber = Subscriber.find(session[:subscriber])
      render
      # try to find the email in the subscribers 
      #    if there, ask them for a validation key
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
      #    else, goto create
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
        # send email
        # add to session
        redirect_to @subscriber, notice: 'Subscriber was successfully created.'
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
      @subscriber.errors.add(:validation_code, "is too old. We've sent a new one.")
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
  end

  def resend_confirmaion
  end

  def confirm
  end
  
  private
    def subscriber_params
      params.require(:subscriber).permit(:name, :email, :confirmed)
    end

    def add_to_session(id)
      session[:subscriber] = id
    end
end
