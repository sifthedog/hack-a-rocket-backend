class ApplicationController < ActionController::API
    include HackARocketExceptions
    
    def encode_token(payload)
        JWT.encode(payload, ENV['SECRET_JWT'])
    end

    def auth_header
        request.headers['Authorization']
    end

    def encoded_token
        if auth_header
            token = auth_header.split(' ')[1]
            JWT.decode(token, ENV['SECRET_JWT'], true, algorithm: 'HS256')
        end        
    end
    
    def logged_in_user
        if encoded_token
            id = encoded_token[0]['id']
            @user = User.find(id) 

            return true
        end
        
        return false
    end

    def logged_in?
        !!logged_in_user
    end
    
    def authorized
        begin
            raise JWT::VerificationError if !logged_in?
        rescue JWT::VerificationError
            render json: {error: 'Unauthorized token'},status: 401
        rescue JWT::DecodeError
            render status: 400
        rescue => e
            Rails.logger.error e.message
            Rails.logger.error e.backtrace.join("\n")
        end
    end
end
