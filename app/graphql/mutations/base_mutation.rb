# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    field :errors, [Types::ErrorType], null: true

    def resolve(**args)
      begin
        send(:execute, **args) if respond_to?(:execute)
      rescue ActiveRecord::RecordInvalid => e
        {errors: [{ type: ErrorTypes::VALIDATION_ERROR, message: e.record.errors.full_messages }]}
      rescue ActiveRecord::RecordNotFound => e
        {errors: [{ type: ErrorTypes::NOT_FOUND, message: "#{e.model} not found" }]}
      rescue Errors::Unauthorized => e
        {errors: [{ type: ErrorTypes::UNAUTHORIZED, message: e.message }]}
      rescue GraphQL::ExecutionError => e
        {errors: [{ type: e.extensions[:type] || ErrorTypes::EXECUTION_ERROR, message: e.message }]}
      rescue => e
        Rails.logger.error "Mutation Error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        {errors: [{ type: ErrorTypes::INTERNAL_ERROR, message: "Something went wrong, please try again later." }]}
      end
    end

    def raise_graphql_error(type, message)
      raise GraphQL::ExecutionError.new(message, extensions: { type: type })
    end

    def within_transaction(&block)
      ActiveRecord::Base.transaction do
        block.call
      end
    end

    def current_user
      context[:current_user]
    end

    def ensure_authorized!
      raise Errors::Unauthorized, "Unauthorized" unless current_user
    end
  end
end
