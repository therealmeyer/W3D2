require_relative 'questions.rb'

class Replies



  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
      *
      FROM
      replies
      WHERE
      id = ?
    SQL

    return nil if reply.empty?
    Replies.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
      *
      FROM
      replies
      WHERE
      user_id = ?
    SQL

    return nil if replies.empty?
    replies.map{|reply| Replies.new(reply)}
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
      *
      FROM
      replies
      WHERE
      question_id = ?
    SQL

    return nil if replies.empty?
    replies.map{|reply| Replies.new(reply)}
  end




  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    author = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
      *
      FROM
      users
      WHERE
      id = ?
    SQL
    return nil if author.empty?
    Users.new(author.first)
  end

  def question
    quest = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
      *
      FROM
      questions
      WHERE
      id = ?
    SQL
    return nil if quest.empty?
    Questions.new(quest.first)
  end

  def parent_reply
    reply = QuestionsDatabase.instance.execute(<<-SQL, @parent_reply_id)
      SELECT
      *
      FROM
      replies
      WHERE
      id = ?
    SQL
    return nil if reply.empty?
    Replies.new(reply.first)
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
      *
      FROM
      replies
      WHERE
      parent_reply_id = ?
    SQL
    return nil if reply.empty?
    reply.map{|rep| Replies.new(rep)}
  end

  def save
    raise "#{self} already saved in database" if @id
    saved = QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id, @body)
      INSERT INTO
        replies(question_id, parent_reply_id, user_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end
