class MoonboardPolicy < ApplicationPolicy
    def index?
      true
    end
  
    def update?
      @account_user.administrator?
    end
  
    def show?
      true
    end
  
    def create?
      @account_user.administrator?
    end
  
    def destroy?
      @account_user.administrator?
    end

    def download?
      @account_user.administrator?
    end
  end
  