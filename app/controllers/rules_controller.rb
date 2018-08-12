class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy]

  # GET /rules
  # GET /rules.json
  def index
    @rules = current_user.rules
  end

  # GET /rules/new
  def new
    @rule = Rule.new
  end

  # POST /rules
  # POST /rules.json
  def create
    @rule = Rule.new(rule_params)
    @rule.user = current_user
    @rule.value = construct_value

    respond_to do |format|
      if @rule.save
        format.html { redirect_to rules_url, notice: 'Rule was successfully created.' }
        format.json { render :show, status: :created, location: @rule }
      else
        format.html { render :new }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rules/1
  # PATCH/PUT /rules/1.json
  def update
    respond_to do |format|
      @rule.value = construct_value
      if @rule.update(rule_params)
        format.html { redirect_to rules_url, notice: 'Rule was successfully updated.' }
        format.json { render :show, status: :ok, location: @rule }
      else
        format.html { render :edit }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule.destroy
    respond_to do |format|
      format.html { redirect_to rules_url, notice: 'Rule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /rules/data_parser
  # POST /rules/data_parser.json
  def data_parser
    start_time = Time.now
    @failure_list = []
    rules = current_user.rules.group_by(&:signal)
    rule_keys = rules.keys
    file = File.read('public/raw_data.json')
    data_hash = JSON.parse(file).uniq
    applicable_data = data_hash.select { |a| rule_keys.include? a["signal"] }.uniq
    applicable_data.each do |data|
      relevant_rules = rules[data["signal"]].select { |r| r.value_type == data["value_type"] }.uniq
      relevant_rules.each do |rule|
        if rule.value_type == data["value_type"]
          lhs = data["value"]
          rhs = rule.value
          if rule.value_type == Rule::TYPES[:dt]
            rhs = rule.relative ? eval(rhs) : rhs.to_time
          elsif rule.value_type == Rule::TYPES[:int]
            lhs = lhs.to_i
            rhs = rhs.to_i
          end
          @failure_list << data unless lhs.method(rule.comparison_operator).(rhs)
        else
          @failure_list << data
        end
      end
    end
    end_time = Time.now
    render partial: "rules/failure_list", locals: { start_time: start_time, end_time: end_time, execution_time: (end_time - start_time) }
    # redirect_to test_rules_url(start_time: start_time, end_time: end_time, execution_time: (end_time - start_time), failure_list: failure_list.uniq.first(16)), notice: "Test was run successfully."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      @rule = Rule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rule_params
      params.require(:rule).permit(:signal, :value_type, :comparison_operator, :relative)
    end

    # Construct the value based on the type and option.
    def construct_value
      if Rule::TYPES.values_at(:int, :str).include? params[:rule][:value_type]
        params[:signal_value]
      elsif params[:rule][:relative] == "1"
        "#{params[:val] || 0}.#{params[:rule][:value]}.from_now"
      else
        DateTime.civil(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i,params[:date][:hour].to_i,params[:date][:minute].to_i)
      end
    end
end
