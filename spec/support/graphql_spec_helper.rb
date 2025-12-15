module GraphQLSpecHelper
  def execute_graphql(query, variables: {}, context: {})
    AccrueSchema.execute(
      query,
      variables: variables,
      context: context
    )
  end

  def graphql_response(result)
    result['data']
  end

  def graphql_errors(result)
    result['errors']
  end

  def fund_user_account(user, amount)
    external_funding = DoubleEntry::Account.account(AccountType::Internal::PRIMARY_FUNDING)
    DoubleEntry.transfer(
      Money.new(amount, 'USD'),
      from: external_funding,
      to: user.account(AccountType::User::PRIMARY),
      code: TransactionCode::DEPOSIT
    )
  end
end
