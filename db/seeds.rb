300.times do |i|
  problem = Problem.new(description: "Problem #{i}", form: rand(1..2))

  options_count = rand(1..10)
  options_count.times do |j|
    problem.options << Option.new(description: (65 + j).chr)
  end

  if problem.form == 1
    problem.options[rand(options_count)].right = true
  else
    rand(1..options_count).times do
      problem.options[rand(options_count)].right = true
    end
  end

  tags = ['Tag-A', 'Tag-B', 'Tag-C', 'Tag-D', 'Tag-E', 'Tag-F']
  problem.tags_list = tags.sample(rand(7)).join(';')

  problem.save
end

30.times { |i| Organization.create(uid: "#{i}", name: "Org #{i}") }

300.times do |i|
  user = User.new(uid: "#{i}", name: "User #{i}")
  user.organization_ids = Organization.ids.sample(rand(1..30))
  user.save
end

30.times do |i|
  paper = Paper.new(title: "Test #{i}", scale: rand(1..2))

  problem_ids = Problem.single.ids.sample(rand(20)).concat Problem.multi.ids.sample(rand(20))
  if paper.scale == 1
    problem_scores = Array.new(problem_ids.length, 5)
  else
    problem_scores = Array.new(problem_ids.length) { rand(1..20) }
  end
  paper.problems_list = (problem_ids.map.with_index { |id, j| "#{id}-#{problem_scores[j]}" }).join(';')
  paper.send :add_problems

  paper.user_ids = User.ids.sample(80)

  now = Time.now
  last_year = now.at_beginning_of_year - 1.year
  duration = (now - last_year).to_i
  paper.created_at = last_year + rand(duration)
  paper.deadline = paper.created_at + rand(duration)

  paper.save(validate: false)
end

Enroll.all.each do |enroll|
  finished = rand(1..10)
  paper = enroll.paper
  enroll.created_at = paper.created_at

  if (finished > 4)
    enroll.score = rand(1..paper.assigns.sum(:problem_score))

    duration = (paper.deadline - paper.created_at).to_i
    enroll.hand_in_time = paper.created_at + rand(duration)
  end

  enroll.save
end
