class RecipientForm
  include ActiveModel::Model

  def initialize(recipient:, user:, attributes: {})
    @recipient = recipient
    @user = user
    @attributes = attributes
  end

  def save
    ActiveRecord::Base.transaction do
      @recipient.assign_attributes(recipient_attributes)
      @recipient.save!
      create_and_assign_new_tag
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def recipient_attributes
    @attributes.except(:new_tag_name)
  end

  def create_and_assign_new_tag
    tag_name = @attributes[:new_tag_name].to_s.strip
    return if tag_name.blank?

    tag = @user.tags.find_or_create_by!(name: tag_name)
    @recipient.tags << tag unless @recipient.tags.exists?(tag.id)
  end
end
