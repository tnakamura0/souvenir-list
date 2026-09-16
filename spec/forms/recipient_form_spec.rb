require "rails_helper"

RSpec.describe RecipientForm do
  describe "#save" do
    let(:user) { create(:user) }
    let(:form) do
      described_class.new(
        recipient:,
        user:,
        attributes:
      )
    end

    context "新規作成の場合" do
      let(:recipient) { user.recipients.build }
      let(:attributes) { attributes_for(:recipient) }

      context "正常な値の場合" do
        it "相手を作成する" do
          expect {
            form.save
          }.to change(Recipient, :count).by(1)
        end

        context "新しいタグ名が入力された場合" do
          let(:attributes) do
            attributes_for(:recipient).merge(
              new_tag_name: "家族"
            )
          end

          it "タグを作成して相手に関連付ける" do
            expect {
              form.save
            }.to change(Tag, :count).by(1)

            tag = user.tags.find_by(name: "家族")

            expect(recipient.reload.tags).to include(tag)
          end
        end

        context "同名のタグが既に存在する場合" do
          let(:attributes) do
            attributes_for(:recipient).merge(
              new_tag_name: "家族"
            )
          end

          it "既存のタグを相手に関連付ける" do
            existing_tag = create(:tag, user:, name: "家族")

            expect {
              form.save
            }.not_to change(Tag, :count)

            expect(recipient.reload.tags).to include(existing_tag)
          end
        end
      end

      context "不正な値の場合" do
        let(:attributes) { attributes_for(:recipient, name: nil) }

        it "相手を作成せずfalseを返す" do
          expect {
            @result = form.save
          }.not_to change(Recipient, :count)

          expect(@result).to be false
        end
      end
    end

    context "更新の場合" do
      let(:recipient) { create(:recipient, user:, name: "更新前の名前") }

      context "正常な値の場合" do
        let(:attributes) { { name: "更新後の名前" } }

        it "相手を更新する" do
          form.save

          expect(recipient.reload.name).to eq("更新後の名前")
        end
      end

      context "不正な値の場合" do
        let(:attributes) { { name: "" } }

        it "相手を更新せずfalseを返す" do
          expect(form.save).to be false
          expect(recipient.reload.name).to eq("更新前の名前")
        end
      end
    end
  end
end
