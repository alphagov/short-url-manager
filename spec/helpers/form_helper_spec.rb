require "rails_helper"

describe FormHelper do
  before do
    stub_const("TestModel", Class.new { include Mongoid::Document })
  end

  describe "#render_errors_for" do
    let(:model) do
      TestModel.new.tap do |model|
        errors.each do |error|
          model.errors.add(error[0], error[1])
        end
      end
    end
    let(:leading_message) { nil }

    let(:rendered) { Capybara::Node::Simple.new(render_errors_for(model, leading_message:)) }

    describe "without errors" do
      let(:errors) { [] }

      it "should render nothing" do
        expect(render_errors_for(model)).to be_blank
      end
    end

    describe "with errors" do
      let(:errors) do
        [
          [:attribute_1, "can't be blank"],
          [:attribute_2, "can't be a small lemon"],
        ]
      end

      describe "specific errors" do
        it "should render errors in a list" do
          expect(rendered).to have_css("div.form-errors ul li", text: "Attribute 1 can't be blank")
          expect(rendered).to have_css("div.form-errors ul li", text: "Attribute 2 can't be a small lemon")
        end
      end

      describe "heading message" do
        describe "without custom leading_message" do
          let(:leading_message) { nil }

          it "should have a default message based on the model's class name" do
            expect(rendered).to have_css("div.form-errors p", text: "The test model could not be saved for the following reasons:")
          end
        end

        describe "with custom leading_message" do
          let(:leading_message) { "Your death ray could not be activated." }

          it "should show the custom leading_message" do
            expect(rendered).to have_css("div.form-errors p", text: "Your death ray could not be activated.")
          end
        end
      end
    end
  end
end
