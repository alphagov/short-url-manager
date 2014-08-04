require 'rails_helper'

describe FormHelper do
  let(:test_model_klass) {
    class TestModel
      include Mongoid::Document
    end
  }

  describe '#render_errors_for' do
    let(:model) {
      test_model_klass.new.tap { |model|
        errors.each { |error|
          model.errors.add(error[0], error[1])
        }
      }
    }
    let(:leading_message) { nil }

    subject { Capybara::Node::Simple.new(render_errors_for(model, leading_message: leading_message)) }

    describe "without errors" do
      let(:errors) { [] }

      it "should render nothing" do
        expect(render_errors_for(model)).to be_blank
      end
    end

    describe "with errors" do
      let(:errors) { [
        [:attribute_1, "can't be blank"],
        [:attribute_2, "can't be a small lemon"]
      ] }

      describe "specific errors" do
        it "should render errors in a list" do
          expect(subject).to have_css("div.form_errors ul li", text: "Attribute 1 can't be blank")
          expect(subject).to have_css("div.form_errors ul li", text: "Attribute 2 can't be a small lemon")
        end
      end

      describe "heading message" do
        describe "without custom leading_message" do
          let(:leading_message) { nil }

          it "should have a default message based on the model's class name" do
            expect(subject).to have_css("div.form_errors p", text: "The test model could not be saved for the following reasons:")
          end
        end

        describe "with custom leading_message" do
          let(:leading_message) { "Your death ray could not be activated." }

          it "should show the custom leading_message" do
            expect(subject).to have_css("div.form_errors p", text: "Your death ray could not be activated.")
          end
        end
      end
    end
  end
end
