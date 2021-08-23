class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :book_reads, dependent: :destroy
  has_many :book_unreads, dependent: :destroy
  has_many :read_books, through: :book_reads, source: :book
  has_many :unread_books, through: :book_unreads, source: :book
  has_many :read_comments, dependent: :destroy
  has_many :read_favorites, dependent: :destroy

  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followers, through: :reverse_of_relationships, source: :follower
  has_many :followings, through: :relationships, source: :followed

  # 通知を送信
  has_many :active_notifications, class_name: "Notification", foreign_key: "visitor_id", dependent: :destroy
  # 通知を受信
  has_many :passive_notifications, class_name: "Notification", foreign_key: "visited_id", dependent: :destroy
  has_one :sns_acount, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true
  validates :introduction, length: { maximum: 50 }

  attachment :image

  def self.follow_include?(follower, follow)
    follower.followings.include?(follow)
  end

  def create_notification_follow(current_user)
    temp = Notification.where(["visitor_id = ? and visited_id = ? and action = ?", current_user.id, id, "follow"])
    if temp.blank?
      notification = current_user.active_notifications.new(
        visited_id: id,
        action: "follow"
        )
        notification.save if notification.valid?
    end
  end

  # メール送信
  def self.notify_release_book
    self.all.each do |user|
      user.notify_mail_book
    end
  end

  def notify_mail_book
    if self.is_mail_send == true
      books = []
      self.unread_books.each do |book|
        books << book if book.sales_date == Time.current.tomorrow.to_date
      end
      ReleaseNotificationMailer.send_release_mail(books, self).deliver if books.present?
    end
  end

  # フォローユーザーのアクティビティを取得
  def follow_user_timeline(current_user)
    current_user.followings.each do |follow_user|
      follow_user.active_notifications.where("action = ? or action = ?", "read", "release")
    end
  end

end
