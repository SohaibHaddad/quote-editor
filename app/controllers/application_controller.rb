class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def switch_locale(&action)
    locale = extract_locale
    I18n.with_locale(locale, &action)
  end

  def extract_locale
    requested_locale = params[:locale]&.to_sym

    if requested_locale.present? && I18n.available_locales.include?(requested_locale)
      session[:locale] = requested_locale
    end

    session[:locale]&.to_sym || I18n.default_locale
  end
end
