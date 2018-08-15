# RuleEngine
A Rule Engine to validate incoming data stream by applying rules defined by an user.

## Problem Statement
Build a rule engine that will apply rules on streaming data. Program should be able to perform following tasks, at minimum:
- Allow users to create rules on incoming data stream
- Execute rules on incoming stream and show the data that violates a rule.

Incoming data stream is a tagged data stream. Each incoming data is a hashmap with following syntax
```
{ 'signal': 'ATL1', 'value': '234.98', 'value_type': 'Integer'}
{ 'signal': 'ATL2', 'value': 'HIGH', 'value_type': 'String'}
{ 'signal': 'ATL3', 'value': '23/07/2017 13:24:00.8765', 'value_type': 'Datetime'}
...
```

In general, a data unit would have three keys
- **signal**: This key specifies the source ID of the signal. It could be any valid alphanumeric combo. ex: ATL1, ATL2, ATL3, ATL4
- **value**: This would be the actual value of the signal. This would always be a string. ex: '234', 'HIGH', 'LOW', '23/07/2017'
- **value_type**: This would specify how the value has to be interpreted. It would be one of the following
  - _Integer_: In this case the value is interpreted as an integer. Ex: '234' would be interpreted as 234
  - _String_: In this case the value is interpreted as a String. Ex: 'HIGH' would be interpreted as 'HIGH'
  - _Datetime_: In this case the value is interpreted as a DateTime.

Rules can be specified for a signal and in accordance to the value_type. Some examples of rules are:
- ATL1 value should not rise above 240.00
- ATL2 value should never be LOW
- ATL3 should not be in future

## Assumptions
- Rules are defined based on an assumption that the value_type will be of type `Integer / String / Datetime`.
  - Value Types are fixed for above 3 types.
  - Please note the value_type is a case sensitive i.e., `Datetime` is not same as `DateTime`.
- Comparison Operators like `==`, `!=`, `<`, `>`, `<=`, `>=` has been fixed to select and define a Rule behavior/validation.
- Rules have been associated with a User i.e., Any incoming Data stream will be validated based on the `current_user` rules.
- A free input text field has been provided to specify the Signal while defining the Rule since the Signal name could be any Alphanumeric Value based on the incoming Data Stream.
  - Algorithm will only consider the Data having the Signal name matching with the Rules.
- Algorithm has been written with an assumption that the Data will be an `Array` of `Hashes`.
- Assumed that there could exist a multiple rules for a single data signal and the Algorithm has been designed accordingly.

## Technical Details
- Using `devise` gem for User Authentication and Management.
- Using `sqlite3` storage for storing the rules.
- Using `kaminari` gem for pagination.
- Using `toastr-rails` gem as a flash message notifier.
- `rules#index` has been set as a `root_path`.
- CRUD actions of a Rules controller has been used for rules management.
- Custom GET actions have been added to Parse and Test the Data Stream.
- Ajax with jQuery is used for listing the failures after data parsing.
- `Datetime` Rule can be defined with Absolute value(Ex: Must be greater than `23/07/2017 13:24:00`) or Relative value(Ex: Must be less than 6 months from now i.e., `-6.months.from_now` or `6.months.from_now`).
  - Negative values for relative datetime can be provided for past dates.
  - Relative boolean field has been used for this purpose - which indicates how the date value has to be interpreted.
- Frozen Hash of Value types [`Integer`, `String`, `Datetime`] has been defined.
- Frozen Array of Comparison Operators [`==`, `!=`, `<`, `>`, `<=`, `>=`] has been defined.
- Frozen Array of Datetime Components [`second`, `minute`, `hour`, `day`, `month`, `year`] has been defined.
- The `data_parser` could be invoked from `rails console` using `Rule.parse_incoming_signal_data(user_id, file_path)`. For example `user_id = User.first.id` and `file_path = 'public/uploads/raw_data.json'`.
  - It returns the list of failure signals.

## Steps to setup and run the project on Ubuntu
- Clone the repository using [`git clone`](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository) command.
- CD into the repository and run `bundle install` and `rake db:create db:migrate` or `rake db:setup`.
- Start `rails server`.
- visit `localhost:3000` in your browser.
- `devise` authenticator will prompt you to sign_in / sign_up.
  - Sign up with your email id and sign in as an user to the Rule Engine.
  - Please note, mailers haven't been setup. Ergo, you wouldn't receive any emails.
- Upon successful login, you will be redirected to the Rules listing page. With below links:
  - To **Add** a Rule
  - To **Edit** a Rule
  - To **Remove** a Rule
  - To **Test the Data** with the Created set of Rules
  - To **Sign out**
- Adding/Editing a Rule
  - Enter **Signal name**
  - Select **Value Type**
  - Select **Comparison Operator** to define the rule and how the data must be validated Ex: 20 must be < 100
  - Specify **Value**
  - `Datetime` type has options:
    - To Specify an Absolute DateTime Ex: Should be less than `date`
    - To Specify a Relative DateTime Ex: Must not be in future
      - Negative values can be provided for relative datetime.
  - jQuery is been used to switch between Absolute and Relative value fields.
- Test with Data option redirects to a page to Run the Data Parser
  - `raw_data.json` file is placed under `/public/uploads/` directory of the RuleEngine repository.
  - Clicking on `Run Data Parser` button will validate the `raw_data.json` file contents against the `current_user` rules.
  - The Parser returns:
    - The **Start Time** of the Algorithm
    - The **End Time** of the Algorithm
    - The **Total Execution Time** of the Algorithm
    - Number of Failed data signals and
    - The list of **Failed data signals** in a tabular format.
- CSS has been written for table responsiveness, a fixed footer with background and text decorations, etc.
- Please replace either the file `raw_data.json` with your new test data or the file name/path in the `data_parser` action of the `rules_controller`.

## Discussion Questions
- Briefly describe the conceptual approach you chose! What are the trade-offs?
  - The concept of storing the operational components in the database and executing them while validating the data stream is been used. To parse the data, the grouped hashmap has been filtered to fetch the set of applicable items only and the method to evaluate the function and carryout the operation has been chosen.
  - There was no trade-offs. I chose the best and suitable approach as far as my knowledge goes, during the design phase.
  - Willing to learn and switch to optimal solution.

- What's the runtime performance? What is the complexity? Where are the bottlenecks?
  1. Runtime performance for the sample `raw_data.json` is between 
     - 10 - 12 ms(Millisecond) Best case Ω(n).
     - 14 - 17 ms(Millisecond) Average case θ(n).
     - 21 - 27 ms(Millisecond) Worst case Ο(n).
  2. Complexity of the program
    1. Time Complexity is 5N+12 where N is dependent on Input Data and Rules.
    2. Space Complexity is 5N+3 where N is dependent on Input Data and Rules.
  3. Bottlenecks could be encountered with respect to specific Datetime with zone during the comparison.

- If you had more time, what improvements would you make, and in what order of priority?
  - Improvements in Order
    - A strong model level validation to handle the Rule creation/update from other sources like `rails console`, etc.
    - Datetime with zone comparison
    - Exception handler for wrong data stream/format
    - Rspec test case scenarios
    - Add file Uploader
    - Datepicker to select Datetime while defining the Rule
    - Horizontal Form fields
    - Integration of Bootstrap with CSS for better UI/UX look and feel
    - Management of Value_types, Comparison Operators and the Date Components for Users according to their requirement and Input Data Stream.
    - Setup Mailer

## Few execution time are listed below

| Seconds       | Milliseconds  |
| ------------- |:-------------:|
| 0.021887856   | 21.88         |
| 0.025107658   | 25.10         |
| 0.015308115   | 15.30         |
| 0.017441078   | 17.44         |
| 0.012836701   | 12.83         |
| 0.013141354   | 13.14         |
| 0.016190643   | 16.19         |
| 0.014000516   | 14.00         |
| 0.011532539   | 11.53         |
| 0.010087103   | 10.09         |
