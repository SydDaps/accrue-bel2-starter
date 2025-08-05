# Accrue Backend Engineer L2 Assignment

Welcome! We're excited that you're interested in joining the Accrue team. This assignment is designed to give you a feel for the kind of work we do every day and to help us understand your approach to solving problems. It should take no more than **5 hours** to complete.

The goal is not just to get it working, but to write clean, maintainable, and well-tested code that fits into an existing architecture.

## Application Context

To get you started, here’s a brief overview of the key patterns in our codebase.

- **Technology Stack:** The project uses Ruby on Rails in API-only mode, with PostgreSQL for the database, GraphQL for the API layer, and RSpec for testing.
- **Interactor Pattern:** All business logic is encapsulated in interactors, which reside in `app/interactors`. Interactors have a single public method, `call`, and are responsible for executing one specific task.
  - They inherit from a base `ApplicationInteractor`.
  - Input parameters are declared using the `parameters` class method (e.g., `parameters :user, :amount`).
  - Errors are handled by calling `fail!(error_type, "error message")`.
  - [Interactor gem](https://github.com/collectiveidea/interactor-rails)
- **GraphQL API:** Our API is built with the `graphql-ruby` gem.
  - Mutations are located in `app/graphql/mutations`.
  - Types are in `app/graphql/types`.
  - Authorization in mutations and queries is handled by calling `ensure_authorized!` to ensure a `current_user` is present.
  - [GraphQL-Ruby gem](https://graphql-ruby.org/)
- **Accounting System:** We use the `double_entry` gem to manage all financial transactions and balances.
  - Core models like `User` have an `account` method (e.g., `user.account(AccountType::User::PRIMARY)`) to access their specific ledger accounts.
  - All money movement is performed using `DoubleEntry.transfer`.
  - [DoubleEntry gem](https://github.com/envato/double_entry)

## The Assignment: Implement a "Purchase Gift Card" Feature

Your task is to implement a GraphQL mutation that allows a **JWT-authenticated** user to purchase a digital gift card using their existing account balance.

### Detailed Requirements

### 1. Database Model

##### 1.1 Gift Card Model

Create a `GiftCard` model and an associated migration. It should have the following attributes:

- `slug`: A unique slug identifying the gift card.
- `name`: The name of the gift card.
- `price`: An integer to store the price of the gift card in cents.

#### 1.2 Gift Card Order Model

Create a `GiftCardOrder` model and an associated migration. It should have the following attributes:

- `user_id`: A foreign key to the `User` who owns the gift card order.
- `gift_card_id`: A foreign key to the `GiftCard` that is being purchased.
- `status`: A string/enum to track the order's state (e.g., `pending`, `completed`, `failed`).
- `fee`: An integer to store the fee of the gift card order in cents. Fee is 1% of the price.

### 2. GraphQL Query

Create a `giftCards` query. It should return a list of the available gift cards for purchase.

- **File Location:** `app/graphql/queries/gift_cards.rb`
- **Return Type:**
  - A list of `GiftCard` GraphQL types that expose the details of the available gift cards.

### 3. GraphQL Mutation

Create a `purchaseGiftCard` mutation.

- **File Location:** `app/graphql/mutations/purchase_gift_card.rb`
- **Arguments:**
  - `giftcard` (ID!, required): The gift card to purchase.
  - `user` (User, ID!): The user who is purchasing the gift card.
- **Return Type:**
  - The mutation should return a new `GiftCardOrder` GraphQL type that exposes the details of the newly created gift card order. (gift_card, status, created_at)
- **Authorization:**
  - The mutation must be protected, ensuring only an authenticated user can perform this action.

### 3. Business Logic (Interactor)

Create an interactor to handle the logic of purchasing a gift card.

- **File Location:** `app/interactors/accrue/gift_cards/purchase.rb`
- **Parameters:** `user`, `amount`
- **Logic:**
  1. Validate that the `amount` is a positive value.
  2. Check if the `user` has sufficient funds in their primary account (amount + fee). You can access this via `user.account(AccountType::User::PRIMARY)`.
  3. If the balance is sufficient, execute a `DoubleEntry` transfer to move the funds from the user's primary balance to their outgoing balance. You can assume the following constants and configurations exist:
     - **From Account:** `user.account(AccountType::User::PRIMARY)`
     - **To Account:** `AccountType::User::OUTGOING` (an internal account for revenue)
     - **Transaction Code:** `TransactionCode::GIFT_CARD_PURCHASE`
  4. Move the fee charged from the user's outgoing balance to the internal revenue account. You can assume the following constants and configurations exist:
     - **From Account:** `AccountType::User::OUTGOING`
     - **To Account:** `AccountType::Internal::GIFT_CARD_REVENUE`
     - **Transaction Code:** `TransactionCode::GIFT_CARD_FEE`
  5. Upon successful transfer, create and save the new `GiftCardOrder` record, associating it with the user.
  6. The interactor should return the newly created `GiftCardOrder` instance on success.
- **Error Handling:**
  - If the user's balance is too low, the interactor should fail with an `:insufficient_funds` error which will be returned to the client.
  - If the amount is invalid (e.g., zero or negative), it should fail with an `:invalid_amount` error which will be returned to the client.

### 4. Testing (RSpec)

Write comprehensive tests for the new functionality.

- **Interactor Spec:**
  - Test the successful purchase of a gift card.
  - Test the failure case for insufficient funds.
  - Test the failure case for an invalid purchase amount.
- **Query Spec:**
  - Test that the query returns a list of gift cards.
  - Test that the query returns the correct fields for each gift card.
- **Mutation Spec:**
  - Write a request spec to test the mutation via a GraphQL query.
  - Test the happy path for an authenticated user.
  - Test that an unauthenticated request is rejected.
  - Verify that the correct error messages are returned from the API when the business logic fails (e.g., for insufficient funds).

### What We're Looking For

- **Correctness and Robustness:** Does the feature work as specified? Are edge cases handled?
- **Code Quality:** Is the code clean, readable, and easy to maintain?
- **Adherence to Patterns:** Do you follow the established architectural patterns (Interactor, GraphQL structure)?
- **Testing:** How thorough are your tests? Do they cover both success and failure scenarios?
- **Problem-Solving:** How did you approach the problem and structure your solution?

### Setup & Submission

1. Clone this starter repository.
2. Run `bundle install` to install dependencies, and `rails db:setup` to set up the database.
3. Create a new branch for your work.
4. When you are finished, please open a pull request against the `main` branch of this repository and let us know.

Good luck! We're looking forward to seeing your work.
