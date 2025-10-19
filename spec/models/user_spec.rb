require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_db_column(:email).of_type(:string) }
  it { should have_db_column(:encrypted_password).of_type(:string) }
  it { should have_db_column(:reset_password_token).of_type(:string) }
  it { should have_db_column(:reset_password_sent_at).of_type(:datetime) }
  it { should have_db_column(:remember_created_at).of_type(:datetime) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of(:password) }
  it { should validate_length_of(:password).is_at_least(6) }

  describe 'Devise modules' do
    it { should have_db_index(:email) }
    it { should have_db_index(:reset_password_token) }
  end

  describe '.authenticate!' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns the user' do
        result = User.authenticate!('test@example.com', 'password123')
        expect(result).to eq(user)
      end
    end

    context 'with invalid email' do
      it 'returns nil' do
        result = User.authenticate!('invalid@example.com', 'password123')
        expect(result).to be_nil
      end
    end

    context 'with invalid password' do
      it 'returns nil' do
        result = User.authenticate!('test@example.com', 'wrongpassword')
        expect(result).to be_nil
      end
    end

    context 'with nil email' do
      it 'returns nil' do
        result = User.authenticate!(nil, 'password123')
        expect(result).to be_nil
      end
    end

    context 'with nil password' do
      it 'returns nil' do
        result = User.authenticate!('test@example.com', nil)
        expect(result).to be_nil
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end
  end
end
