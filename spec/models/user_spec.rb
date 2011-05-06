require 'spec_helper'

describe User do
  describe "remarkable" do
    before(:each) do
      @user = Factory(:user)
    end
    it { should have_fields(:created_at, :updated_at).of_type(Time) }

    it { should validate_presence_of :username }
    it { should validate_uniqueness_of :username }

    it { should reference_many :subscriptions }
    it { should reference_many :invitations }
    it { should reference_many :followerships }

    it { should embed_many :visits }

    it { should reference_many :convos }
    it { should reference_many :messages }


    it { should validate_uniqueness_of( :username) }
    it { should validate_uniqueness_of( :email) }

    it { should have_fields(:username, :email, :encrypted_password, :password_salt, :confirmation_token) }
    it { should have_fields(:confirmed_at, :confirmation_sent_at, :remember_created_at, :current_sign_in_at, :last_sign_in_at, :locked_at).of_type(DateTime) }

    it { should have_fields( :reset_password_token, :remember_token, :current_sign_in_at, :last_sign_in_ip, :unlock_token) }

    it { should have_fields( :sign_in_count).of_type(Integer)}
    it { should have_fields( :failed_attempts).of_type(Integer).with_default_value_of(0)}
  end


  describe "business logic" do
    it "should produce gravatar url" do
      user = User.make(:email => "test@example.com")
      user.gravatar.should include("gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0.jpg")      
    end
  end


  describe "followers logic" do
    before do
      @follower = User.make!
      @leader = User.make!
    end
    
    it "should be able to follow" do
      @leader.should_not be_followed(@follower)
      @follower.follow(@leader)
      @leader.should be_followed(@follower)
    end

    it "should be able to unfollow" do
      @follower.follow(@leader)
      @leader.should be_followed(@follower)
      @follower.unfollow(@leader)
      @leader.should_not be_followed(@follower)      
    end
  end
  
  
  describe "visiting multiple convos" do
    before do
      @user = User.make!
       3.times do |i|
          Convo.make!(:owner => @user, :created_at => i*1000)
       end
       Convo.all.each do |convo|
         @user.visit convo
       end       
    end
    it "should grow the visits collection" do
       @user.visits.count.should == 3
    end

    it "should not grow if the same convos are visited again" do
      # visit the same convos again
      Convo.all.each do |convo|
        @user.visit convo
      end       
      @user.visits.count.should == 3      
    end

    it "should return visited_convos" do
      @user.visited_convos.should == Convo.all.reverse
    end

    it "should return visited_convos" do
      all_convos = Convo.all
      @user.visited_convos.count == all_convos.count
      
      @user.visited_convos.each do |visited_convo|
        all_convos.should include visited_convo
      end
    end
        
    it "should not grow more then 100 items" do
      first_visit = @user.visits[0]
      first_visit.convo.should == Convo.all[0]
      @user.visits.should include first_visit
      #after this there should be 1003 convos created but only 1000 visits
      100.times do |i|         
         @user.visit Convo.make!(:owner => @user, :created_at => i*1000)
      end
      @user.visits.count.should == 100
      # and the first item pushed out
      @user.visits.should_not include first_visit      
    end    

  end
  
  describe "updated_subscriptions are made to subsriptions" do
    before do
      @user = User.make!
      # this convo will be automatically subscribed because the @user is the owner
      @convo = Convo.make!(:owner => @user)
      
      # this convo will have to explicitely subscribe because the owner is different
      convo = Convo.make!
      convo.subscribe @user
      # let's make another subscription just to make sure it's not affecting anything 
      Subscription.make!
    end
    
    it "should have 2 subscription" do
      @user.subscriptions.count.should == 2
    end
    
    it "should have updated_subscriptions when a new message posted to a subscribed convo which was never visited" do
      3.times { Message.make!(:convo => @convo, :owner => @user) }
      @user = User.find(@user.id)
      @user.updated_subscriptions.count.should == 1
      @user.updated_subscriptions[0].new_messages_count.should == 3
      # add one more message, new_messages_count increased
      Message.make!(:convo => @convo, :owner => @user)
      @user.updated_subscriptions[0].new_messages_count.should == 4
    end

    it "should have updated_subscriptions when a new message posted to a subscribed convo which was visited before" do
      Message.make!(:convo => @convo, :owner => @user)
      @user.visit @convo
      @user = User.find(@user.id) # have to refetch the user
      Message.make!(convo: @convo, owner: @user, created_at: Time.now + 1)
      @user.updated_subscriptions[0].new_messages_count.should == 1
      # one more message
      Message.make!(convo: @convo, owner: @user, created_at: Time.now + 1)
      @user.updated_subscriptions[0].new_messages_count.should == 2
      # and now visit and it should reset
      @user.visit @convo
      @user = User.find(@user.id) # have to refetch the user
      @user.updated_subscriptions.count.should == 0
    end


    it "should have updates when a new convo created and automatically subscribed"
    
  end
  
  
end
