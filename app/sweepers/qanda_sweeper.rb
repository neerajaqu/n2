class QandaSweeper < ActionController::Caching::Sweeper
  observe Question, Answer

  def after_save(record)
    if record.is_a?(Question)
    	clear_question_cache(record)
    elsif record.is_a?(Answer)
    	clear_answer_cache(record)
    elsif record.is_a?(Idea)
    	clear_idea_cache(record)
    elsif record.is_a?(Resource)
    	clear_resource_cache(record)
    else
    	return false
    end
  end

  def after_destroy(record)
    if record.is_a?(Question)
    	clear_question_cache(record)
    elsif record.is_a?(Answer)
    	clear_answer_cache(record)
    elsif record.is_a?(Idea)
    	clear_idea_cache(record)
    elsif record.is_a?(Resource)
    	clear_resource_cache(record)
    else
    	return false
    end
  end

  def clear_resource_cache(resource)
    ['top_resources', 'newest_resources', 'resources_list'].each do |fragment|
      expire_fragment "#{fragment}_html"
      expire_fragment "#{fragment}_fbml"
    end
  end

  def clear_idea_cache(idea)
    ['top_ideas', 'newest_ideas'].each do |fragment|
      expire_fragment "#{fragment}_html"
      expire_fragment "#{fragment}_fbml"
    end
  end

  def clear_question_cache(question)
    ['top_questions', 'newest_questions', 'unanswered_questions', "#{question.cache_key}_top", "#{question.cache_key}_bottom"].each do |fragment|
      expire_fragment "#{fragment}_html"
      expire_fragment "#{fragment}_fbml"
    end
    ['', 'page_1_', 'page_2_'].each do |page|
      expire_fragment "questions_list_#{page}html"
      expire_fragment "questions_list_#{page}fbml"
    end
  end

  def clear_answer_cache(answer)
    ['top_answers', 'newest_answers', 'unanswered_questions'].each do |fragment|
      expire_fragment "#{fragment}_html"
      expire_fragment "#{fragment}_fbml"
    end
    clear_question_cache answer.question
  end

  def self.expire_resource_all resource
    controller = ActionController::Base.new
    ['top_resources', 'newest_resources', 'resources_list'].each do |fragment|
      controller.expire_fragment "#{fragment}_html"
      controller.expire_fragment "#{fragment}_fbml"
    end
  end


  def self.expire_idea_all idea
    controller = ActionController::Base.new
    ['top_ideas', 'newest_ideas'].each do |fragment|
      controller.expire_fragment "#{fragment}_html"
      controller.expire_fragment "#{fragment}_fbml"
    end
  end

  def self.expire_question_all question
    controller = ActionController::Base.new
    ['top_questions', 'newest_questions', 'unanswered_questions', "#{question.cache_key}_top", "#{question.cache_key}_bottom"].each do |fragment|
      controller.expire_fragment "#{fragment}_html"
      controller.expire_fragment "#{fragment}_fbml"
    end
    ['', 'page_1_', 'page_2_'].each do |page|
      controller.expire_fragment "questions_list_#{page}html"
      controller.expire_fragment "questions_list_#{page}fbml"
    end
  end

  def self.expire_answer_all answer
    controller = ActionController::Base.new
    ['top_answers', 'newest_answers', 'unanswered_questions'].each do |fragment|
      controller.expire_fragment "#{fragment}_html"
      controller.expire_fragment "#{fragment}_fbml"
    end
    QandaSweeper.expire_question_all answer.question
  end

end
