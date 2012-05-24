class Test_Thing
  # To change this template use File | Settings | File Templates.
  def initialize
    #do nothing
  end

  def do_something
    @rules = Rule.all

    @rules.each do |rule|
      puts "#{rule.group.id} #{rule.group.title} - #{rule.id} #{rule.title}"
      @users = rule.group.users
      @users.each do |user|
        puts user.email
      end
    end
  end
end