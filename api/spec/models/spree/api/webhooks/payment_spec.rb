require 'spec_helper'

describe Spree::Payment do
  let(:payment) { create(:payment) }

  describe '#void' do
    let(:payload) { {} }
    let(:queue_requests) { instance_double(Spree::Webhooks::Endpoints::QueueRequests) }

    before do
      allow(Spree::Webhooks::Endpoints::QueueRequests).to receive(:new).and_return(queue_requests)
      allow(queue_requests).to receive(:call).with(any_args)
    end

    shared_examples 'queues a webhook request' do
      it 'executes QueueRequests.call with a payment.void event and {} payload after invoking void' do
        payment.void
        expect(queue_requests).to have_received(:call).with(event: 'payment.void', payload: payload).once
      end
    end

    context 'when transitioning from pending to void' do
      before { payment.pend }

      include_examples 'queues a webhook request'
    end

    context 'when transitioning from processing to void' do
      before { payment.started_processing }

      include_examples 'queues a webhook request'
    end

    context 'when transitioning from completed to void' do
      before { payment.complete }

      include_examples 'queues a webhook request'
    end

    context 'when transitioning from checkout to void' do
      include_examples 'queues a webhook request'
    end
  end
end
