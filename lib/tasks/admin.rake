namespace :admin do
  desc "Make the first user an admin"
  task make_first_user_admin: :environment do
    user = User.order(:created_at).first

    if user
      user.update(admin: true)
      puts "Successfully made #{user.email} an admin."
    else
      puts "No users found in the database."
    end
  end

  desc "Make a specific user an admin by email"
  task :make_admin, [:email] => :environment do |t, args|
    email = args[:email]
    
    if email.blank?
      puts "Please provide an email address: rake admin:make_admin[user@example.com]"
      exit
    end

    user = User.find_by(email: email)
    
    if user
      if user.admin?
        puts "#{user.email} is already an admin."
      else
        user.update(admin: true)
        puts "Successfully made #{user.email} an admin."
      end
    else
      puts "User with email '#{email}' not found."
    end
  end

  desc "Remove admin privileges from a user by email"
  task :remove_admin, [:email] => :environment do |t, args|
    email = args[:email]
    
    if email.blank?
      puts "Please provide an email address: rake admin:remove_admin[user@example.com]"
      exit
    end

    user = User.find_by(email: email)
    
    if user
      if user.admin?
        user.update(admin: false)
        puts "Successfully removed admin privileges from #{user.email}."
      else
        puts "#{user.email} is not an admin."
      end
    else
      puts "User with email '#{email}' not found."
    end
  end

  desc "List all admin users"
  task list_admins: :environment do
    admins = User.where(admin: true)
    
    if admins.any?
      puts "Admin users:"
      admins.each do |admin|
        puts "- #{admin.email} (created: #{admin.created_at.strftime('%Y-%m-%d %H:%M')})"
      end
    else
      puts "No admin users found."
    end
  end

  desc "Show user admin status by email"
  task :status, [:email] => :environment do |t, args|
    email = args[:email]
    
    if email.blank?
      puts "Please provide an email address: rake admin:status[user@example.com]"
      exit
    end

    user = User.find_by(email: email)
    
    if user
      status = user.admin? ? "Admin" : "Regular user"
      puts "#{user.email}: #{status} (created: #{user.created_at.strftime('%Y-%m-%d %H:%M')})"
    else
      puts "User with email '#{email}' not found."
    end
  end
end
