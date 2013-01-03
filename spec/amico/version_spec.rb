require 'spec_helper'

describe 'Amico::VERSION' do
  it 'should be the correct version' do
    Amico::VERSION.should == '2.3.2'
  end
end