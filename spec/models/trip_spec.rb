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

      it "return_dateにエラーが追加されること" do
        trip.validate

        expect(trip.errors[:return_date]).to include("は出発日以降の日付を入力してください")
      end
    end
  end

  describe "#total_count" do
    let(:trip) { create(:trip) }

    context "相手が追加されている場合" do
      before do
        create_list(:trip_recipient, 3, trip:)
      end

      it "追加されている相手の件数を返す" do
        expect(trip.total_count).to eq(3)
      end
    end

    context "相手が追加されていない場合" do
      it "0を返す" do
        expect(trip.total_count).to eq(0)
      end
    end
  end

  describe "#purchased_count" do
    let(:trip) { create(:trip) }

    before do
      create_list(:trip_recipient, 2, trip:, purchased: true)
      create(:trip_recipient, trip:, purchased: false)
    end

    it "購入済みの相手の件数を返す" do
      expect(trip.purchased_count).to eq(2)
    end
  end

  describe "#progress_percentage" do
    let(:trip) { create(:trip) }

    context "相手が追加されていない場合" do
      it "0を返す" do
        expect(trip.progress_percentage).to eq(0)
      end
    end

    context "購入済みの相手がいない場合" do
      before do
        create_list(:trip_recipient, 3, trip:, purchased: false)
      end

      it "0を返す" do
        expect(trip.progress_percentage).to eq(0)
      end
    end

    context "一部の相手が購入済みの場合" do
      before do
        create(:trip_recipient, trip:, purchased: true)
        create_list(:trip_recipient, 2, trip:, purchased: false)
      end

      it "購入済み件数の割合を四捨五入して返す" do
        expect(trip.progress_percentage).to eq(33)
      end
    end

    context "すべての相手が購入済みの場合" do
      before do
        create_list(:trip_recipient, 3, trip:, purchased: true)
      end

      it "100を返す" do
        expect(trip.progress_percentage).to eq(100)
      end
    end
  end
end
