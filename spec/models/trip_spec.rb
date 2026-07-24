require 'rails_helper'

RSpec.describe Trip, type: :model do
  describe "バリデーション" do
    subject(:trip) { build(:trip) }

    context "すべての属性が有効な場合" do
      it "有効である" do
        expect(trip).to be_valid
      end
    end

    context "nameが空の場合" do
      before { trip.name = nil }

      it "無効である" do
        expect(trip).to be_invalid
        expect(trip.errors[:name]).to be_present
      end
    end

    context "destinationが空の場合" do
      before { trip.destination = nil }

      it "無効である" do
        expect(trip).to be_invalid
        expect(trip.errors[:destination]).to be_present
      end
    end

    context "departure_dateが空の場合" do
      before { trip.departure_date = nil }

      it "無効である" do
        expect(trip).to be_invalid
        expect(trip.errors[:departure_date]).to be_present
      end
    end

    context "return_dateが空の場合" do
      before { trip.return_date = nil }

      it "無効である" do
        expect(trip).to be_invalid
        expect(trip.errors[:return_date]).to be_present
      end
    end

    context "出発日と帰宅日が同じ場合" do
      before do
        trip.departure_date = Date.today
        trip.return_date = Date.today
      end

      it "有効である" do
        expect(trip).to be_valid
      end
    end

    context "帰宅日が出発日より後の場合" do
      before do
        trip.departure_date = Date.yesterday
        trip.return_date = Date.today
      end

      it "有効である" do
        expect(trip).to be_valid
      end
    end

    context "帰宅日が出発日より前の場合" do
      before do
        trip.departure_date = Date.today
        trip.return_date = Date.yesterday
      end

      it "無効である" do
        expect(trip).to be_invalid
      end
    end
  end
end
