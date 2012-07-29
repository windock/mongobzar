require 'mongobzar/utility/virtual_proxy'

module Mongobzar module Utility module Test
  describe VirtualProxy do
    subject { VirtualProxy.new(loader) }

    context 'when actual is not loaded' do
      let(:loader) { stub }
      let(:actual) { stub }

      it 'loads it on any request and delegates to actual' do
        loader.stub!(:call) { actual }

        actual.should_receive(:unknown).with(no_args)
        subject.unknown
      end
    end

    context 'when actual is already loaded' do
      let(:loader) { stub(call: actual) }
      let(:actual) { stub(bootstrap: nil) }

      before do
        subject.bootstrap
      end

      it 'does not load actual, just delegates' do
        loader.should_not_receive(:call)
        actual.should_receive(:unknown).with(no_args)
        subject.unknown
      end
    end

    let(:loader) { stub }
    let(:actual) { stub }
    it 'does delegate build-in Object methods' do
    end

    it 'delegates == to actual' do
      loader.stub!(:call) { actual }
      subject.should == actual
    end
  end
end end end
