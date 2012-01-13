require 'spec_helper'

describe Amico::Configuration do
  describe '#configure' do
    it 'should have default attributes' do
      Amico.configure do |configuration|
        configuration.namespace.should eql('amico')
        configuration.following_key.should eql('following')
        configuration.followers_key.should eql('followers')
        configuration.blocked_key.should eql('blocked')
        configuration.reciprocated_key.should eql('reciprocated')
        configuration.page_size.should be(25)
      end
    end
  end
end