class Book < ApplicationRecord
  has_many :book_reads, dependent: :destroy
  has_many :book_unreads, dependent: :destroy
  has_many :book_comments, dependent: :destroy

  validates  :isbn, presence: true

  acts_as_taggable

  # Bookモデルに登録するハッシュ
  def self.book_details(book)
    {
      "title" => book.title,
      "isbn" => book.isbn,
      "author" => book.author,
      "publisher_name" => book.publisher_name,
      "image_url" => book.large_image_url.chomp("?_ex=200x200"),
      "sales_date" => book.sales_date,
      "url" => book.item_url,
    }
  end

  # 読んだ本が既にテーブルに存在するか？
  def read_exists?(user, type)
    if type == "read"
      book_reads.where(user_id: user.id).exists?
    else
      book_unreads.where(user_id: user.id).exists?
    end
  end

  # 楽天ブックスのジャンルID（カテゴリ）
  enum genre_id:
    { 少年: "001001001",
      少女: "001001002",
      青年: "001001003",
      レディース: "001001004",
      文庫: "001001006",
      その他: "001001012",
    }
  # 楽天ブックスのジャンルID（出版社名）
  # enum publisher_id:
  #   { 秋田書店 少年チャンピオン: "001001001001",
  #     スクウェア・エニックス ガンガンC: "001001002",
  #     青年: "001001003",
  #     レディース: "001001004",
  #     文庫: "001001006",
  #     その他: "001001012",
  #   }

  #  本を検索する
  def self.search_books(keyword:"本", author:"", sort:"standard", genre:"", hits:"28")
    RakutenWebService::Books::Total.search(
      keyword: keyword,
      author: author,
      sort: sort,
      booksGenreId:"001001" + genre,
      orFlag: "1",
      hits: hits)
  end

  # 読んだ順
  def self.reads_rank
    # BookRead.all.group(:book_id).order("count(:book_id) desc")
    BookRead.all.group(:book_id).sort {|a,b| b.book_id.size <=> a.book_id.size}
  end

  def self.unreads_rank
    BookUnread.all.group(:book_id).sort {|a,b| b.book_id.size <=> a.book_id.size}
  end

  def self.reviews_avg
      self.book_reads.sum(:rate) / self.book_reads.count
  end

end
