class CertificateAuthenticationController < ApplicationController

  def login
    certificate = request.headers['SSL_CLIENT_CERT']

    @cert = Mconf::SSLClientCert.new(certificate, session)
    @user = @cert.user

    if @user.present?
      sign_in :user, @user
      @cert.set_signed_in

      redir_url = after_sign_in_path_for(current_user)
      respond_to do |format|
        format.json { render json: { result: true, redirect_to: redir_url }, status: 200 }
      end
    else
      error = @cert.error || 'unknown'
      msg = I18n.t("certificate_authentication.error.#{error}")

      respond_to do |format|
        format.json { render json: { result: false, error: msg }, status: 200 }
      end
    end
  end

end
