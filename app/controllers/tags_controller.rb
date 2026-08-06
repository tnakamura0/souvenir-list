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

  def edit
    @tag = current_user.tags.find(params[:id])
  end

  def update
    @tag = current_user.tags.find(params[:id])

    if @tag.update(tag_params)
      render partial: "tag", locals: { tag: @tag }
    else
      flash.now[:alert] = t(".failure")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    tag = current_user.tags.find(params[:id])
    tag.destroy!
    redirect_to tags_path, notice: t(".success")
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
