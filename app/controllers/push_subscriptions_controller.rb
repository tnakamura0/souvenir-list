class PushSubscriptionsController < ApplicationController
  def create
    push_subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: push_subscription_params[:endpoint]
    )

    created = push_subscription.new_record?

    push_subscription.assign_attributes(push_subscription_params)

    if push_subscription.save
      head created ? :created : :ok
    else
      head :unprocessable_content
    end
  end

  private

  def push_subscription_params
    params.require(:push_subscription).permit(:endpoint, :p256dh, :auth)
  end
end
