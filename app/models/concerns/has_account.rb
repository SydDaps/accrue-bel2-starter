module HasAccount
  def account(account_type, currency = Dollar)
    user_accounts = [AccountType::User::PRIMARY, AccountType::User::OUTGOING]

    balance_fields = {
      currency: currency,
      scope: user_accounts.include?(account_type) ? self : nil
    }.compact

    DoubleEntry::Account.account(account_type, **balance_fields)
  end

  def entry_lines(account_type, code = nil)
    user_accounts = [AccountType::User::PRIMARY, AccountType::User::OUTGOING]

    entry_lines_fields = {
      account: account_type,
      code: code,
      scope: user_accounts.include?(account_type) ? "user_#{id}" : nil
    }.compact

    DoubleEntry::Line.where(entry_lines_fields)
  end
end
