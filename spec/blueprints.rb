User.blueprint do
  username { "username#{sn}" }
  password { 'password' }
  email {"#{object.username}@example.com"}
end


Convo.blueprint do
  title {"title#{sn}"}
  privacy {'public'}
  # associations eventually should just work, perhaps not working as expected because the user is embedded, oh well
  owner { User.make }
end


Subscription.blueprint do
  user { User.make }
  convo { Convo.make }
end


Invitation.blueprint do
  user { User.make }
  convo { Convo.make }
  requestor { User.make }
end


Message.blueprint do
  convo { Convo.make }
  owner { User.make }
  body { "body#{sn}"}
end