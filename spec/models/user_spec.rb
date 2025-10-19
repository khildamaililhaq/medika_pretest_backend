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
  # Removed length validation test as it's now handled by custom complexity validation

  describe 'password complexity' do
    let(:user) { build(:user) }

    context 'with valid password' do
      it 'is valid' do
        user.password = 'Password1!'
        user.password_confirmation = 'Password1!'
        expect(user).to be_valid
      end
    end

    context 'with password too short' do
      it 'is invalid' do
        user.password = 'Pass1!'
        user.password_confirmation = 'Pass1!'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must be at least 8 characters and include at least one uppercase letter, one number, and one special character')
      end
    end

    context 'with password missing uppercase' do
      it 'is invalid' do
        user.password = 'password1!'
        user.password_confirmation = 'password1!'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must be at least 8 characters and include at least one uppercase letter, one number, and one special character')
      end
    end

    context 'with password missing number' do
      it 'is invalid' do
        user.password = 'Password!'
        user.password_confirmation = 'Password!'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must be at least 8 characters and include at least one uppercase letter, one number, and one special character')
      end
    end

    context 'with password missing special character' do
      it 'is invalid' do
        user.password = 'Password1'
        user.password_confirmation = 'Password1'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must be at least 8 characters and include at least one uppercase letter, one number, and one special character')
      end
    end
  end

  describe 'Devise modules' do
    it { should have_db_index(:email) }
    it { should have_db_index(:reset_password_token) }
  end

  describe '.authenticate!' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'P@ssword123!') }

    context 'with valid credentials' do
      it 'returns the user' do
        result = User.authenticate!('test@example.com', 'P@ssword123!')
        expect(result).to eq(user)
      end
    end

    context 'with invalid email' do
      it 'returns nil' do
        result = User.authenticate!('invalid@example.com', 'P@ssword123!')
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
        result = User.authenticate!(nil, 'P@ssword123!')
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
