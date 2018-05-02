require_relative 'questions.rb'

class Users
  attr_accessor :fname, :lname
  attr_reader :id
  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if user.length == 0
    Users.new(user.first)
  end

  def self.find_by_name(fname, lname)
      user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if user.length == 0
    Users.new(user.first)
  end

  def self.all
    user = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      users
  SQL
  return nil if user.length == 0
  user.map {|usa| Users.new(usa)}
  end

  def initialize(options)
    @fname = options['fname']
    @lname = options['lname']
    @id = options['id']
  end

  def authored_questions
    Questions.find_by_author_id(id)
  end

  def authored_replies
    Replies.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollows.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLikes.liked_questions_for_user_id(id)
  end

  def average_karma
    question_ids = QuestionsDatabase.instance.execute(<<-SQL, @id)

    SELECT
      (SELECT
          COUNT(question_id) AS num_likes
        FROM
          question_likes
        WHERE
          question_id IN (
                SELECT
                  questions.id
                FROM
                  questions
                WHERE
                  questions.user_id = 1)
        GROUP BY
          question_id) / CAST(COUNT(questions.id) AS FLOAT)
    FROM
      questions
    WHERE
      questions.user_id = 1
    SQL

  end

  def save
    raise "#{self} already saved in database" if @id
    saved = QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end



# SELECT
#   SUM(ct) / COUNT(user_id)
# FROM (
#   SELECT
#     questions.id, questions.user_id, question_likes.id, COUNT(questions.id) AS ct
#   FROM
#     questions
#   LEFT JOIN question_likes
#     ON questions.id = question_likes.question_id
#   GROUP BY
#     questions.id
# ) AS inn
# WHERE
#   question.user_id = 2
# GROUP BY
#   questions.id
#
