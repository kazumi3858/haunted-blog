# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_current_user_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    user_id = current_user ? current_user.id : session[:user_id]
    @blog = Blog.where(id: params[:id]).merge(Blog.where(user_id: user_id).or(Blog.where(secret: false))).first!
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_current_user_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    permitted_params = current_user.premium? ? %i[title content secret random_eyecatch] : %i[title content secret]
    params.require(:blog).permit(permitted_params)
  end
end
