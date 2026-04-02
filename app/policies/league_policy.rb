class LeaguePolicy < ApplicationPolicy
    def index?
        user.present? # True if user is logged in
    end

    def show?
      record.owner == user || LeagueMembership.exists?(user: user, league: record)
    end

    def destroy?
      record.owner == user
    end

    def invite?
      record.owner == user
    end

    class Scope < Scope
        def resolve
        scope.all
        end
    end
end
