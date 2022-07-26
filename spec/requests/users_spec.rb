require 'rails_helper'
require 'helper'

RSpec.configure do |config|
  config.include Helper::User
end

RSpec.describe UsersController, type: :request do
  let(:headers) { { 'HTTPS': 'on', 
                    'HTTP_ACCEPT': 'application/json' } }
  before do
    FactoryBot.create(:user, name: "John",
                             email: "john@mail.com",
                             password: "password",
                             password_confirmation: "password" )
   
    FactoryBot.create(:user, name: "Jake",
                             email: "jake@mail.com",
                             password: "password",
                             password_confirmation: "password" )
  end
  describe "GET /users" do
    it 'returns all users' do
        get '/users', headers: headers 

        custom_expect response, status: :success
        expect( JSON.parse(response.body).size )
          .to eq(2) 
          end
  end
  describe "POST /users" do
    let(:user_json) do
      { user: {  name: "Lexy",
                 email: "lexy@mail.com",
                 password: "password",
                 password_confirmation: "password" } } 
    end 
    it 'creates a valid user' do
        post '/users', params: user_json, headers: headers
        custom_expect response, status: :created,
                          expected_keys: %w[ name email is_author ],
                          unexpected_keys: %w[ password_digest ]
        expect( User.count )
          .to eq(3) 
          end
    it 'doesn\'t create a nonvalid user' do
        user_json[:user][:password_confirmation] = "anotherpass"
        user_json[:user][:email] = "lexymail.com"

        post '/users', params: user_json, headers: headers

        custom_expect response, status: :unprocessable_entity,
                          expected_keys: %w[ password_confirmation email ]
        expect( User.count )
          .to eq(2)
          end
  end
  describe "GET /users/:id" do
    it 'showes a user' do
        user = create_local_user
      
        get "/users/#{user.id}", headers: headers
        custom_expect response, status: :success,
                          expected_keys: %w[ name email is_author ],
                          unexpected_keys: %w[ password_digest ]
          end
  end
  describe "DELETE /users/:id" do
    it 'deletes a user' do
        user = create_local_user
        
        delete "/users/#{user.id}", headers: headers

        custom_expect response, status: :no_content
        expect( User.count )
          .to eq(2) 
          end
  end
end
