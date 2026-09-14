require "rails_helper"

RSpec.describe "今日の旅行", type: :system do
  describe "購入チェック" do
    around do |example|
      travel_to(Date.new(2026, 8, 7)) do
        example.run
      end
    end

    let(:user) { create(:user) }
    let(:today_trip) {
      create(
        :trip,
        user:,
        name: "今日の旅行",
        departure_date: Date.new(2026, 8, 6),
        return_date: Date.new(2026, 8, 8)
      )
    }
    let(:recipient) { create(:recipient, user:) }
    let!(:trip_recipient) { create(:trip_recipient, trip: today_trip, recipient:, purchased: false) }

    before do
      login_as(user)
    end

    it "画面遷移せずに購入状態と進捗バーが更新される" do
      visit root_path

      expect(page).to have_content("今日の旅行")

      within("#trip_progress") do
        expect(page).to have_content("0%")
      end

      within("#trip_recipient_#{trip_recipient.id}") do
        expect(page).to have_button("未購入")
        click_button "未購入"

        expect(page).to have_button("購入済み")
        expect(page).not_to have_button("未購入")
      end

      expect(page).to have_current_path(root_path)

      within("#trip_progress") do
        expect(page).to have_content("100%")
      end

      within("#trip_recipient_#{trip_recipient.id}") do
        expect(page).to have_button("購入済み")
        click_button "購入済み"

        expect(page).to have_button("未購入")
        expect(page).not_to have_button("購入済み")
      end

      expect(page).to have_current_path(root_path)

      within("#trip_progress") do
        expect(page).to have_content("0%")
      end
    end
  end
end
