module V2

  class SkillsController < ApplicationController

  	before_action :find_skill, only: [:show, :update, :destroy]

  	def index
  		@skills = policy_scope(Skill).where(user_id: params[:user_id])
  	end

  	def create
      authorize Skill
      
  		@skill = Skill.new(skill_params)
      if @skill.save
        render :action => "show"
      else
        render json: { status: { error: @skill.errors.full_messages }}, status: :unprocessable_entity
      end
  	end

    def update
      authorize @skill

      if @skill.update_attributes(update_params)
        render :action => "show"
      else
        render json: { status: { error: @skill.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @skill

      @skill.destroy
      head :no_content
    end

  	private

  	def find_skill
  		@skill = policy_scope(Skill).find(params[:id])
  	end

    def skill_params
      params.require(:skill).permit(:name, :description, transportation: []).merge(user: current_user)
    end

    def update_params
      params.require(:skill).permit(:name, :description, transportation: [])
    end
  end
end
