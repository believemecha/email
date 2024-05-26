class HomeController < ApplicationController
    
    def index
        @card_numbers = InboundEmail.where.not(card_number: nil).distinct.pluck(:card_number)
        @otps = InboundEmail.where.not(otp: nil).order(:card_number).order(:card_number).order(created_at: :desc)

        if params[:card_number].present?
            @otps = @otps.where(card_number: params[:card_number])
        end
        @otps = @otps.page(params[:page]).per(20)
    end

    def webhook
        gem 'nokogiri'

        email_content = params[:html]

        summary = params[:summary]

        doc = Nokogiri::HTML(email_content)

        text = doc.text

        card_number_match = text.match(/card ending in (\d{4})/)

        otp_match = text.match(/one-time passcode is (\d{6})/)

        card_number = card_number_match ? card_number_match[1] : nil

        otp = otp_match ? otp_match[1] : nil


        subject = params[:subject]
        to_address = params[:toAddress]
        received_time = params[:receivedTime]
        from_address = params[:fromAddress]

        InboundEmail.new(summary:summary, to_address: to_address,from_address: from_address,content:text,otp: otp,subject: subject,card_number: card_number,meta: params.except(:action,:controller,:home)).save

        render json: { status: true }, status: :ok 
    end
end