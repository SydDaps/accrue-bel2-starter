class ApplicationInteractor
  include Interactor

  def with_locked_accounts(accounts, &block)
    DoubleEntry.lock_accounts(accounts) do
      block.call
    end
  rescue StandardError => e
    raise e if e.is_a?(Interactor::Failure)
    Rails.logger.error "Transaction failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    fail!(ErrorTypes::TRANSACTION_FAILED, "Something went wrong. Try again later.")
  end

  def within_transaction(&block)
    ActiveRecord::Base.transaction do
      block.call
    end
  end

  def fail!(error_type, message)
    context.fail!(error: { type: error_type, message: message })
  end
end
