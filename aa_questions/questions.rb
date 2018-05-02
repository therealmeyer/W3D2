require 'sqlite3'
require 'Singleton'
require_relative 'users.rb'
require_relative 'replies.rb'
require_relative 'question_follow.rb'
require_relative 'question_likes.rb'


class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end



class Questions

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
      *
      FROM
      questions
      WHERE
      id = ?
    SQL
    return nil if question.empty?
    Questions.new(question.first)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
      *
      FROM
      questions
      WHERE
      user_id = ?
    SQL
    return nil if questions.empty?
    questions.map {|question| Questions.new(question)}
  end

  def self.most_followed(n)
    QuestionFollows.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end

  def initialize(options)
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
    @id = options['id']

  end

  def author
    user = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
      *
      FROM
      users
      WHERE
      id = ?
    SQL
    return nil if user.empty?
    Users.new(user.first)
  end

  def replies
    Replies.find_by_question_id(id)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def likers
    QuestionLikes.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end

  def save
    raise "#{self} already saved in database" if @id
    saved = QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions(title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end
