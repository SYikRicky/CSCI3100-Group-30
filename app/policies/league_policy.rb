class LeaguePolicy < ApplicationPolicy
    def index?
        user.present? # True if user is logged in
    end

    def show?
        user.present?
    end

    class Scope < Scope
        def resolve
        scope.all
        end
    end
end
