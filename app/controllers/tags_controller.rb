class TagsController < ApplicationController
  def index
    @tags = current_user.tags
    @tag = Tag.new
  end
end
