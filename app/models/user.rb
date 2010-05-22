class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :database_authenticatable, :registerable, :confirmable, :recoverable,
  :rememberable, :trackable, :validatable

  validates_presence_of :username
  validates_uniqueness_of :username


  field :username #  t.string,  :null               => false
  field :email #  t.string,  :null               => false
  field :encrypted_password # t.string, :limit   => 40, :null => false
  field :password_salt # t.string, :null         => false
  field :confirmation_token # t.string, :limit   => 20
  field :confirmed_at, :type => DateTime # t.datetime
  field :confirmation_sent_at, :type => DateTime # t.datetime
  field :reset_password_token # t.string, :limit => 20
  field :remember_token # t.string, :limit       => 20
  field :remember_created_at, :type => DateTime # t.datetime
  field :sign_in_count, :type => Integer # t.integer
  field :current_sign_in_at, :type => DateTime # t.datetime
  field :last_sign_in_at, :type => DateTime # t.datetime
  field :current_sign_in_ip # t.string
  field :last_sign_in_ip # t.string
  field :failed_attempts, :type => Integer, :default => 0 # t.integer, :default   => 0
  field :unlock_token # t.string, :limit         => 20
  field :locked_at, :type => DateTime # t.datetime
  field :created_at, :type => DateTime # t.datetime
  field :updated_at, :type => DateTime # t.datetime


end