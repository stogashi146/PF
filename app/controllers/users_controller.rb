class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @book_reads = @user.book_reads
    @book_unreads = @user.book_unreads
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user.id)
    end
  end

  def calender
    @books = current_user.unread_books
  end

  def welcome
  end

  def cancel
  end

  def unsubscribe
  end

  private
  def user_params
    params.require(:user).permit(:name_id, :name, :is_mail_send, :introduction, :image)
  end

end
