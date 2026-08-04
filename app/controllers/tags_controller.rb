class TagsController < ApplicationController
  def index
    @tags = current_user.tags
    @tag = Tag.new
  end

  def create
    @tag = current_user.tags.build(tag_params)

    if @tag.save
      redirect_to tags_path, notice: t(".success")
    else
      @tags = current_user.tags.where.not(id: nil)
      flash.now[:alert] = t(".failure")
      render :index, status: :unprocessable_content
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
