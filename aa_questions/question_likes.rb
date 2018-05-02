require_relative 'questions.rb'

class QuestionLikes

  def self.likers_for_question_id(question_id)

    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, fname, lname
      FROM
        users
      JOIN question_likes
        ON users.id = question_likes.user_id
      WHERE
        question_id = ?
    SQL

    return nil if likers.empty?
    likers.map {|liker| Users.new(liker)}

  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(question_id) AS num_likes
      FROM
        question_likes
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL
    num_likes[0]['num_likes']
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, title, body, questions.user_id
      FROM
        question_likes
      JOIN questions
        ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL
    return nil if questions.empty?
    questions.map { |question| Questions.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT
          questions.id, title, body, questions.user_id
        FROM
          questions
        JOIN question_likes
          ON questions.id = question_likes.question_id
        GROUP BY
          question_likes.question_id
        ORDER BY
          COUNT(questions.id) DESC
        LIMIT
          ?
      SQL
      return nil if questions.empty?
      questions.map {|qu| Questions.new(qu)}

  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end














end
