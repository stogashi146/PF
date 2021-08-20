class BookRead < ApplicationRecord
  has_many :read_comments, dependent: :destroy
  has_many :read_favorites, dependent: :destroy
  has_many :notifications, dependent: :destroy
  belongs_to :user
  belongs_to :book

  acts_as_taggable

  def favorited_by?(user)
    read_favorites.where(user_id: user.id).exists?
  end

  # いいねの通知メソッド
  def create_notification_fav(current_user)
    # 既にいいねされているか検索
    temp = Notification.where(["visitor_id = ? and visited_id = ? and book_id = ? and book_read_id =? and action = ? ", current_user.id, user_id, book_id, id, "favorite"])
    # いいねがなければ、通知レコード作成
    if temp.blank?
      notification = current_user.active_notifications.new(
        book_id: book_id,
        book_read_id: id,
        visited_id: user_id,
        action: "favorite"
        )
      #自分の投稿に対するいいねは、通知済みとする
      if notification.visitor_id == notification.visited_id
        notification.checked = true
      end
      notification.save if notification.valid?
    end
  end

  # コメントの通知メソッド
  def create_notification_comment(current_user, read_comment_id)
    # 自分以外にコメントしている人をすべて取得
    temp_ids = ReadComment.select(:user_id).where(book_read_id: id).where.not(user_id: current_user.id).distinct
    # temp_idsで取得したuser_idで、繰り返し保存する
    temp_ids.each do |temp_id|
      save_notification_comment(current_user, read_comment_id, temp_id["user_id"])
    end
    #　まだだれもコメントしていない場合は、投稿者に通知を送る
    save_notification_comment(current_user, read_comment_id, user_id) if temp_ids.blank?
  end

  def save_notification_comment(current_user, read_comment_id, visited_id)
    # コメントは既存チェックせず、コメント分だけ通知する
    notification = current_user.active_notifications.new(
      book_read_id: id,
      book_id: book_id,
      read_comment_id: read_comment_id,
      visited_id: visited_id,
      action: "comment"
      )

    # 自分の投稿に対する、自分のコメントは、通知済みにする
    if notification.visitor_id == notification.visited_id
      notification.checked = true
    end
    notification.save if notification.valid?
  end

end
