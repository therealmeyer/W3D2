require_relative 'questions.rb'

class QuestionFollows

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
      question_follows
      JOIN users
        ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL

    return nil if users.empty?
    users.map{|user| Users.new(user)}

  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.user_id
      FROM
      question_follows
      JOIN questions
        ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL

    return nil if questions.empty?
    questions.map{|qu| Questions.new(qu)}
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT
          questions.id, title, body, questions.user_id
        FROM
          questions
        JOIN question_follows
          ON questions.id = question_follows.question_id
        GROUP BY
          question_follows.question_id
        ORDER BY
          COUNT(questions.id) DESC
        LIMIT
          ?
      SQL
      return nil if questions.empty?
      questions.map {|qu| Questions.new(qu)}

  end


  def initialize (options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end







end
